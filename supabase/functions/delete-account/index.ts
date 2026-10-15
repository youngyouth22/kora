// delete-account — permanent account deletion (App Store / Play requirement).
// verify_jwt = true. Body: { "confirm": "DELETE" }
// Order matters: 1) database rows (cascade)  2) storage files  3) RevenueCat customer  4) auth user.
// Every step is idempotent, so the app can simply retry if something fails halfway.
import { handle, HttpError, json, readJson } from '../_shared/http.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';

const BUCKETS = ['scan-photos', 'scan-masks'] as const;
type Admin = ReturnType<typeof adminClient>;

Deno.serve(handle(async (req) => {
  if (req.method !== 'POST') throw new HttpError(405, 'method_not_allowed');
  const { user, userClient } = await requireUser(req);
  const body = await readJson(req);
  if (body.confirm !== 'DELETE') throw new HttpError(400, 'confirmation_required', 'Send {"confirm":"DELETE"}.');

  const admin = adminClient();
  const uid = user.id;

  // Warn the app if a store subscription is still active (deleting data does NOT cancel it).
  const ent = await admin.from('entitlements').select('is_pro,expires_at').eq('user_id', uid).maybeSingle();
  const hadActiveSubscription = !!ent.data?.is_pro && (!ent.data.expires_at || new Date(ent.data.expires_at) > new Date());

  // 1) Wipe database rows. Runs as the user (auth.uid()); returns storage paths to delete.
  const wipe = await userClient.rpc('delete_my_account_data');
  if (wipe.error) throw new HttpError(500, 'db_wipe_failed', wipe.error.message);
  const paths = (wipe.data ?? {}) as { photo_paths?: string[]; mask_paths?: string[] };

  // 2) Delete storage files: known paths + a sweep of the user's folders (catches uploads that never got a scan row).
  const failures: string[] = [];
  await removeFiles(admin, 'scan-photos', paths.photo_paths ?? [], failures);
  await removeFiles(admin, 'scan-masks', paths.mask_paths ?? [], failures);
  for (const bucket of BUCKETS) {
    const orphans = await listAll(admin, bucket, uid, 0);
    await removeFiles(admin, bucket, orphans, failures);
  }

  // 3) RevenueCat customer data (optional, best effort). Needs a SECRET API key (sk_...).
  let revenuecatDeleted: boolean | null = null;
  const rcKey = Deno.env.get('REVENUECAT_SECRET_API_KEY');
  if (rcKey) {
    try {
      const res = await fetch(`https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(uid)}`, {
        method: 'DELETE', headers: { Authorization: `Bearer ${rcKey}` }, signal: AbortSignal.timeout(10_000),
      });
      revenuecatDeleted = res.ok || res.status === 404;
    } catch {
      revenuecatDeleted = false;
    }
  }

  // 4) Delete the auth user last (cascades anything left that references auth.users).
  const del = await admin.auth.admin.deleteUser(uid);
  if (del.error && !/not.?found/i.test(del.error.message)) {
    // Data is already gone; tell the app to retry so the auth record is removed too.
    throw new HttpError(500, 'auth_delete_failed',
      'Your data was deleted but the account record remains. Please retry.', { retry: true });
  }

  return json({
    deleted: true,
    had_active_subscription: hadActiveSubscription, // the app should tell the user to cancel in the store
    revenuecat_deleted: revenuecatDeleted,
    storage_failures: failures.length,
  });
}));

async function removeFiles(admin: Admin, bucket: string, paths: string[], failures: string[]): Promise<void> {
  for (let i = 0; i < paths.length; i += 100) {
    const chunk = paths.slice(i, i + 100);
    const { error } = await admin.storage.from(bucket).remove(chunk);
    if (error) failures.push(`${bucket}: ${error.message}`);
  }
}

/** Recursively lists files under `<uid>/` (depth: uid/scan_id/file). */
async function listAll(admin: Admin, bucket: string, prefix: string, depth: number): Promise<string[]> {
  if (depth > 3) return [];
  const { data, error } = await admin.storage.from(bucket).list(prefix, { limit: 1000 });
  if (error || !data) return [];
  const out: string[] = [];
  for (const item of data) {
    const full = `${prefix}/${item.name}`;
    if (item.id) out.push(full); // file
    else out.push(...await listAll(admin, bucket, full, depth + 1)); // folder
  }
  return out;
}
