import { assert, assertEquals } from './_assert.ts';
import { isUuid, timingSafeEqual } from './http.ts';

Deno.test('timingSafeEqual', async () => {
  assert(await timingSafeEqual('secret', 'secret'));
  assert(!(await timingSafeEqual('secret', 'secreT')));
  assert(!(await timingSafeEqual('secret', 'secret-longer')));
  assert(!(await timingSafeEqual('', 'x')));
});

Deno.test('isUuid', () => {
  assertEquals(isUuid('aaaaaaaa-0000-0000-0000-000000000001'), true);
  assertEquals(isUuid('../etc/passwd'), false);
  assertEquals(isUuid(42), false);
});
