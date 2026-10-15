// revenuecat-webhook — keeps public.entitlements in sync with RevenueCat.
// verify_jwt = false (RevenueCat cannot send a Supabase JWT). Authentication = the shared
// "Authorization header value" you configure in the RevenueCat dashboard (REVENUECAT_WEBHOOK_AUTH).
//
// All business rules live in SQL (apply_revenuecat_event): idempotent on event.id, ignores stale events,
// CANCELLATION keeps access until expiry, EXPIRATION removes it, refunds revoke immediately.
import { json, timingSafeEqual } from '../_shared/http.ts';
import { adminClient } from '../_shared/supabase.ts';

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  const expected = Deno.env.get('REVENUECAT_WEBHOOK_AUTH');
  if (!expected) {
    console.error('REVENUECAT_WEBHOOK_AUTH is not configured');
    return json({ error: 'server_misconfigured' }, 500);
  }
  const got = req.headers.get('authorization') ?? '';
  const ok = (await timingSafeEqual(got, expected)) || (await timingSafeEqual(got, `Bearer ${expected}`));
  if (!ok) return json({ error: 'unauthorized' }, 401);

  let payload: { event?: Record<string, unknown> };
  try {
    payload = await req.json();
  } catch {
    return json({ error: 'invalid_json' }, 400);
  }
  const event = payload?.event;
  if (!event || typeof event !== 'object' || typeof event.id !== 'string' || typeof event.type !== 'string') {
    return json({ error: 'invalid_event' }, 400);
  }

  const { data, error } = await adminClient().rpc('apply_revenuecat_event', { p_event: event });
  if (error) {
    // 5xx => RevenueCat retries with backoff, which is what we want for transient DB errors.
    console.error('apply_revenuecat_event failed', event.id, error.message);
    return json({ error: 'processing_failed' }, 500);
  }
  console.log('revenuecat event', event.type, event.id, JSON.stringify(data));
  return json({ ok: true, result: data }, 200);
});
