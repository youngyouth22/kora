// coach — secure gateway between the Flutter app and your Mastra agent. verify_jwt = true.
//
//   App --(user JWT)--> this function --(shared secret)--> Mastra server --> LLM
//
// What this function guarantees (the model cannot be trusted with any of it):
//   * daily message limit, enforced by a DB trigger on public.messages (free 3 / Pro 30 by default)
//   * the user's data comes from coach_context() (SQL, no photos) — never from the client
//   * medical / crisis red flags are answered by deterministic rules BEFORE any model call
//   * history is stored in public.messages (Supabase is the source of truth, Mastra stays stateless)
//
// Request:  POST { "message": "..." }
// Response: text/event-stream with events
//   meta   {message_id}              the stored user message
//   delta  {text}                    answer chunks
//   action {type,label,payload}      optional structured suggestion rendered as a button (suggest_action tool)
//   done   {message_id, remaining}   the stored assistant message
//   error  {error,message}           (the user's message is refunded if the model was unavailable)
import { handle, HttpError, readJson } from '../_shared/http.ts';
import { adminClient, requireUser } from '../_shared/supabase.ts';
import { detectRedFlags } from '../_shared/safety.ts';
import { sseResponse } from '../_shared/sse.ts';
import { streamAgent } from '../_shared/mastra.ts';

const MAX_MESSAGE_CHARS = 2000;
const HISTORY_LIMIT = 12;
const FALLBACK_REPLY =
  "I couldn't put together a good answer just now. Could you rephrase your question? This is general information, not medical advice.";

Deno.serve(handle(async (req) => {
  if (req.method !== 'POST') throw new HttpError(405, 'method_not_allowed');
  const { user, userClient, jwt } = await requireUser(req);
  const body = await readJson(req);

  const message = String(body.message ?? '').trim();
  if (!message || message.length > MAX_MESSAGE_CHARS) {
    throw new HttpError(400, 'invalid_message', `Message must be 1-${MAX_MESSAGE_CHARS} characters.`);
  }

  // 1) Store the user message AS THE USER: the DB trigger enforces the daily quota atomically.
  const ins = await userClient.from('messages').insert({ user_id: user.id, role: 'user', content: message }).select('id').single();
  if (ins.error || !ins.data) {
    if (ins.error?.code === 'P0001' || /coach_limit_reached/.test(ins.error?.message ?? '')) {
      throw new HttpError(429, 'coach_limit_reached', "You've reached today's coach limit. It resets tomorrow.");
    }
    throw new HttpError(500, 'db_error', ins.error?.message);
  }
  const userMessageId = ins.data.id as string;
  const admin = adminClient();

  // 2) Deterministic safety layer (no model involved).
  const flag = detectRedFlags(message);
  if (flag) {
    return sseResponse(async (send) => {
      send('meta', { message_id: userMessageId });
      send('delta', { text: flag.reply });
      const saved = await saveAssistant(admin, user.id, flag.reply, { safety: flag.kind });
      send('done', { message_id: saved, remaining: await remaining(userClient), safety: flag.kind });
    });
  }

  // 3) Context + recent history, both read as the user (RLS applies).
  const [ctx, hist] = await Promise.all([
    userClient.rpc('coach_context'),
    userClient.from('messages').select('role,content').in('role', ['user', 'assistant'])
      .order('created_at', { ascending: false }).limit(HISTORY_LIMIT),
  ]);
  if (ctx.error) throw new HttpError(500, 'context_failed', ctx.error.message);
  const messages = ((hist.data ?? []) as { role: string; content: string }[]).reverse();

  const mastraUrl = Deno.env.get('MASTRA_URL');
  const mastraSecret = Deno.env.get('MASTRA_API_SECRET');
  if (!mastraUrl || !mastraSecret) {
    await admin.from('messages').delete().eq('id', userMessageId);
    throw new HttpError(503, 'coach_unavailable', 'The coach is not configured yet.');
  }

  return sseResponse(async (send) => {
    send('meta', { message_id: userMessageId });
    let answer = '';
    const actions: unknown[] = [];
    try {
      await streamAgent({
        baseUrl: mastraUrl, secret: mastraSecret, agentId: Deno.env.get('MASTRA_AGENT_ID') ?? 'skinCoach',
        messages,
        requestContext: { userId: user.id, userJwt: jwt, coachContext: ctx.data, locale: String(body.locale ?? 'en') },
        onText: (t) => { answer += t; send('delta', { text: t }); },
        onAction: (a) => { actions.push(a); send('action', a); },
      });
    } catch (e) {
      console.error('mastra call failed', e instanceof Error ? e.message : e);
      await admin.from('messages').delete().eq('id', userMessageId); // do not burn the user's quota
      send('error', { error: 'coach_unavailable', message: 'The coach is unavailable right now. Please try again.' });
      return;
    }

    const finalText = answer.trim() || FALLBACK_REPLY;
    if (!answer.trim()) send('delta', { text: FALLBACK_REPLY });
    const saved = await saveAssistant(admin, user.id, finalText, {
      used: ['profile', 'scans', 'routine', 'experiments', 'streak'], actions, model: Deno.env.get('COACH_MODEL_LABEL') ?? null,
    });
    send('done', { message_id: saved, remaining: await remaining(userClient) });
  });
}));

async function saveAssistant(admin: ReturnType<typeof adminClient>, uid: string, content: string, context: Record<string, unknown>) {
  const r = await admin.from('messages').insert({ user_id: uid, role: 'assistant', content, context }).select('id').single();
  return r.data?.id ?? null;
}

async function remaining(userClient: ReturnType<typeof adminClient>) {
  const r = await userClient.rpc('coach_remaining');
  return r.data ?? null;
}
