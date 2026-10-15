// YouCam (Perfect Corp) Skin Analysis client — endpoints taken from docs.perfectcorp.com/reference/ai_skin_analysis
import { sleep } from './http.ts';

const BASE = (Deno.env.get('YOUCAM_BASE_URL') ?? 'https://yce-api-01.makeupar.com').replace(/\/$/, '');

/** SD concerns requested (override with YOUCAM_SD_ACTIONS="a,b,c"). Verify names in the docs before changing. */
export const SD_ACTIONS: string[] = (Deno.env.get('YOUCAM_SD_ACTIONS') ??
  'acne,redness,age_spot,texture,pore,wrinkle,moisture,oiliness,radiance,dark_circle_v2,firmness,eye_bag')
  .split(',').map((s) => s.trim()).filter(Boolean);

/** HD action names are deliberately NOT hard-coded: set YOUCAM_HD_ACTIONS from the docs to enable HD. */
export const HD_ACTIONS: string[] = (Deno.env.get('YOUCAM_HD_ACTIONS') ?? '')
  .split(',').map((s) => s.trim()).filter(Boolean);

export class YoucamError extends Error {
  constructor(public status: number, public code: string, message: string) {
    super(message);
  }
}

// deno-lint-ignore no-explicit-any
type Json = any;

async function yc(path: string, init: RequestInit & { retries?: number } = {}): Promise<Json> {
  const key = Deno.env.get('YOUCAM_API_KEY');
  if (!key) throw new YoucamError(500, 'config_error', 'YOUCAM_API_KEY is not set');
  const retries = init.retries ?? 2;
  let lastErr: unknown;
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const res = await fetch(BASE + path, {
        ...init,
        headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json', ...(init.headers ?? {}) },
        signal: AbortSignal.timeout(20_000),
      });
      const text = await res.text();
      let body: Json = {};
      try { body = text ? JSON.parse(text) : {}; } catch { /* non-JSON body */ }
      if (res.ok) return body;
      const code = String(body?.error_code ?? body?.error ?? res.status);
      const msg = String(body?.message ?? body?.error ?? text.slice(0, 200) ?? res.status);
      if ((res.status === 429 || res.status >= 500) && attempt < retries) {
        const ra = Number(res.headers.get('retry-after'));
        await sleep(ra > 0 ? Math.min(ra, 10) * 1000 : 800 * 2 ** attempt);
        continue;
      }
      throw new YoucamError(res.status, code, msg);
    } catch (e) {
      if (e instanceof YoucamError) throw e;
      lastErr = e;
      if (attempt < retries) { await sleep(800 * 2 ** attempt); continue; }
    }
  }
  throw new YoucamError(502, 'network_error', String(lastErr));
}

export interface UploadTarget {
  fileId: string;
  method: string;
  url: string;
  headers: Record<string, string>;
}

/** Step 1: register the file and get a pre-signed upload URL. */
export async function createFile(p: { contentType: string; fileName: string; fileSize: number }): Promise<UploadTarget> {
  const body = await yc('/s2s/v2.0/file', {
    method: 'POST',
    body: JSON.stringify({ files: [{ content_type: p.contentType, file_name: p.fileName, file_size: p.fileSize }] }),
  });
  const f = body?.data?.files?.[0];
  const r = f?.requests?.[0];
  if (!f?.file_id || !r?.url) throw new YoucamError(502, 'bad_response', 'File registration returned no upload URL');
  return { fileId: f.file_id, method: r.method ?? 'PUT', url: r.url, headers: r.headers ?? {} };
}

/** Step 3: start the analysis. */
export async function createSkinTask(p: { fileId: string; actions: string[] }): Promise<string> {
  const body = await yc('/s2s/v2.0/task/skin-analysis', {
    method: 'POST',
    body: JSON.stringify({ src_file_id: p.fileId, dst_actions: p.actions, format: 'json' }),
  });
  const id = body?.data?.task_id;
  if (!id) throw new YoucamError(502, 'bad_response', 'Task creation returned no task_id');
  return String(id);
}

export type TaskState =
  | { state: 'running' }
  | { state: 'success'; data: Json }
  | { state: 'error'; code: string; message: string };

