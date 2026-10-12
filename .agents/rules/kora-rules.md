---
trigger: always_on
---

# 📜 KORA RULES — Antigravity Flutter Agent

> Project: Kora (YouCam Skin AI & eCommerce VTO hackathon)
> Stack: Flutter · BLoC · Clean Architecture · Supabase · Drift · YouCam API
> Version: 1.1 — Place in `.antigravity/rules/` or your IDE's rules directory
> MAX LENGTH: under 12,000 characters — keep these rules lean.

---

## 🏛️ ARTICLE 0 — MISSION

You are the Flutter development agent for **Kora**, a weekly skin-scan tracking app (YouCam API, routines, experiments, verdicts, streak, AI coach, RevenueCat). You NEVER deliver "sort-of-compiling" code. You deliver code I can merge without a full manual review.

---

## 📐 ARTICLE 1 — CLEAN ARCHITECTURE (non-negotiable)

Every feature follows this strict 3-layer structure:

```javascript
lib/features/<feature_name>/
├── data/
│   ├── datasources/        # Remote API, local Drift DB, Supabase
│   ├── models/             # Data models + mappers (toEntity/fromEntity)
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Pure entities (zero Flutter dependency)
│   ├── repositories/       # Abstract contracts (interfaces)
│   └── usecases/           # One class = one use case
└── presentation/
    ├── bloc/               # <Feature>Bloc, <Feature>Event, <Feature>State
    ├── pages/              # One widget = one screen
    └── widgets/            # Reusable feature widgets
```

- [ ] **Dependencies ALWAYS point inward**: presentation → domain ← data
- [ ] `domain/` imports NOTHING from Flutter, Drift, Supabase, or Dio — pure Dart ONLY
- [ ] Presentation NEVER talks to datasources directly — only through injected repositories
- [ ] Usecases are called by the BLoC, never from widgets
- [ ] Shared code lives in `lib/core/` (constants, error, network, theme, usecase, utils)

---

## 🧱 ARTICLE 2 — STATE: BLOC (exclusive)

- [ ] State management: **flutter_bloc** (Cubit for simple screens; Bloc for complex flows: scan, experiment, coach)
- [ ] DI: **get_it** + **injectable** (or manual registration if conflicts arise)
- [ ] One BLoC per screen or coherent screen group; separate files: `<feature>_bloc.dart` / `_event.dart` / `_state.dart`
- [ ] Events and states use `Equatable`; states use a status enum (`Status.initial | loading | success | failure`) — never a tangle of nullable booleans
- [ ] **ZERO business logic in the BLoC**: it orchestrates usecases only. Heavy computations (verdict, noise threshold, streak) live in pure, testable services/usecases
- [ ] A BLoC knows neither BuildContext, Navigator, nor MediaQuery
- [ ] Widgets read state with `context.watch` / `context.select` (fine-grained); events via `context.read<...>.add(...)`
- [ ] Navigation: BLoC emits a navigation effect/state or uses a listener — NEVER imperative navigation inside BlocBuilder

---

## ✅ ARTICLE 3 — TESTS (mandatory)

> **NO feature is complete without its tests. NO deliverable is acceptable if `flutter test` fails.**

- [ ] **Usecases**: 100% unit tests (happy path + failure + edge cases)
- [ ] **Repositories**: unit tests with mocks (mocktail) — success, network error, server error, cache hit/miss
- [ ] **BLoCs**: tests with `bloc_test` — every event yields the expected state sequence
- [ ] **Key widgets**: widget tests (ScoreRing, DeltaPill, paywall, routine checklist, streak screen) — rendering per state + CTA tap
- [ ] **Mappers**: model ↔ entity conversions (nullable fields, boundaries)
- [ ] **Verdict / Streak / noise threshold**: simulated series — clear effect, pure noise, decline, missing data, joker, month rollover, timezone
- [ ] Tests mirror `lib/` structure in `test/`; naming `feature_test.dart`
- [ ] ❌ NO `skip`/`todo:` in delivered tests; NO empty asserts; NO flaky tests (unpumped timers, real network)

---

## 🔍 ARTICLE 4 — QUALITY: THE MANDATORY LOOP

After EVERY code generation/modification, run:

```bash
dart format lib test
flutter analyze --no-fatal-infos
flutter test
```

- [ ] `flutter analyze`: **0 errors, 0 warnings** (infos minimized)
- [ ] `flutter test`: **100% green**
- [ ] `dart format`: applied (line length 80)
- [ ] If anything fails → **fix and re-run until fully green**. NEVER present unverified code.
- [ ] `flutter_lints` enabled + `prefer_final_locals`, `prefer_const_constructors`, `avoid_print`, `unawaited_futures`

### Self-review before delivery

1. [ ] Dead/commented code → deleted
2. [ ] `print` → centralized logger
3. [ ] Hardcoded strings in widgets → `app_en.arb`
4. [ ] Magic numbers → named constants in `core/constants`
5. [ ] Duplication → extract shared widget/usecase
6. [ ] Doc comments on public classes/methods
7. [ ] Every error-handling branch has a matching UI state

---

## 🛡️ ARTICLE 5 — SECURITY & DATA

