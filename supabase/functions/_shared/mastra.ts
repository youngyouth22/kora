// Minimal Mastra HTTP client (no SDK: avoids a heavy npm tree and zod peer conflicts in Edge Functions).
// Protocol verified against @mastra/client-js 1.53 / @mastra/core 1.x:
//   POST {baseUrl}/api/agents/{agentId}/stream   body: { messages, requestContext }
//   response: Server-Sent Events, each "data: {json}\n\n", terminated by "data: [DONE]"
//   chunks:   { type:'text-delta', payload:{ text } }
//             { type:'tool-result', payload:{ toolName, result } }
//             { type:'error', payload:{ error } }

export interface MastraChunk {
  type: string;
  // deno-lint-ignore no-explicit-any
  payload?: any;
}

/** Splits an SSE byte stream into parsed JSON chunks; stops at [DONE]. */
export async function* readSse(body: ReadableStream<Uint8Array>): AsyncGenerator<MastraChunk> {
  const reader = body.getReader();
  const dec = new TextDecoder();
  let buf = '';
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      buf += dec.decode(value, { stream: true });
      const parts = buf.split('\n\n');
      buf = parts.pop() ?? '';
      for (const part of parts) {
        for (const line of part.split('\n')) {
          if (!line.startsWith('data:')) continue;
          const data = line.slice(5).trim();
          if (data === '[DONE]') return;
          try { yield JSON.parse(data) as MastraChunk; } catch { /* ignore malformed line */ }
        }
      }
    }
  } finally {
    try { reader.releaseLock(); } catch { /* ignore */ }
  }
}

export interface StreamAgentParams {
  baseUrl: string;
  secret: string;
  agentId: string;
  messages: { role: string; content: string }[];
  requestContext: Record<string, unknown>;
  signal?: AbortSignal;
  onText: (text: string) => void;
  onAction: (action: Record<string, unknown>) => void;
}

export async function streamAgent(p: StreamAgentParams): Promise<void> {
  const res = await fetch(`${p.baseUrl.replace(/\/$/, '')}/api/agents/${encodeURIComponent(p.agentId)}/stream`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${p.secret}`, 'Content-Type': 'application/json', Accept: 'text/event-stream' },
    body: JSON.stringify({ messages: p.messages, requestContext: p.requestContext }),
    signal: p.signal ?? AbortSignal.timeout(90_000),
  });
  if (!res.ok || !res.body) throw new Error(`Mastra responded ${res.status}: ${(await res.text()).slice(0, 200)}`);

  for await (const chunk of readSse(res.body)) {
    if (chunk.type === 'text-delta') {
      const t = chunk.payload?.text;
      if (typeof t === 'string' && t) p.onText(t);
    } else if (chunk.type === 'tool-result' && chunk.payload?.toolName === 'suggest_action') {
      const r = chunk.payload.result;
      if (r && typeof r === 'object') p.onAction(r as Record<string, unknown>);
    } else if (chunk.type === 'error') {
      throw new Error(`Mastra stream error: ${JSON.stringify(chunk.payload?.error ?? 'unknown').slice(0, 300)}`);
    }
  }
}
