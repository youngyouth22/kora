// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/core/router/app_routes.dart';

/// Progress timeline and calendar screen (C06 & S02 in blueprint).
class ProgressPage extends StatefulWidget {
  /// Creates a [ProgressPage].
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int _selectedSegment = 0; // 0: Overall, 1: By concern, 2: Calendar
  int _selectedRange = 0; // 0: 4 wks, 1: 12 wks, 2: All
  bool _smoothEnabled = true;

  // Selected day detail in Calendar view
  int? _selectedCalendarDay = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Skin Progress',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
        actions: [
          IconButton(
            tooltip: 'Compare Scans',
            icon: const Icon(
              Icons.compare_arrows_rounded,
              color: AppColors.primary700,
            ),
            onPressed: () =>
                context.push(AppRoutes.buildComparePath('scan_1', 'scan_2')),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSegmentControl(),
              const SizedBox(height: 16),
              if (_selectedSegment == 0) _buildOverallView(),
              if (_selectedSegment == 1) _buildByConcernView(),
              if (_selectedSegment == 2) _buildCalendarView(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentControl() {
    final segments = ['Overall', 'By concern', 'Calendar'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey300),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(segments.length, (index) {
          final isSelected = _selectedSegment == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.grey50 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: AppColors.grey300)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  segments[index],
                  style: isSelected
                      ? AppTypography.bodySMedium.copyWith(
                          color: AppColors.primary900,
                        )
                      : AppTypography.bodySRegular.copyWith(
                          color: AppColors.grey700,
                        ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOverallView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRangeAndSmoothHeader(),
        const SizedBox(height: 14),
        _buildChartCard(),
        const SizedBox(height: 20),
        Text(
          'Scan History',
          style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
        ),
        const SizedBox(height: 12),
        _buildScanListTile(
          date: 'Oct 12, 2026',
          score: 75,
          delta: 3,
          note: 'Retinol Day 12 · Good lighting',
          onTap: () => context.push(AppRoutes.buildScanResultPath('scan_4')),
        ),
        const SizedBox(height: 10),
        _buildScanListTile(
          date: 'Oct 5, 2026',
          score: 72,
          delta: 1,
          note: 'Retinol Day 5',
          onTap: () => context.push(AppRoutes.buildScanResultPath('scan_3')),
        ),
        const SizedBox(height: 10),
        _buildScanListTile(
          date: 'Sep 28, 2026',
          score: 71,
          delta: 2,
          note: 'Baseline scan 2',
          onTap: () => context.push(AppRoutes.buildScanResultPath('scan_2')),
        ),
        const SizedBox(height: 10),
        _buildScanListTile(
          date: 'Sep 21, 2026',
          score: 69,
          delta: 0,
          isStable: true,
          note: 'First baseline scan',
          onTap: () => context.push(AppRoutes.buildScanResultPath('scan_1')),
        ),
      ],
    );
  }

  Widget _buildByConcernView() {
    final concerns = [
      {'name': 'Dark spots', 'type': 'dark_spots', 'score': 64, 'delta': 4},
      {
        'name': 'Redness',
        'type': 'redness',
        'score': 71,
        'delta': 0,
        'isStable': true,
      },
      {'name': 'Pores', 'type': 'pores', 'score': 68, 'delta': 2},
      {'name': 'Texture', 'type': 'texture', 'score': 58, 'delta': -2},
      {'name': 'Hydration', 'type': 'hydration', 'score': 82, 'delta': 5},
      {
        'name': 'Wrinkles & Firmness',
        'type': 'wrinkles',
        'score': 76,
        'delta': 1,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tap any concern for detailed breakdown & ingredients',
          style: AppTypography.bodySRegular.copyWith(color: AppColors.grey700),
        ),
        const SizedBox(height: 12),
        ...concerns.map((item) {
          final name = item['name']! as String;
          final type = item['type']! as String;
          final score = item['score']! as int;
          final delta = item['delta']! as int;
          final isStable = (item['isStable'] as bool?) ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: KoraCard(
              onTap: () =>
                  context.push(AppRoutes.buildProgressConcernPath(type)),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$score',
                      style: AppTypography.bodyLBold.copyWith(
                        color: AppColors.primary900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                        Text(
                          'Score: $score/100',
                          style: AppTypography.bodyXsRegular.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  KoraDeltaPill(delta: delta, isStable: isStable),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.grey600,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCalendarView() {
    // S02 Calendar month view
    const daysInMonth = 31;
    const firstWeekday = 4; // Thursday

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KoraCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'October 2026',
                    style: AppTypography.bodyLBold.copyWith(
                      color: AppColors.grey1050,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Weekdays row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                  return SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        day,
                        style: AppTypography.bodyXsSemiBold.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              // Days grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: 35,
                itemBuilder: (context, index) {
                  final dayNumber = index - firstWeekday + 2;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final isScanDay = dayNumber == 5 || dayNumber == 12;
                  final isFreezeDay = dayNumber == 8;
                  final isActive = dayNumber <= 12 && dayNumber != 8;
                  final isSelected = _selectedCalendarDay == dayNumber;

                  var cellColor = Colors.transparent;
                  var textColor = AppColors.grey900;
                  Border? cellBorder;

                  if (isSelected) {
                    cellBorder = Border.all(
                      color: AppColors.primary700,
                      width: 2,
                    );
                  }

                  if (isScanDay) {
                    cellColor = AppColors.primary100;
                    textColor = AppColors.primary900;
                  } else if (isFreezeDay) {
                    cellColor = AppColors.secondary100;
                    textColor = AppColors.secondary900;
                  }

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCalendarDay = dayNumber),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(8),
                        border: cellBorder,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: AppTypography.bodyXsMedium.copyWith(
                              color: textColor,
                            ),
                          ),
                          if (isActive && !isScanDay)
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondary500,
                              ),
                            ),
                          if (isScanDay)
                            const Icon(
                              Icons.camera_alt,
                              size: 10,
                              color: AppColors.primary700,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem('Active day', AppColors.secondary500),
                  _buildLegendItem('Scan done', AppColors.primary700),
                  _buildLegendItem('Freeze used', AppColors.secondary300),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Day detail card
        if (_selectedCalendarDay != null)
          KoraCard(
            backgroundColor: AppColors.primary50,
            borderColor: AppColors.primary200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oct ${_selectedCalendarDay!}, 2026',
                  style: AppTypography.bodyLBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedCalendarDay == 12
                      ? 'Weekly scan completed (Score 75) + Morning & Evening routine tracked.'
                      : 'Morning & evening skincare logged · Streak preserved.',
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppColors.grey800,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        KoraCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMonthStat('18', 'Active days'),
              Container(width: 1, height: 32, color: AppColors.grey300),
              _buildMonthStat('4', 'Weekly scans'),
              Container(width: 1, height: 32, color: AppColors.grey300),
              _buildMonthStat('1', 'Freeze used'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodyXsRegular.copyWith(color: AppColors.grey700),
        ),
      ],
    );
  }

  Widget _buildMonthStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
        Text(
          label,
          style: AppTypography.bodyXsRegular.copyWith(color: AppColors.grey700),
        ),
      ],
    );
  }

  Widget _buildRangeAndSmoothHeader() {
    return Row(
      children: [
        ...List.generate(3, (index) {
          final labels = ['4 wks', '12 wks', 'All'];
          final isSelected = _selectedRange == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedRange = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary700 : AppColors.grey100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  labels[index],
                  style: AppTypography.bodyXsMedium.copyWith(
                    color: isSelected ? AppColors.grey50 : AppColors.grey800,
                  ),
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _smoothEnabled = !_smoothEnabled),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _smoothEnabled ? AppColors.primary50 : AppColors.grey100,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: _smoothEnabled
                    ? AppColors.primary300
                    : AppColors.grey300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_graph_rounded,
                  size: 14,
                  color: _smoothEnabled
                      ? AppColors.primary700
                      : AppColors.grey600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Smooth',
                  style: AppTypography.bodyXsMedium.copyWith(
                    color: _smoothEnabled
                        ? AppColors.primary900
                        : AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    return KoraCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Trajectory',
                style: AppTypography.bodyLBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const KoraDeltaPill(delta: 6),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '+6 points over 4 weeks · Retinol introduced Sep 30',
            style: AppTypography.bodyXsRegular.copyWith(
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 20),
          // Clean flat chart presentation
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: const Size(double.infinity, 140),
              painter: _TrajectoryChartPainter(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sep 21 (69)',
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              Text(
                'Sep 28 (71)',
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              Text(
                'Oct 5 (72)',
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              Text(
                'Oct 12 (75)',
                style: AppTypography.bodyXsSemiBold.copyWith(
                  color: AppColors.primary700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanListTile({
    required String date,
    required int score,
    required int delta,
    required String note,
    required VoidCallback onTap,
    bool isStable = false,
  }) {
    return KoraCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.grey300),
            ),
            child: const Icon(
              Icons.face_retouching_natural_rounded,
              color: AppColors.primary700,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey1050,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: AppTypography.bodyLBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              const SizedBox(height: 2),
              KoraDeltaPill(delta: delta, isStable: isStable),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.grey600,
          ),
        ],
      ),
    );
  }
}

class _TrajectoryChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(10, size.height * 0.75),
      Offset(size.width * 0.33, size.height * 0.60),
      Offset(size.width * 0.66, size.height * 0.50),
      Offset(size.width - 10, size.height * 0.20),
    ];

    // Horizontal guideline
    final gridPaint = Paint()
      ..color = AppColors.grey300
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      gridPaint,
    );

    // Main line
    final linePaint = Paint()
      ..color = AppColors.primary700
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Nodes
    final nodePaint = Paint()..color = AppColors.primary700;
    final whitePaint = Paint()..color = AppColors.grey50;

    for (final pt in points) {
      canvas
        ..drawCircle(pt, 6, nodePaint)
        ..drawCircle(pt, 3, whitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
