// scan — orchestrates a YouCam skin analysis. verify_jwt = true (called by the Flutter app).
//
// Flow (POST JSON, field "action"):
//   start  -> checks the gate (Pro / free scan / caps), creates the scan row, registers the file at YouCam,
//             returns a pre-signed upload target. The app PUTs the image straight to it.
//   run    -> creates the analysis task, answers 202 immediately, finishes in the background and writes the
//             result with complete_scan() (Realtime on public.scans tells the app when it is done).
//   status -> idempotent fallback: polls once and finalizes if the provider is done (use if Realtime is slow).
import { handle, HttpError, isUuid, json, readJson, sleep } from '../_shared/http.ts';
import { adminClient, requireUser, runInBackground } from '../_shared/supabase.ts';
import {
  createFile, createSkinTask, deleteTask, getSkinTask, HD_ACTIONS, mapYoucamError, parseSkinResults, SD_ACTIONS,
  YoucamError,
} from '../_shared/youcam.ts';

const MAX_BYTES = 10 * 1024 * 1024;
const BACKGROUND_BUDGET_MS = 110_000;
const UNITS_PER_SCAN = Number(Deno.env.get('YOUCAM_UNITS_PER_SCAN') ?? '0'); // set from GET /s2s/v2.0/credit/feature-cost
const DELETE_AT_PROVIDER = (Deno.env.get('YOUCAM_DELETE_AFTER_SCAN') ?? 'true') !== 'false';
const EXT: Record<string, string> = { 'image/jpeg': 'jpg', 'image/png': 'png' };

type Admin = ReturnType<typeof adminClient>;

Deno.serve(handle(async (req) => {
  if (req.method !== 'POST') throw new HttpError(405, 'method_not_allowed');
  const { user } = await requireUser(req);
  const body = await readJson(req);
  switch (body.action) {
    case 'start': return await start(user.id, body);
    case 'run': return await run(user.id, body);
    case 'status': return await status(user.id, body);
    default: throw new HttpError(400, 'invalid_action', 'action must be start | run | status');
  }
}));

// ------------------------------------------------------------------ start
async function start(uid: string, body: Record<string, unknown>): Promise<Response> {
  const mode = body.mode === 'HD' ? 'HD' : 'SD';
  if (mode === 'HD' && HD_ACTIONS.length === 0) {
    throw new HttpError(400, 'hd_not_enabled', 'HD analysis is not enabled on this server.');
  }
  const contentType = String(body.content_type ?? '');
  const fileSize = Number(body.file_size);
  if (!EXT[contentType]) throw new HttpError(400, 'invalid_content_type', 'Use image/jpeg or image/png.');
  if (!Number.isInteger(fileSize) || fileSize < 1 || fileSize > MAX_BYTES) {
    throw new HttpError(400, 'invalid_file_size', 'Image must be between 1 byte and 10 MB.');
  }

  const admin = adminClient();
  const gate = await admin.rpc('scan_gate', { p_user: uid });
  if (gate.error) throw new HttpError(500, 'gate_failed', gate.error.message);
  const g = gate.data as { allowed: boolean; reason?: string; warning?: string; next_allowed_at?: string };
  if (!g.allowed) {
    throw new HttpError(
      g.reason === 'pro_required' ? 402 : 429,
      g.reason ?? 'not_allowed',
      g.reason === 'pro_required' ? 'Weekly scans are part of Pro.' : 'Scan limit reached. Try again later.',
      { gate: g },
    );
  }

  const ins = await admin.from('scans').insert({ user_id: uid, status: 'created', mode }).select('id').single();
  if (ins.error || !ins.data) throw new HttpError(500, 'db_error', ins.error?.message);
  const scanId = ins.data.id as string;

  try {
    const target = await createFile({ contentType, fileName: `${scanId}.${EXT[contentType]}`, fileSize });
    const upd = await admin.from('scans').update({ api_file_id: target.fileId, status: 'uploading' }).eq('id', scanId);
    if (upd.error) throw new HttpError(500, 'db_error', upd.error.message);
    return json({
      scan_id: scanId,
      upload: { method: target.method, url: target.url, headers: target.headers },
      max_bytes: MAX_BYTES,
      warning: g.warning ?? null,
      next_allowed_at: g.next_allowed_at ?? null,
      // Storage path to use if the user keeps photos: bucket "scan-photos"
      photo_path_hint: `${uid}/${scanId}/photo.${EXT[contentType]}`,
    });
  } catch (e) {
    await admin.rpc('fail_scan', { p_scan: scanId, p_error_code: 'provider_unavailable' });
    if (e instanceof HttpError) throw e;
    if (e instanceof YoucamError) {
      throw new HttpError(e.status === 429 ? 429 : 502, 'provider_unavailable', 'The analysis service is busy. Please try again.');
    }
    throw e;
  }
}

