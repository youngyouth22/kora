// ignore_for_file: document_ignores, lines_longer_than_80_chars, prefer_int_literals

import 'package:kora/features/progress/domain/entities/progress_models.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';

/// Provides SQL-aligned seed data matching `supabase/migrations/`:
/// - `20261012000000_skinproof_init.sql` (`seed_demo_data`, `concern_types`,
///   `scans`, `scan_concerns`, `experiments`, `experiment_scans`,
///   `activity_days`, `streak_state`, `milestones`)
/// - `20261014000000_skinproof_celebrations.sql` (`seen_at` tracking).
abstract final class ProgressSqlSeedDataSource {
  /// Default demo user UUID matching `RoutineSqlSeedDataSource.defaultUserId`.
  static const String defaultUserId = 'demo-user-amina';

  /// Reference date used for deterministic seed generation when none is passed.
  static final DateTime defaultReferenceDate = DateTime(2026, 10, 30, 18);

  /// Reference `public.concern_types` rows (`is_headline` true for 1..6,
  /// false for 7..12).
  static List<ProgressConcernType> buildConcernTypes() {
    return const [
      ProgressConcernType(
        key: 'age_spot',
        label: 'Dark spots',
        isHeadline: true,
        sortOrder: 3,
        description: 'Reflects melanin cluster uniformity and post-blemish hyperpigmentation across the cheeks and forehead. Higher scores indicate a more even, spot-free tone.',
        recommendedActives: [
          (
            name: 'Retinol 0.3%',
            role: 'Accelerates epidermal turnover to disperse surface pigment clusters.',
          ),
          (
            name: 'L-Ascorbic Acid 15% (Vitamin C)',
            role: 'Inhibits tyrosinase activity and shields against UV-induced darkening.',
          ),
          (
            name: 'Azelaic Acid 10%',
            role: 'Targets hyperactive melanocytes gently without barrier irritation.',
          ),
        ],
        relatedVideoId: '2',
        relatedVideoTitle:
            'The truth about dark spot treatments (Azelaic, Vit C & Retinoids)',
      ),
      ProgressConcernType(
        key: 'redness',
        label: 'Redness',
        isHeadline: true,
        sortOrder: 2,
        description: 'Measures visible capillary reactivity and surface erythema. Maintaining a stable redness score while introducing retinoids confirms your skin barrier is respected.',
        recommendedActives: [
          (
            name: 'Houttuynia Cordata 77%',
            role: 'Soothes neurogenic sensitivity and calms reactive zones.',
          ),
          (
            name: 'Panthenol (Vitamin B5)',
            role: 'Supports stratum corneum recovery and reduces transepidermal water loss.',
          ),
          (
            name: 'Ceramides NP, AP, EOP',
            role: 'Replenishes intercellular lipid mortar to prevent stinging.',
          ),
        ],
        relatedVideoId: '4',
        relatedVideoTitle: 'Skin barrier repair: The exact 3-step routine',
      ),
      ProgressConcernType(
        key: 'texture',
        label: 'Texture',
        isHeadline: true,
        sortOrder: 4,
        description: 'Evaluates micro-relief smoothness and corneocyte cohesion. Smoother surface geometry scatters light evenly and improves product absorption.',
        recommendedActives: [
          (
            name: 'Retinol 0.3%',
            role: 'Refines stratum corneum compactness over a 6-week cycle.',
          ),
          (
            name: 'Salicylic Acid (BHA 2%)',
            role: 'Dissolves lipid congestion inside uneven surface pores.',
          ),
          (
            name: 'Squalane',
            role: 'Softens dry micro-flakes without clogging follicles.',
          ),
        ],
        relatedVideoId: '1',
        relatedVideoTitle: 'How to start Retinol without purging',
      ),
      ProgressConcernType(
        key: 'pore',
        label: 'Pores',
        isHeadline: true,
        sortOrder: 5,
        description: 'Tracks the apparent diameter and optical depth of T-zone and cheek follicles. Hydrated surrounding tissue and clear sebum channels make pores appear smaller.',
        recommendedActives: [
          (
            name: 'Niacinamide 5%',
            role: 'Regulates sebum output and supports perifollicular elasticity.',
          ),
          (
            name: 'Salicylic Acid 2%',
            role: 'Keeps follicular walls clear of oxidized sebum plugs.',
          ),
        ],
        relatedVideoId: '1',
        relatedVideoTitle: 'How to start Retinol without purging',
      ),
      ProgressConcernType(
        key: 'moisture',
        label: 'Hydration',
        isHeadline: true,
        sortOrder: 6,
        description: 'Reflects optical plumpness and water retention in the upper epidermis. Well-hydrated skin buffers active ingredients and minimizes fine dehydration lines.',
        recommendedActives: [
          (
            name: 'Hyaluronic Acid + Glycerin',
            role:
                'Draws and binds ambient moisture into the superficial layers.',
          ),
          (
            name: 'Ceramides & Squalane',
            role:
                'Seals hydration in overnight to prevent moisture evaporation.',
          ),
        ],
        relatedVideoId: '4',
        relatedVideoTitle: 'Skin barrier repair: The exact 3-step routine',
      ),
      ProgressConcernType(
        key: 'acne',
        label: 'Acne',
        isHeadline: true,
        sortOrder: 1,
        description: 'Quantifies active blemishes, papules, and congested comedones. Higher scores indicate clearer, calmer skin with fewer active breakouts.',
        recommendedActives: [
          (
            name: 'Salicylic Acid 2%',
            role: 'Lipophilic exfoliant that clears congested follicles.',
          ),
          (
            name: 'Azelaic Acid 10%',
            role: 'Reduces blemish redness and post-breakout marks simultaneously.',
          ),
        ],
        relatedVideoId: '1',
        relatedVideoTitle: 'How to start Retinol without purging',
      ),
      ProgressConcernType(
        key: 'wrinkle',
        label: 'Wrinkles',
        isHeadline: false,
        sortOrder: 7,
        description: 'Measures fine expression lines and crease depth around the forehead, eyes, and nasolabial zone.',
        recommendedActives: [
          (
            name: 'Retinol 0.3%',
            role: 'Supports structural collagen renewal over 8 to 12 weeks.',
          ),
          (
            name: 'Broad Spectrum SPF 50+',
            role: 'Prevents UVA-driven elastin and collagen breakdown.',
          ),
        ],
        relatedVideoId: '3',
        relatedVideoTitle: 'SPF explained: Chemical vs Mineral UV filters',
      ),
      ProgressConcernType(
        key: 'firmness',
        label: 'Firmness',
        isHeadline: false,
        sortOrder: 8,
        description: 'Assesses contour resilience and structural bounce across the lower face and jawline.',
        recommendedActives: [
          (
            name: 'Multi-Peptides',
            role: 'Signals extracellular matrix support for firmer-looking contours.',
          ),
          (
            name: 'L-Ascorbic Acid 15%',
            role: 'Essential cofactor for natural collagen synthesis.',
          ),
        ],
        relatedVideoId: '3',
        relatedVideoTitle: 'SPF explained: Chemical vs Mineral UV filters',
      ),
      ProgressConcernType(
        key: 'radiance',
        label: 'Radiance',
        isHeadline: false,
        sortOrder: 9,
        description: 'Captures surface luminosity and light reflection across the cheekbones and forehead.',
        recommendedActives: [
          (
            name: 'Vitamin C + Ferulic Acid',
            role: 'Neutralizes dullness caused by daily oxidative stress.',
          ),
        ],
        relatedVideoId: '2',
        relatedVideoTitle:
            'The truth about dark spot treatments (Azelaic, Vit C & Retinoids)',
      ),
      ProgressConcernType(
        key: 'oiliness',
        label: 'Oiliness',
        isHeadline: false,
        sortOrder: 10,
        description:
            'Tracks surface sebum shine balance between the T-zone and U-zone.',
        recommendedActives: [
          (
            name: 'Zinc PCA & Niacinamide',
            role: 'Balances daytime sebum production without stripping.',
          ),
        ],
        relatedVideoId: '4',
        relatedVideoTitle: 'Skin barrier repair: The exact 3-step routine',
      ),
      ProgressConcernType(
        key: 'dark_circle_v2',
        label: 'Dark circles',
        isHeadline: false,
        sortOrder: 11,
        description: 'Evaluates periorbital pigment and vascular shadow contrast beneath the eyes.',
        recommendedActives: [
          (
            name: 'Caffeine + Vitamin K Oxide',
            role: 'Supports microcirculation in the delicate under-eye area.',
          ),
        ],
        relatedVideoId: '2',
        relatedVideoTitle:
            'The truth about dark spot treatments (Azelaic, Vit C & Retinoids)',
      ),
      ProgressConcernType(
        key: 'eye_bag',
        label: 'Eye bags',
        isHeadline: false,
        sortOrder: 12,
        description: 'Measures under-eye puffiness and fluid retention along the orbital rim.',
        recommendedActives: [
          (
            name: 'Peptides & Cool Compress',
            role: 'Reduces morning fluid stagnation and supports orbital tone.',
          ),
        ],
        relatedVideoId: '4',
        relatedVideoTitle: 'Skin barrier repair: The exact 3-step routine',
      ),
    ];
  }

