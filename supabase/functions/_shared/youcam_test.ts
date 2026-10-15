import { assert, assertEquals } from './_assert.ts';
import { mapYoucamError, parseSkinResults } from './youcam.ts';

Deno.test('parseSkinResults: SD json output with masks, overall fallback, hd_ prefix', () => {
  const r = parseSkinResults({
    results: { output: [
      { type: 'acne', ui_score: 82, raw_score: 74.2, mask_urls: ['https://x/acne.png'] },
      { type: 'redness', ui_score: 90, raw_score: 71, mask_urls: [] },
      { type: 'hd_pore', region: 'forehead', ui_score: 70, raw_score: 61, mask_urls: ['https://x/p.png'] },
      { type: 'texture', raw_score: 'not-a-number' },
      { type: '' },
    ] },
  });
  assertEquals(r.concerns.length, 3);
  assertEquals(r.concerns[0], { concern: 'acne', zone: null, raw_score: 74.2, ui_score: 82, mask_url: 'https://x/acne.png' });
  assertEquals(r.concerns[1].mask_url, null);
  assertEquals(r.concerns[2].concern, 'pore');
  assertEquals(r.concerns[2].zone, 'forehead');
  assertEquals(r.overall, 72.6, 'overall = mean of whole-face raw scores');
  assertEquals(r.skinAge, null);
});

Deno.test('parseSkinResults: explicit overall + skin_age entries win over the fallback', () => {
  const r = parseSkinResults({ results: { output: [
    { type: 'all', score: 66, raw_score: 66 }, { type: 'skin_age', raw_score: 31 }, { type: 'acne', raw_score: 80 },
  ] } });
  assertEquals(r.overall, 66);
  assertEquals(r.skinAge, 31);
  assertEquals(r.concerns.length, 1);
});

Deno.test('parseSkinResults: tolerates empty / unexpected shapes', () => {
  assertEquals(parseSkinResults({}).concerns.length, 0);
  assertEquals(parseSkinResults(null).overall, null);
  assertEquals(parseSkinResults({ results: { output: 'nope' } }).concerns.length, 0);
});

Deno.test('mapYoucamError: documented codes map to actionable messages', () => {
  assert(mapYoucamError('error_lighting_dark').message.startsWith('Too dark'));
  assert(mapYoucamError('error_src_face_too_small').retake);
  assert(mapYoucamError('error_src_face_out_of_bound').retake);
  assert(mapYoucamError('error_below_min_image_size').message.includes('too small'));
  assert(mapYoucamError('error_no_face').retake);
  assertEquals(mapYoucamError('error_internal').retake, false);
  assert(mapYoucamError('error_internal').message.includes("won't be charged"));
});
