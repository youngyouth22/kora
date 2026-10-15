// Deterministic safety layer for the coach: runs BEFORE any model call.
export type RedFlagKind = 'emergency' | 'crisis' | 'medical';

export interface RedFlag { kind: RedFlagKind; reply: string }

const RULES: { kind: RedFlagKind; re: RegExp }[] = [
  // Self-harm / crisis
  { kind: 'crisis', re: /\b(suicid\w*|kill myself|end my life|want to die|self[- ]?harm|hurt myself)\b/i },
  // Severe allergic reaction / chemical burn / breathing
  { kind: 'emergency', re: /\b(can'?t breathe|trouble breathing|difficulty breathing|anaphyla\w*|throat (is )?(closing|swelling)|swelling (of|in) (my )?(face|lips?|tongue|throat)|chemical burn)\b/i },
  // Skin-cancer-type signals and infection signs
  { kind: 'medical', re: /\b(melanoma|skin cancer|carcinoma)\b/i },
  { kind: 'medical', re: /\b(mole|freckle|lesion|spot|bump|growth)\b.{0,60}\b(chang\w*|grow\w*|bigger|bleed\w*|itch\w*|irregular|crust\w*|won'?t heal|painful)\b/i },
  { kind: 'medical', re: /\b(chang\w*|grow\w*|bleed\w*|itch\w*|irregular|won'?t heal)\b.{0,60}\b(mole|freckle|lesion|spot|bump|growth)\b/i },
  { kind: 'medical', re: /\b(pus|infect\w*|fever|spreading redness|open sore|bleeding)\b/i },
];

const REPLIES: Record<RedFlagKind, string> = {
  emergency:
    "This could be serious. If you have trouble breathing or swelling of your face, lips or throat, call your local emergency number now (911 in the US). " +
    "For a chemical burn, rinse with cool running water and seek urgent care. I can't assess this safely in a chat.",
  crisis:
    "I'm really sorry you're feeling this way. You deserve support from a real person right now. " +
    "If you're in the US, you can call or text 988 (Suicide & Crisis Lifeline) at any time. If you might act on these thoughts, call your local emergency number. " +
    "If you're elsewhere, please contact your local crisis line or emergency services. I'm here to talk, but please reach out to someone you trust too.",
  medical:
    "What you describe is worth having checked by a doctor or dermatologist, ideally soon. " +
    "Changes in a mole or spot, bleeding, non-healing areas, or signs of infection can't be judged from an app or a chat. " +
    "I'd rather not guess. In the meantime, I'm happy to help with your routine once you've been seen. This is general information, not medical advice.",
};

export function detectRedFlags(text: string): RedFlag | null {
  for (const r of RULES) if (r.re.test(text)) return { kind: r.kind, reply: REPLIES[r.kind] };
  return null;
}
