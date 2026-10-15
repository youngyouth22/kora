// Minimal assertions so tests run without network access to jsr.io
export function assert(cond: unknown, msg = 'assertion failed'): asserts cond { if (!cond) throw new Error(msg); }
export function assertEquals<T>(actual: T, expected: T, msg = ''): void {
  const a = JSON.stringify(actual), b = JSON.stringify(expected);
  if (a !== b) throw new Error(`${msg} expected ${b} got ${a}`);
}