/** Step 4: poll once. */
export async function getSkinTask(taskId: string): Promise<TaskState> {
  const body = await yc(`/s2s/v2.0/task/skin-analysis/${encodeURIComponent(taskId)}`, { method: 'GET' });
  const d = body?.data ?? {};
  const st = String(d.task_status ?? '').toLowerCase();
  if (st === 'success' || st === 'succeeded' || st === 'completed') return { state: 'success', data: d };
  if (st === 'error' || st === 'failed' || st === 'failure') {
    return { state: 'error', code: String(d.error ?? d.error_code ?? 'error_unknown'), message: String(d.error_message ?? '') };
  }
  return { state: 'running' };
}

/** Privacy: remove the input image and outputs from the provider once we stored what we need (best effort). */
export async function deleteTask(taskId: string): Promise<void> {
  try {
    await yc('/s2s/v2.0/task/delete', { method: 'POST', body: JSON.stringify({ task_id: taskId }), retries: 1 });
  } catch (e) {
    console.warn('provider task delete failed (non-fatal)', e instanceof Error ? e.message : e);
  }
}

// ---------- result parsing ----------
export interface ParsedConcern {
  concern: string;
  zone: string | null;
  raw_score: number;
  ui_score: number | null;
  mask_url: string | null;
}
export interface ParsedResult {
  overall: number | null;
  skinAge: number | null;
  concerns: ParsedConcern[];
}

const num = (v: unknown): number | null => (typeof v === 'number' && Number.isFinite(v) ? v : null);

/** Tolerant parser: the exact shape of overall score / skin age must be confirmed on the first real call
 *  (the full provider response is stored in scans.result_json for that purpose). */
export function parseSkinResults(data: Json): ParsedResult {
  const out: Json[] = Array.isArray(data?.results?.output) ? data.results.output
    : Array.isArray(data?.results) ? data.results : [];
  const concerns: ParsedConcern[] = [];
  let overall: number | null = num(data?.results?.overall ?? data?.results?.score ?? data?.results?.all?.score);
  let skinAge: number | null = num(data?.results?.skin_age);

  for (const item of out) {
    const type = String(item?.type ?? '');
    if (!type) continue;
    if (type === 'all' || type === 'overall') { overall = overall ?? num(item.score) ?? num(item.raw_score); continue; }
    if (type === 'skin_age') { skinAge = skinAge ?? num(item.raw_score) ?? num(item.score); continue; }
    const raw = num(item.raw_score) ?? num(item.score);
    if (raw === null) continue;
    const region = typeof item.region === 'string' && item.region && item.region !== 'whole' ? item.region : null;
    const masks: unknown = item.mask_urls;
    concerns.push({
      concern: type.replace(/^hd_/, ''),
      zone: region,
      raw_score: raw,
      ui_score: num(item.ui_score),
      mask_url: Array.isArray(masks) && typeof masks[0] === 'string' ? masks[0] : null,
    });
  }
  if (overall === null) {
    const whole = concerns.filter((c) => c.zone === null);
    if (whole.length) overall = Math.round((whole.reduce((s, c) => s + c.raw_score, 0) / whole.length) * 100) / 100;
  }
  return { overall, skinAge, concerns };
}

// ---------- error mapping (user-facing, English) ----------
export interface UserFacingError { code: string; message: string; retake: boolean }

export function mapYoucamError(code: string): UserFacingError {
  const c = code.toLowerCase();
  if (c.includes('lighting')) return { code, message: 'Too dark here. Face a window and try again.', retake: true };
  if (c.includes('too_small')) return { code, message: 'Move a bit closer so your face fills the circle.', retake: true };
  if (c.includes('out_of_bound')) return { code, message: 'Keep your whole face inside the frame.', retake: true };
  if (c.includes('no_face') || c.includes('face_not_found') || c.includes('no_faces')) {
    return { code, message: "We couldn't see a face. Look straight at the camera.", retake: true };
  }
  if (c.includes('below_min')) return { code, message: 'This photo is too small. Use a larger one.', retake: true };
  if (c.includes('exceed_max')) return { code, message: 'This photo is too large. Try again.', retake: true };
  if (c.includes('face')) return { code, message: 'Make sure your whole face is clearly visible.', retake: true };
  return { code, message: "We couldn't finish. You won't be charged. Please try again.", retake: false };
}