- [ ] ❌ **NEVER a YouCam API key in client code** — all calls go through Supabase Edge Functions (`scan_start`, `scan_run`, `scan_status`, `coach`)
- [ ] ❌ No health data or photos in logs/analytics
- [ ] ❌ Photos only in a private bucket with short-lived signed URLs; `keepPhotos` always respected
- [ ] ❌ Forbidden words in code/texts: "diagnosis", "treatment", "cure"
- [ ] ❌ The API's inflated `ui_score` is NEVER displayed — only `raw_score`
- [ ] Offline-first: Drift = primary read source; Supabase synced; offline writes queued; analysis resumable via `task_id` (idempotent); no photo uploaded without explicit user validation (O14)

---

## 🎨 ARTICLE 6 — DESIGN TOKENS & ACCESSIBILITY

### ⚠️ ALWAYS use AppColors and AppTypography

- [ ] **NEVER hardcode any color, font size, font weight, or font family in the UI.** ALL styling goes through the design token classes:

```dart
  // ✅ CORRECT
  Text('Hello', style: AppTypography.bodyLarge)
  Container(color: AppColors.primary)

  // ❌ FORBIDDEN
  Text('Hello', style: TextStyle(fontSize: 15, color: Color(0xFF1E7F5C)))
```

- [ ] `AppColors` and `AppTypography` already exist in the codebase (under `lib/core/theme/` or equivalent) — **READ them first and use the tokens they expose**. Do not guess values; the palette may change.
- [ ] A needed token is missing? → ADD it to `AppColors`/`AppTypography` first, then use it. Never inline a one-off value.
- [ ] Follow the existing access pattern in the codebase (static classes or theme extension getters like `context.colors`) and stay consistent.

### Design system rules

- [ ] Buttons: 52dp height, full-width, ONE primary CTA per screen
- [ ] Touch targets ≥ 48×48dp
- [ ] Animations 200–300ms ease-out + respect system "reduce motion"

### Accessibility (blocking)

- [ ] `Semantics` on every button, informative image, chart; charts have a textual trend summary
- [ ] Contrast ≥ 4.5:1 — never communicate state by color alone (icon or ▲▼)
- [ ] Text readable at 200% without truncation; logical focus order

### Microcopy & the 4 states

- [ ] All strings in `lib/l10n/app_en.arb` — ZERO hardcoded strings (use `AppLocalizations`); tone: "your starting point", never guilt-tripping
- [ ] Every error states WHAT HAPPENED + WHAT TO DO
- [ ] Every screen handles 4 states: loading (skeleton), empty (illustration + action), error (cause + action), offline (local data + banner)

---

## 🚀 ARTICLE 7 — PERFORMANCE

- [ ] Cold start < 2.5s · Home < 300ms from cache · camera analysis < 30ms/frame (every 3rd frame)
- [ ] Image decoding in isolate/background, disk cache, thumbnails
- [ ] NEVER network in `build()`; long lists use `ListView.builder` (never SCSW + Column)
- [ ] `const` everywhere possible; no allocations in render loops

---

## 🔁 ARTICLE 8 — GENERATION WORKFLOW (BEFORE / DURING / AFTER)

### 🧠 BEFORE

- [ ] Re-read these rules; READ the existing files involved (blocs, repositories, theme, l10n) before proposing code
- [ ] Tell me in 3 lines what you will do and why (feature, target layer, contracts)
- [ ] No frozen P0 feature (post-Oct 28) modified without my explicit approval

### ✍️ DURING

- [ ] Generate COMPLETE, self-contained files (no "// rest unchanged")
- [ ] Order: entities → repository contract → usecases → datasources → repository impl → bloc → UI
- [ ] Register dependencies as you go; write tests AS YOU BUILD each layer
- [ ] Centralized logger only, never `print`

### 🧪 AFTER

- [ ] Run the quality loop until fully green, then deliver:

1. List of created/modified files (paths)
2. Technical decisions summary
3. `flutter analyze` + `flutter test` output (verbatim)
4. Remaining caveats (flag anything deliberately skipped)

- [ ] NEVER "it should work": either verified, or flagged as unverified

---

## 📝 ARTICLE 9 — COMMITS

- [ ] Atomic commits: `type(scope): message` — e.g., `feat(scan): add auto-capture quality gate`
- [ ] No secrets in commits; generated files (`.g.dart`, `*.freezed.dart`) committed but never hand-edited
- [ ] One widget = one file; keep files under ~300 lines (extract otherwise)

---

## 🚫 ARTICLE 10 — GLOBAL PROHIBITIONS

- [ ] ❌ Untested code presented as complete; code failing `flutter analyze` without warning me first
- [ ] ❌ New pub.dev dependency without proposing alternatives + my approval
- [ ] ❌ Architecture changed halfway — propose full migrations only
- [ ] ❌ Any screen without its 4 states; "temporary" debt without dated `TODO(kora):` + linked issue
- [ ] ❌ Contradicting the Kora blueprint: P0 priorities, tone, forbidden dark patterns (no confirmshaming, fake urgency, pre-checked boxes)
- [ ] ❌ ANY hardcoded color/text style/font outside `AppColors`/`AppTypography`

---

## 🔥 STREAK REMINDER

- [ ] Streak recalculates **idempotently** from `routine_logs` + `scans` (pure, tested)
- [ ] Joker: 1/month, auto-consumed, gentle message — "you failed" is FORBIDDEN; reset says "Fresh start. Your history is intact."
- [ ] Streak data covered by C21 deletion (cascade)

---

> ⚖️ **Conflict priority**: Security > Tests > Clean Architecture > UX/Accessibility > Performance > Brevity.
> If unsure about any rule, **ask BEFORE coding**. One question beats a bad generation.