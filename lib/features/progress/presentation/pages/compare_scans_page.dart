// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/primary_button.dart';

/// Side-by-side / split before-after scan comparison screen (C05 in blueprint).
class CompareScansPage extends StatefulWidget {
  /// Creates a [CompareScansPage].
  const CompareScansPage({
    this.scanAId = 'scan_1',
    this.scanBId = 'scan_4',
    super.key,
  });

  /// First scan identifier (e.g. baseline).
  final String scanAId;

  /// Second scan identifier (e.g. current).
  final String scanBId;

  @override
  State<CompareScansPage> createState() => _CompareScansPageState();
}

class _CompareScansPageState extends State<CompareScansPage> {
  double _sliderPosition = 0.5; // 0.0 to 1.0
  bool _showZonesOverlay = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Compare Scans',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mode switcher: Photo vs Zones
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToggleOption(
                    label: 'Photo',
                    isSelected: !_showZonesOverlay,
                    onTap: () => setState(() => _showZonesOverlay = false),
                  ),
                  const SizedBox(width: 8),
                  _buildToggleOption(
                    label: 'Detected Zones',
                    isSelected: _showZonesOverlay,
                    onTap: () => setState(() => _showZonesOverlay = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Interactive Before/After Split Viewer
              KoraCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 320,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final dividerX = width * _sliderPosition;

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Base After Image / Surface (Right)
                            Container(
                              color: AppColors.primary100,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _showZonesOverlay
                                        ? Icons.grain_rounded
                                        : Icons.face_rounded,
                                    size: 64,
                                    color: AppColors.primary700,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Oct 12 (After)',
                                    style: AppTypography.bodyMBold.copyWith(
                                      color: AppColors.primary900,
                                    ),
                                  ),
                                  Text(
                                    'Score: 75 (+6 pts)',
                                    style: AppTypography.bodyXsMedium.copyWith(
                                      color: AppColors.primary800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Clipped Before Image / Surface (Left)
                            ClipRect(
                              clipper: _SplitClipper(dividerX),
                              child: Container(
                                color: AppColors.neutral300,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _showZonesOverlay
                                          ? Icons.grain_rounded
                                          : Icons.face_outlined,
                                      size: 64,
                                      color: AppColors.grey700,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sep 21 (Before)',
                                      style: AppTypography.bodyMBold.copyWith(
                                        color: AppColors.grey1050,
                                      ),
                                    ),
                                    Text(
                                      'Score: 69 (Baseline)',
                                      style: AppTypography.bodyXsMedium
                                          .copyWith(
                                            color: AppColors.grey700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Draggable Vertical Divider Line and Handle
                            Positioned(
                              left: dividerX - 16,
                              top: 0,
                              bottom: 0,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onHorizontalDragUpdate: (details) {
                                  setState(() {
                                    final newPos =
                                        (details.localPosition.dx +
                                            dividerX -
                                            16) /
                                        width;
                                    _sliderPosition = newPos.clamp(0.05, 0.95);
                                  });
                                },
                                child: SizedBox(
                                  width: 32,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 2,
                                        color: AppColors.grey50,
                                      ),
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.grey50,
                                          border: Border.all(
                                            color: AppColors.grey400,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.unfold_more_rounded,
                                          size: 16,
                                          color: AppColors.grey900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Labels Overlay
                            Positioned(
                              left: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.grey50.withValues(
                                    alpha: 0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.grey300),
                                ),
                                child: Text(
                                  'BEFORE',
                                  style: AppTypography.bodyXsBold.copyWith(
                                    color: AppColors.grey900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.grey50.withValues(
                                    alpha: 0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.grey300),
                                ),
                                child: Text(
                                  'AFTER',
                                  style: AppTypography.bodyXsBold.copyWith(
                                    color: AppColors.primary800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Variations summary
              Text(
                'Evolution Summary (3 weeks)',
                style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
              ),
              const SizedBox(height: 8),
              KoraCard(
                child: Column(
                  children: [
                    _buildDeltaRow('Redness', -9, 'Calmed down significantly'),
                    const Divider(height: 16, color: AppColors.grey200),
                    _buildDeltaRow('Texture', 4, 'Smoother skin feel'),
                    const Divider(height: 16, color: AppColors.grey200),
                    _buildDeltaRow('Dark spots', 6, 'Visible fading on cheeks'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bottom Share CTA
              PrimaryButton(
                text: 'Share result',
                height: 52,
                backgroundColor: AppColors.primary700,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Comparison card ready. Privacy protected (face omitted).',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey50,
                        ),
                      ),
                      backgroundColor: AppColors.grey1000,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary700 : AppColors.grey100,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.primary700 : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: isSelected
              ? AppTypography.bodySMedium.copyWith(color: AppColors.grey50)
              : AppTypography.bodySMedium.copyWith(color: AppColors.grey800),
        ),
      ),
    );
  }

  Widget _buildDeltaRow(String label, int delta, String description) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
              Text(
                description,
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
        ),
        KoraDeltaPill(delta: delta),
      ],
    );
  }
}

class _SplitClipper extends CustomClipper<Rect> {
  const _SplitClipper(this.splitX);

  final double splitX;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, splitX, size.height);
  }

  @override
  bool shouldReclip(covariant _SplitClipper oldClipper) {
    return oldClipper.splitX != splitX;
  }
}