// -------------------------------------------------------------------- run
async function run(uid: string, body: Record<string, unknown>): Promise<Response> {
  const scanId = body.scan_id;
  if (!isUuid(scanId)) throw new HttpError(400, 'invalid_scan_id');
  const admin = adminClient();

  const found = await admin.from('scans')
    .select('id,user_id,status,api_file_id,api_task_id,mode').eq('id', scanId).eq('user_id', uid).maybeSingle();
  if (found.error) throw new HttpError(500, 'db_error', found.error.message);
  const scan = found.data;
  if (!scan) throw new HttpError(404, 'scan_not_found');
  if (scan.status === 'done' || scan.api_task_id) return json({ scan_id: scanId, status: scan.status }, 200);
  if (scan.status !== 'uploading' || !scan.api_file_id) throw new HttpError(409, 'invalid_state', `Scan is ${scan.status}.`);

  let photoPath: string | null = null;
  if (typeof body.photo_path === 'string' && body.photo_path) {
    if (!body.photo_path.startsWith(`${uid}/${scanId}/`) || body.photo_path.includes('..')) {
      throw new HttpError(400, 'invalid_photo_path');
    }
    photoPath = body.photo_path;
  }

  // Claim the scan atomically so two concurrent calls cannot create two tasks (and burn two units).
  const claim = await admin.from('scans').update({ status: 'processing', photo_path: photoPath })
    .eq('id', scanId).eq('status', 'uploading').is('api_task_id', null).select('id');
  if (claim.error) throw new HttpError(500, 'db_error', claim.error.message);
  if (!claim.data || claim.data.length === 0) return json({ scan_id: scanId, status: 'processing' }, 202);

  try {
    const actions = scan.mode === 'HD' ? HD_ACTIONS : SD_ACTIONS;
    const taskId = await createSkinTask({ fileId: scan.api_file_id, actions });
    await admin.from('scans').update({ api_task_id: taskId }).eq('id', scanId);
  } catch (e) {
    const code = e instanceof YoucamError ? e.code : 'provider_unavailable';
    await admin.rpc('fail_scan', { p_scan: scanId, p_error_code: code });
    const ue = mapYoucamError(code);
    throw new HttpError(
      e instanceof YoucamError && e.status === 429 ? 429 : 502,
      'analysis_not_started', ue.message, { retake: ue.retake },
    );
  }

  runInBackground(finalizeLoop(scanId));
  return json({ scan_id: scanId, status: 'processing' }, 202);
}

// ----------------------------------------------------------------- status
async function status(uid: string, body: Record<string, unknown>): Promise<Response> {
  const scanId = body.scan_id;
  if (!isUuid(scanId)) throw new HttpError(400, 'invalid_scan_id');
  const admin = adminClient();

  let row = await loadScan(admin, scanId, uid);
  if (row.status === 'processing' && row.api_task_id) {
    await pollAndFinalize(scanId);
    row = await loadScan(admin, scanId, uid);
  }
  const failed = row.status === 'failed';
  const ue = failed ? mapYoucamError(row.error_code ?? '') : null;
  return json({
    scan_id: scanId, status: row.status, overall_score: row.overall_score, skin_age: row.skin_age,
    error_code: row.error_code, message: ue?.message ?? null, retake: ue?.retake ?? null,
  });
}