  /// Builds the 8 weekly demo scans (`scan_1` oldest at -49 days to `scan_8`
  /// latest at 0 days) matching `seed_demo_data()` in
  /// `20261012000000_skinproof_init.sql`.
  ///
  /// Returns scans ordered newest first (`scan_8` .. `scan_1`).
  static List<ProgressScan> buildSeedScans({
    String userId = defaultUserId,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? defaultReferenceDate;
    const offsets = <int>[49, 42, 35, 28, 21, 14, 7, 0];

    // Deterministic progression curves matching SQL `seed_demo_data`:
    // ('age_spot', 58.0, 2.4), ('redness', 71.0, 0.1), ('texture', 58.0, 0.6),
    // ('pore', 60.0, 0.05), ('moisture', 66.0, 0.5), ('acne', 78.0, 0.3)
    // Plus secondary concerns for full 12-concern coverage.
    const specs =
        <({String key, double base, double gain, List<double> jitter})>[
          (
            key: 'age_spot',
            base: 58.0,
            gain: 2.4,
            jitter: [-0.4, 0.4, -0.2, 0.4, 0.0, 0.4, -0.2, 0.6],
          ),
          (
            key: 'redness',
            base: 71.0,
            gain: 0.15,
            jitter: [0.0, -0.4, -0.6, 0.2, 0.4, 0.0, 0.2, 0.4],
          ),
          (
            key: 'texture',
            base: 58.0,
            gain: 1.1,
            jitter: [-0.2, 0.2, 0.0, 0.4, 0.2, 0.6, 0.4, 0.8],
          ),
          (
            key: 'pore',
            base: 60.0,
            gain: 0.45,
            jitter: [0.0, 0.2, -0.2, 0.2, 0.4, 0.2, 0.4, 0.5],
          ),
          (
            key: 'moisture',
            base: 66.0,
            gain: 1.2,
            jitter: [-0.4, 0.0, 0.4, 0.2, 0.6, 0.4, 0.8, 1.0],
          ),
          (
            key: 'acne',
            base: 78.0,
            gain: 0.6,
            jitter: [0.0, 0.4, -0.2, 0.4, 0.2, 0.6, 0.4, 0.8],
          ),
          (
            key: 'wrinkle',
            base: 72.0,
            gain: 0.5,
            jitter: [0.0, 0.2, 0.0, 0.2, 0.4, 0.2, 0.4, 0.5],
          ),
          (
            key: 'firmness',
            base: 74.0,
            gain: 0.4,
            jitter: [0.0, 0.0, 0.2, 0.2, 0.4, 0.4, 0.4, 0.6],
          ),
          (
            key: 'radiance',
            base: 64.0,
            gain: 1.5,
            jitter: [-0.2, 0.2, 0.4, 0.6, 0.4, 0.8, 0.6, 1.0],
          ),
          (
            key: 'oiliness',
            base: 69.0,
            gain: 0.3,
            jitter: [0.0, -0.2, 0.2, 0.0, 0.2, 0.4, 0.2, 0.4],
          ),
          (
            key: 'dark_circle_v2',
            base: 65.0,
            gain: 0.4,
            jitter: [0.0, 0.2, 0.0, 0.2, 0.2, 0.4, 0.4, 0.6],
          ),
          (
            key: 'eye_bag',
            base: 73.0,
            gain: 0.3,
            jitter: [0.0, 0.0, 0.2, 0.2, 0.2, 0.4, 0.4, 0.4],
          ),
        ];

    const notes = <String>[
      'Baseline 1 · Initial calibration scan',
      'Baseline 2 · Retinol 0.3% experiment started',
      'Week 1 follow-up · Barrier calm, zero flaking',
      'Week 2 follow-up · Added C-Glow 15% AM serum',
      'Week 3 follow-up · Cheek pigment starting to lift',
      'Week 4 follow-up · 4-week weekly scan milestone',
      'Week 5 follow-up · Surface texture noticeably smoother',
      'Week 6 final checkpoint · Visible effect verdict unlocked',
    ];

    final scans = <ProgressScan>[];

    for (var idx = 0; idx < 8; idx++) {
      final scanNumber = idx + 1;
      final scanId = 'scan_$scanNumber';
      final ts = now.subtract(Duration(days: offsets[idx]));
      final effectiveSteps = idx > 1 ? idx - 1 : 0;

      final concernScores = <ProgressConcernScore>[];
      var headlineSum = 0.0;
      var headlineCount = 0;

      for (final spec in specs) {
        final raw = spec.base + spec.gain * effectiveSteps + spec.jitter[idx];
        final clamped = double.parse(raw.clamp(0.0, 100.0).toStringAsFixed(1));

        if (headlineCount < 6) {
          headlineSum += clamped;
          headlineCount++;
        }

        concernScores.add(
          ProgressConcernScore(
            id: '${scanId}_${spec.key}_whole',
            scanId: scanId,
            userId: userId,
            concernKey: spec.key,
            rawScore: clamped,
            uiScore: (clamped + 5).clamp(0.0, 100.0),
            maskPath: 'scan-masks/$userId/$scanId/${spec.key}.png',
          ),
        );

        // Add anatomical HD zones (`forehead`, `left_cheek`, `right_cheek`, `nose`)
        // for the 6 headline concerns to support regional inspection & comparison.
        if (headlineCount <= 6) {
          final zones = <({String zone, double offset})>[
            (zone: 'forehead', offset: 2.0),
            (zone: 'left_cheek', offset: -2.5),
            (zone: 'right_cheek', offset: -1.5),
            (zone: 'nose', offset: 1.0),
          ];
          for (final z in zones) {
            final zScore = double.parse(
              (clamped + z.offset).clamp(0.0, 100.0).toStringAsFixed(1),
            );
            concernScores.add(
              ProgressConcernScore(
                id: '${scanId}_${spec.key}_${z.zone}',
                scanId: scanId,
                userId: userId,
                concernKey: spec.key,
                zone: z.zone,
                rawScore: zScore,
              ),
            );
          }
        }
      }

      final overall = double.parse(
        (headlineSum / headlineCount).toStringAsFixed(1),
      );

      scans.add(
        ProgressScan(
          id: scanId,
          userId: userId,
          status: 'done',
          mode: 'HD',
          overallScore: overall,
          skinAge: 36 - (idx ~/ 3),
          qualityOk: true,
          qualityFlags: const {
            'lighting': 'optimal',
            'angle': 'centered',
            'sharpness': 0.96,
          },
          photoPath: 'scan-photos/$userId/$scanId.jpg',
          isDemo: true,
          createdAt: ts,
          completedAt: ts.add(const Duration(seconds: 18)),
          concerns: concernScores,
          note: notes[idx],
          experimentRole: idx <= 1 ? 'baseline' : 'followup',
        ),
      );
    }

    return scans.reversed.toList();
  }

  /// Builds `public.streak_state` aligned with `seed_demo_data()`.
  static ProgressStreakState buildSeedStreakState({
    String userId = defaultUserId,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? defaultReferenceDate;
    final today = DateTime(now.year, now.month, now.day);
    final weekday = today.weekday;
    final monday = today.subtract(Duration(days: weekday - 1));

    return ProgressStreakState(
      userId: userId,
      currentStreak: 14,
      longestStreak: 19,
      lastActiveDate: today,
      freezesAvailable: 2,
      freezesUsedTotal: 1,
      weeklyScanStreak: 8,
      longestWeeklyScanStreak: 8,
      lastScanWeek: monday,
      weeklyJokerAvailable: true,
    );
  }

  /// Builds `public.milestones` aligned with `seed_demo_data()` and
  /// `20261014000000_skinproof_celebrations.sql`.
  static List<ProgressMilestone> buildSeedMilestones({
    String userId = defaultUserId,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? defaultReferenceDate;
    return [
      ProgressMilestone(
        userId: userId,
        type: 'first_scan',
        title: 'First Baseline Scan',
        subtitle: 'Completed your calibrated starting point',
        reachedAt: now.subtract(const Duration(days: 49)),
        seenAt: now.subtract(const Duration(days: 49)),
      ),
      ProgressMilestone(
        userId: userId,
        type: 'second_scan',
        title: 'Dual Baseline Locked',
        subtitle: '2 weekly scans recorded for noise-filtered comparisons',
        reachedAt: now.subtract(const Duration(days: 42)),
        seenAt: now.subtract(const Duration(days: 42)),
      ),
      ProgressMilestone(
        userId: userId,
        type: 'streak_7',
        title: '7-Day Routine Streak',
        subtitle: 'Earned +1 Streak Freeze for consistent care',
        reachedAt: now.subtract(const Duration(days: 35)),
        seenAt: now.subtract(const Duration(days: 35)),
        meta: const {'days': 7},
      ),
      ProgressMilestone(
        userId: userId,
        type: 'weekly_streak_4',
        title: '4-Week Scan Consistency',
        subtitle: '1 full month of weekly skin tracking',
        reachedAt: now.subtract(const Duration(days: 21)),
        seenAt: now.subtract(const Duration(days: 21)),
        meta: const {'weeks': 4},
      ),
      ProgressMilestone(
        userId: userId,
        type: 'streak_14',
        title: '14-Day Barrier Discipline',
        subtitle: 'Two consecutive weeks of AM & PM adherence',
        reachedAt: now.subtract(const Duration(days: 7)),
        seenAt: now.subtract(const Duration(days: 7)),
        meta: const {'days': 14},
      ),
      ProgressMilestone(
        userId: userId,
        type: 'first_verdict',
        title: 'First Scientific Verdict',
        subtitle: 'Completed a 6-week controlled product test',
        reachedAt: now,
        seenAt: now,
      ),
    ];
  }

  /// Builds `public.experiments` + `compute_experiment_verdict()` aligned with
  /// `seed_demo_data()` in `20261012000000_skinproof_init.sql`.
  static List<ProgressExperiment> buildSeedExperiments({
    String userId = defaultUserId,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? defaultReferenceDate;
    final startedAt = now.subtract(const Duration(days: 42));
    final startedOn = DateTime(startedAt.year, startedAt.month, startedAt.day);

    return [
      ProgressExperiment(
        id: 'exp-retinol-demo',
        userId: userId,
        itemId: 'item-ordinary-retinol',
        title: 'Retinol 0.3% Emulsion',
        brand: 'The Ordinary',
        targets: const ['age_spot', 'texture'],
        plannedDays: 42,
        startedAt: startedAt,
        startedOn: startedOn,
        endedAt: now,
        status: 'completed',
        adherence: 0.86,
        baselineScanIds: const ['scan_1', 'scan_2'],
        followupScanIds: const [
          'scan_3',
          'scan_4',
          'scan_5',
          'scan_6',
          'scan_7',
          'scan_8',
        ],
        verdictTargets: const [
          ProgressVerdictTarget(
            concernKey: 'age_spot',
            concernLabel: 'Dark spots',
            baseline: 58.0,
            post: 70.1,
            delta: 12.1,
            noise: 3.0,
            verdict: 'visible_effect',
            confidence: 'high',
            scansAfter: 6,
            adherence: 0.86,
            qualityRatio: 1.0,
          ),
          ProgressVerdictTarget(
            concernKey: 'texture',
            concernLabel: 'Texture',
            baseline: 58.0,
            post: 64.1,
            delta: 6.1,
            noise: 3.0,
            verdict: 'visible_effect',
            confidence: 'high',
            scansAfter: 6,
            adherence: 0.86,
            qualityRatio: 1.0,
          ),
        ],
        notes: const [
          'Applied 4 nights/week buffered over Avène Tolerance cream.',
          'Zero retinoid uglies or redness spikes observed across 6 weekly scans.',
        ],
      ),
      ProgressExperiment(
        id: 'exp-vitc-active',
        userId: userId,
        itemId: 'item-geek-vitc',
        title: 'C-Glow 15% Vitamin C Serum',
        brand: 'Geek & Gorgeous',
        targets: const ['radiance', 'age_spot'],
        plannedDays: 42,
        startedAt: now.subtract(const Duration(days: 28)),
        startedOn: DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 28)),
        status: 'active',
        adherence: 0.92,
        baselineScanIds: const ['scan_3', 'scan_4'],
        followupScanIds: const ['scan_5', 'scan_6', 'scan_7', 'scan_8'],
        verdictTargets: const [
          ProgressVerdictTarget(
            concernKey: 'radiance',
            concernLabel: 'Radiance',
            baseline: 66.6,
            post: 72.7,
            delta: 6.1,
            noise: 3.0,
            verdict: 'visible_effect',
            confidence: 'medium',
            scansAfter: 4,
            adherence: 0.92,
            qualityRatio: 1.0,
          ),
          ProgressVerdictTarget(
            concernKey: 'age_spot',
            concernLabel: 'Dark spots',
            baseline: 61.7,
            post: 70.1,
            delta: 8.4,
            noise: 3.0,
            verdict: 'visible_effect',
            confidence: 'medium',
            scansAfter: 4,
            adherence: 0.92,
            qualityRatio: 1.0,
          ),
        ],
        notes: const [
          'Morning application before Anthelios UVMune 400 SPF 50+.',
        ],
      ),
    ];
  }

  /// Builds `public.activity_days` for a requested [month] (`calendar_month`
  /// RPC in SQL).
  static List<ProgressActivityDay> buildCalendarMonth({
    required DateTime month,
    String userId = defaultUserId,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? defaultReferenceDate;
    final scans = buildSeedScans(userId: userId, referenceDate: now);

    final firstDay = DateTime(month.year, month.month);
    final nextMonth = DateTime(month.year, month.month + 1);
    final daysInMonth = nextMonth.difference(firstDay).inDays;

    // Map scan dates by day-of-month if in the same year & month
    final scansByDay = <int, ProgressScan>{};
    for (final s in scans) {
      if (s.createdAt.year == month.year && s.createdAt.month == month.month) {
        scansByDay[s.createdAt.day] = s;
      }
    }

    final result = <ProgressActivityDay>[];
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      if (date.isAfter(now)) continue;

      final diffFromNow = now.difference(date).inDays;
      if (diffFromNow > 52) continue;

      final scan = scansByDay[d];
      final isFreeze = d == 8 && month.month == now.month;
      final isMissed = d == 19 && month.month == now.month && scan == null;

      if (isMissed) continue;

      if (isFreeze) {
        result.add(
          ProgressActivityDay(
            userId: userId,
            day: date,
            isFreeze: true,
            summaryNote: 'Streak Freeze auto-applied · Your 14-day streak stayed intact.',
          ),
        );
        continue;
      }

      final hadScan = scan != null;
      final hadCheckin = d.isEven || hadScan;
      final actions = (hadScan ? 1 : 0) + 2 + (hadCheckin ? 1 : 0);

      result.add(
        ProgressActivityDay(
          userId: userId,
          day: date,
          actions: actions,
          hadScan: hadScan,
          hadRoutine: true,
          hadTask: true,
          hadCheckin: hadCheckin,
          scanId: scan?.id,
          scanScore: scan?.overallScore,
          summaryNote: hadScan
              ? 'Weekly HD Scan completed (Score ${scan.overallScore.toStringAsFixed(1)}) + AM/PM routine logged.'
              : 'Morning & evening skincare protocol logged · Barrier feel calm.',
        ),
      );
    }

    return result;
  }
}
