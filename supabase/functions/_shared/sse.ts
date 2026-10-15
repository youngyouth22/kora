// Server-Sent Events helper. Events: meta | delta | action | done | error
import { corsHeaders } from './http.ts';

export type Send = (event: string, data: unknown) => void;

export function sseResponse(run: (send: Send) => Promise<void>): Response {
  const enc = new TextEncoder();
  const stream = new ReadableStream<Uint8Array>({
    async start(controller) {
      let closed = false;
      const send: Send = (event, data) => {
        if (closed) return;
        try {
          controller.enqueue(enc.encode(`event: ${event}\ndata: ${JSON.stringify(data)}\n\n`));
        } catch { closed = true; }
      };
      try {
        await run(send);
      } catch (e) {
        console.error('stream error', e instanceof Error ? e.stack : e);
        send('error', { error: 'internal_error', message: 'Something unexpected happened.' });
      } finally {
        closed = true;
        try { controller.close(); } catch { /* already closed */ }
      }
    },
    cancel() { /* client disconnected: run() keeps draining so the answer is still saved */ },
  });
  return new Response(stream, {
    headers: { ...corsHeaders, 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache, no-transform', Connection: 'keep-alive' },
  });
}
