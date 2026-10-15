// Supabase clients. The service-role client NEVER leaves the server.
import { createClient, type SupabaseClient, type User } from 'npm:@supabase/supabase-js@2';
import { HttpError } from './http.ts';

function required(...names: string[]): string {
  for (const n of names) {
    const v = Deno.env.get(n);
    if (v) return v;
  }
  throw new HttpError(500, 'config_error', `Missing environment variable: ${names.join(' | ')}`);
}

const opts = { auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false } };

export function adminClient(): SupabaseClient {
  return createClient(
    required('SUPABASE_URL'),
    required('SUPABASE_SERVICE_ROLE_KEY', 'SUPABASE_SECRET_KEY', 'SB_SECRET_KEY'),
    opts,
  );
}

export interface AuthedRequest {
  user: User;
  jwt: string;
  /** Acts as the signed-in user: RLS applies, auth.uid() works inside RPCs. */
  userClient: SupabaseClient;
}

export async function requireUser(req: Request): Promise<AuthedRequest> {
  const header = req.headers.get('Authorization') ?? '';
  const jwt = header.startsWith('Bearer ') ? header.slice(7).trim() : '';
  if (!jwt) throw new HttpError(401, 'unauthorized', 'Missing bearer token.');

  const userClient = createClient(
    required('SUPABASE_URL'),
    required('SUPABASE_ANON_KEY', 'SUPABASE_PUBLISHABLE_KEY', 'SB_PUBLISHABLE_KEY'),
    { ...opts, global: { headers: { Authorization: `Bearer ${jwt}` } } },
  );
  const { data, error } = await userClient.auth.getUser(jwt);
  if (error || !data.user) throw new HttpError(401, 'unauthorized', 'Invalid or expired session.');
  return { user: data.user, jwt, userClient };
}

/** Runs a promise after the response is sent (Supabase Edge Runtime), or detached as a fallback. */
export function runInBackground(p: Promise<unknown>): void {
  // deno-lint-ignore no-explicit-any
  const rt = (globalThis as any).EdgeRuntime;
  const guarded = p.catch((e) => console.error('background task failed', e));
  if (rt?.waitUntil) rt.waitUntil(guarded);
}
