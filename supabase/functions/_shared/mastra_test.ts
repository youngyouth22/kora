import { assertEquals } from './_assert.ts';
import { readSse } from './mastra.ts';

function streamOf(chunks: string[]): ReadableStream<Uint8Array> {
  const enc = new TextEncoder();
  return new ReadableStream({ start(c) { for (const x of chunks) c.enqueue(enc.encode(x)); c.close(); } });
}

Deno.test('readSse: reassembles events split across network chunks, stops at [DONE]', async () => {
  const body = streamOf([
    'data: {"type":"text-delta","payload":{"text":"Hel',
    'lo"}}\n\ndata: {"type":"text-delta","payload":{"text":" world"}}\n\n',
    'data: {"type":"tool-result","payload":{"toolName":"suggest_action","result":{"type":"open_screen"}}}\n\n',
    'data: [DONE]\n\ndata: {"type":"text-delta","payload":{"text":"IGNORED"}}\n\n',
  ]);
  const out: string[] = [];
  for await (const c of readSse(body)) out.push(c.type + ':' + (c.payload?.text ?? c.payload?.toolName));
  assertEquals(out, ['text-delta:Hello', 'text-delta: world', 'tool-result:suggest_action']);
});

Deno.test('readSse: ignores malformed JSON and non-data lines', async () => {
  const body = streamOf(['event: ping\n\n', 'data: {not json}\n\n', 'data: {"type":"x"}\n\n']);
  const types: string[] = [];
  for await (const c of readSse(body)) types.push(c.type);
  assertEquals(types, ['x']);
});

Deno.test('streamAgent: calls the right URL/headers/body and surfaces text + suggest_action', async () => {
  let seen: { url: string; auth: string | null; body: Record<string, unknown> } | null = null;
  const server = Deno.serve({ port: 0, onListen: () => {} }, async (req) => {
    seen = { url: new URL(req.url).pathname, auth: req.headers.get('authorization'), body: await req.json() };
    const enc = new TextEncoder();
    return new Response(new ReadableStream({
      start(c) {
        c.enqueue(enc.encode('data: {"type":"text-delta","payload":{"text":"Keep "}}\n\n'));
        c.enqueue(enc.encode('data: {"type":"text-delta","payload":{"text":"going."}}\n\n'));
        c.enqueue(enc.encode('data: {"type":"tool-result","payload":{"toolName":"suggest_action","result":{"type":"start_experiment","label":"Test it"}}}\n\n'));
        c.enqueue(enc.encode('data: [DONE]\n\n'));
        c.close();
      },
    }), { headers: { 'Content-Type': 'text/event-stream' } });
  });
  const { streamAgent } = await import('./mastra.ts');
  let text = ''; const actions: unknown[] = [];
  await streamAgent({
    baseUrl: `http://localhost:${server.addr.port}/`, secret: 's3cret', agentId: 'skinCoach',
    messages: [{ role: 'user', content: 'hi' }], requestContext: { userId: 'u1' },
    onText: (t) => { text += t; }, onAction: (a) => actions.push(a),
  });
  await server.shutdown();
  assertEquals(text, 'Keep going.');
  assertEquals(actions, [{ type: 'start_experiment', label: 'Test it' }]);
  assertEquals(seen!.url, '/api/agents/skinCoach/stream');
  assertEquals(seen!.auth, 'Bearer s3cret');
  assertEquals(seen!.body, { messages: [{ role: 'user', content: 'hi' }], requestContext: { userId: 'u1' } });
});

Deno.test('streamAgent: surfaces HTTP errors and in-stream errors', async () => {
  const bad = Deno.serve({ port: 0, onListen: () => {} }, () => new Response('nope', { status: 401 }));
  const { streamAgent } = await import('./mastra.ts');
  const base = { secret: 'x', agentId: 'a', messages: [], requestContext: {}, onText: () => {}, onAction: () => {} };
  let threw = false;
  try { await streamAgent({ ...base, baseUrl: `http://localhost:${bad.addr.port}` }); } catch (e) { threw = String(e).includes('401'); }
  await bad.shutdown();
  assertEquals(threw, true, 'HTTP 401 throws');

  const err = Deno.serve({ port: 0, onListen: () => {} }, () =>
    new Response('data: {"type":"error","payload":{"error":"model down"}}\n\n', { headers: { 'Content-Type': 'text/event-stream' } }));
  threw = false;
  try { await streamAgent({ ...base, baseUrl: `http://localhost:${err.addr.port}` }); } catch (e) { threw = String(e).includes('model down'); }
  await err.shutdown();
  assertEquals(threw, true, 'in-stream error throws');
});