// ------------------------------------------------------------ background
async function loadScan(admin: Admin, scanId: string, uid: string) {
  const r = await admin.from('scans')
    .select('id,user_id,status,api_task_id,error_code,overall_score,skin_age').eq('id', scanId).eq('user_id', uid).maybeSingle();
  if (r.error) throw new HttpError(500, 'db_error', r.error.message);
  if (!r.data) throw new HttpError(404, 'scan_not_found');
  return r.data;
}

async function finalizeLoop(scanId: string): Promise<void> {
  const deadline = Date.now() + BACKGROUND_BUDGET_MS;
  let delay = 3000;
  while (Date.now() < deadline) {
    await sleep(delay);
    delay = Math.min(delay + 1000, 6000);
    const state = await pollAndFinalize(scanId);
    if (state !== 'processing') return;
  }
  // Budget exhausted: the app's "status" calls will finish it.
}

/** Polls the provider once; finalizes on success/error. Safe to call concurrently (complete_scan is idempotent). */
async function pollAndFinalize(scanId: string): Promise<'processing' | 'done' | 'failed'> {
  const admin = adminClient();
  const r = await admin.from('scans').select('id,user_id,status,api_task_id').eq('id', scanId).maybeSingle();
  const scan = r.data;
  if (!scan) return 'failed';
  if (scan.status === 'done') return 'done';
  if (scan.status === 'failed' || scan.status === 'canceled') return 'failed';
  if (!scan.api_task_id) return 'processing';

  let task;
  try {
    task = await getSkinTask(scan.api_task_id);
  } catch (e) {
    console.warn('poll failed (will retry)', e instanceof Error ? e.message : e);
    return 'processing';
  }
  if (task.state === 'running') return 'processing';
  if (task.state === 'error') {
    await admin.rpc('fail_scan', { p_scan: scanId, p_error_code: task.code });
    if (DELETE_AT_PROVIDER) await deleteTask(scan.api_task_id);
    return 'failed';
  }

  try {
    const parsed = parseSkinResults(task.data);
    if (parsed.concerns.length === 0) throw new Error('no concerns in provider result');

    const concerns = await Promise.all(parsed.concerns.map(async (c) => ({
      concern: c.concern, zone: c.zone, raw_score: c.raw_score, ui_score: c.ui_score,
      mask_path: await storeMask(admin, scan.user_id, scanId, c),
    })));

    const done = await admin.rpc('complete_scan', {
      p_scan: scanId, p_overall: parsed.overall, p_skin_age: parsed.skinAge, p_concerns: concerns,
      p_result: task.data, p_units: UNITS_PER_SCAN, p_quality_ok: true,
    });
    if (done.error) throw new Error(done.error.message);
    if (DELETE_AT_PROVIDER) await deleteTask(scan.api_task_id);
    return 'done';
  } catch (e) {
    console.error('finalize failed', e instanceof Error ? e.message : e);
    await admin.rpc('fail_scan', { p_scan: scanId, p_error_code: 'result_parse_error' });
    return 'failed';
  }
}

async function storeMask(
  admin: Admin, uid: string, scanId: string,
  c: { concern: string; zone: string | null; mask_url: string | null },
): Promise<string | null> {
  if (!c.mask_url) return null;
  try {
    const res = await fetch(c.mask_url, { signal: AbortSignal.timeout(15_000) });
    if (!res.ok) return null;
    const ct = (res.headers.get('content-type') ?? 'image/png').split(';')[0].trim();
    const ext = ct === 'image/jpeg' ? 'jpg' : ct === 'image/webp' ? 'webp' : 'png';
    const path = `${uid}/${scanId}/${c.concern}${c.zone ? '_' + c.zone : ''}.${ext}`;
    const up = await admin.storage.from('scan-masks')
      .upload(path, new Uint8Array(await res.arrayBuffer()), { contentType: ct, upsert: true });
    return up.error ? null : path;
  } catch (e) {
    console.warn('mask copy failed (non-fatal)', c.concern, e instanceof Error ? e.message : e);
    return null;
  }
}
