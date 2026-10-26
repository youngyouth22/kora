// Ambient type definitions for Deno runtime in Supabase Edge Functions.
// This allows the IDE TypeScript language server to recognize Deno globals
// without requiring a global Deno installation.

declare namespace Deno {
  interface Env {
    get(key: string): string | undefined;
    set(key: string, value: string): void;
    delete(key: string): void;
    toObject(): Record<string, string>;
    has(key: string): boolean;
  }

  const env: Env;

  interface ServeOptions {
    port?: number;
    hostname?: string;
    signal?: AbortSignal;
    onError?: (error: unknown) => Response | Promise<Response>;
    onListen?: (params: { hostname: string; port: number }) => void;
  }

  type Handler = (request: Request) => Response | Promise<Response>;

  function serve(handler: Handler): void;
  function serve(options: ServeOptions, handler: Handler): { finished: Promise<void> };

  function test(name: string, fn: () => void | Promise<void>): void;
  function test(options: { name: string; only?: boolean; ignore?: boolean }, fn: () => void | Promise<void>): void;
}
