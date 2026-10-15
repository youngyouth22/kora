import { assert, assertEquals } from './_assert.ts';
import { detectRedFlags } from './safety.ts';

Deno.test('red flags: medical / emergency / crisis are caught', () => {
  assertEquals(detectRedFlags('My mole has changed shape and started to bleed')?.kind, 'medical');
  assertEquals(detectRedFlags('there is a spot on my cheek that keeps growing')?.kind, 'medical');
  assertEquals(detectRedFlags('Is this melanoma?')?.kind, 'medical');
  assertEquals(detectRedFlags('my skin has pus and I have a fever')?.kind, 'medical');
  assertEquals(detectRedFlags("I can't breathe and my lips are swelling")?.kind, 'emergency');
  assertEquals(detectRedFlags('swelling of my face after the new serum')?.kind, 'emergency');
  assertEquals(detectRedFlags('I want to kill myself')?.kind, 'crisis');
  assert(detectRedFlags('I want to kill myself')!.reply.includes('988'));
});

Deno.test('red flags: normal skincare questions are NOT flagged', () => {
  for (const q of [
    'Why did my redness go up after retinol?',
    'Can I mix vitamin C and niacinamide?',
    'My dark spots are fading, what next?',
    'How often should I exfoliate?',
    'What does SPF 50 really do?',
    'Should I add a spot treatment for my acne?',
  ]) assertEquals(detectRedFlags(q), null, q);
});
