// ignore_for_file: document_ignores, lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/kora_scan_image.dart';
import 'package:kora/features/progress/domain/entities/progress_scan.dart';

/// Displays anatomical HD zone scores (`public.scan_concerns.zone`:
/// `forehead`, `left_cheek`, `right_cheek`, `nose`) for a specific concern.
class ConcernRegionalZoneCard extends StatelessWidget {
  /// Creates a [ConcernRegionalZoneCard].
  const ConcernRegionalZoneCard({
    required this.latestZones,
    required this.baselineZones,
    super.key,
  });

  /// Latest regional scores for the active concern.
  final List<ProgressConcernScore> latestZones;

  /// Baseline regional scores for the active concern.
  final List<ProgressConcernScore> baselineZones;

  static String _formatZoneName(String zone) {
    switch (zone.toLowerCase()) {
      case 'forehead':
        return 'Forehead (T-Zone)';
      case 'left_cheek':
        return 'Left Cheek (U-Zone)';
      case 'right_cheek':
        return 'Right Cheek (U-Zone)';
      case 'nose':
        return 'Nasal Bridge';
      default:
        return zone;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (latestZones.isEmpty) return const SizedBox.shrink();

    final baseMap = <String, double>{
      for (final b in baselineZones)
        if (b.zone != null) b.zone!: b.rawScore,
    };

    return KoraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.face_retouching_natural_outlined,
                size: 18,
                color: AppColors.primary700,
              ),
              const SizedBox(width: 8),
              Text(
                'Regional Facial Zones (HD)',
                style: AppTypography.bodyMSemiBold.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < latestZones.length; i++) ...[
            if (i > 0) const Divider(height: 18, color: AppColors.grey200),
            Builder(
              builder: (context) {
                final item = latestZones[i];
                final zoneKey = item.zone ?? '';
                final baseScore = baseMap[zoneKey] ?? item.rawScore;
                final delta = (item.rawScore - baseScore).round();
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 38,
                        height: 38,
                        child: KoraScanImage(
                          photoPath: item.maskPath,
                          showMeshOverlay: true,
                          zoneHighlight: zoneKey,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatZoneName(zoneKey),
                            style: AppTypography.bodySMedium.copyWith(
                              color: AppColors.grey1050,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Baseline ${baseScore.toStringAsFixed(1)} → Now ${item.rawScore.toStringAsFixed(1)}',
                            style: AppTypography.bodyXsRegular.copyWith(
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.rawScore.toStringAsFixed(1),
                      style: AppTypography.bodyMBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                    ),
                    const SizedBox(width: 10),
                    KoraDeltaPill(
                      delta: delta,
                      isStable: delta.abs() < 3,
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Interactive split before/after scan comparison viewer with draggable
/// divider, Scan A / Scan B selector bar, and Photo vs Detected Zones mode.
class CompareSplitViewerCard extends StatefulWidget {
  /// Creates a [CompareSplitViewerCard].
  const CompareSplitViewerCard({
    required this.scanA,
    required this.scanB,
    required this.allScans,
    required this.sliderPosition,
    required this.showZonesOverlay,
    required this.onSliderChanged,
    required this.onToggleOverlay,
    required this.onScanASelected,
    required this.onScanBSelected,
    super.key,
  });

  /// Baseline / earlier scan (`scanA`).
  final ProgressScan scanA;

  /// Follow-up / later scan (`scanB`).
  final ProgressScan scanB;

  /// All available scans to populate the selector pills.
  final List<ProgressScan> allScans;

  /// Horizontal split position (`0.05` to `0.95`).
  final double sliderPosition;

  /// Whether anatomical zone overlay mode is active.
  final bool showZonesOverlay;

  /// Callback when the user drags the split handle.
  final ValueChanged<double> onSliderChanged;

  /// Callback to switch between Photo and Detected Zones.
  final ValueChanged<bool> onToggleOverlay;

  /// Callback when a different baseline scan is selected.
  final ValueChanged<String> onScanASelected;

  /// Callback when a different follow-up scan is selected.
  final ValueChanged<String> onScanBSelected;

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _shortDate(DateTime dt) => '${_months[dt.month - 1]} ${dt.day}';

  @override
  State<CompareSplitViewerCard> createState() => _CompareSplitViewerCardState();
}

class _CompareSplitViewerCardState extends State<CompareSplitViewerCard> {
  late double _localSliderPosition;

  @override
  void initState() {
    super.initState();
    _localSliderPosition = widget.sliderPosition;
  }

  @override
  void didUpdateWidget(covariant CompareSplitViewerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.sliderPosition - _localSliderPosition).abs() > 0.05 &&
        widget.sliderPosition != oldWidget.sliderPosition) {
      _localSliderPosition = widget.sliderPosition;
    }
  }

  void _handleDrag(double localX, double totalWidth) {
    if (totalWidth <= 0) return;
    final next = (localX / totalWidth).clamp(0.04, 0.96);
    setState(() => _localSliderPosition = next);
    widget.onSliderChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scan A vs Scan B selector row
        Row(
          children: [
            Expanded(
              child: _ScanSelectorDropdown(
                label: 'BEFORE (SCAN A)',
                selectedScan: widget.scanA,
                allScans: widget.allScans,
                onSelected: widget.onScanASelected,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.grey600,
              ),
            ),
            Expanded(
              child: _ScanSelectorDropdown(
                label: 'AFTER (SCAN B)',
                selectedScan: widget.scanB,
                allScans: widget.allScans,
                onSelected: widget.onScanBSelected,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Mode switcher: Photo vs Detected Zones
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ModeTogglePill(
              label: 'Photo',
              isSelected: !widget.showZonesOverlay,
              onTap: () => widget.onToggleOverlay(false),
            ),
            const SizedBox(width: 8),
            _ModeTogglePill(
              label: 'Detected Zones',
              isSelected: widget.showZonesOverlay,
              onTap: () => widget.onToggleOverlay(true),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Interactive Split Comparison Canvas
        KoraCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 320,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final dividerX = width * _localSliderPosition;

                  return Semantics(
                    slider: true,
                    label: 'Before and After comparison slider',
                    child: GestureDetector(
                      key: const Key('compare_split_slider_gesture'),
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragDown: (details) {
                        _handleDrag(details.localPosition.dx, width);
                      },
                      onHorizontalDragStart: (details) {
                        _handleDrag(details.localPosition.dx, width);
                      },
                      onHorizontalDragUpdate: (details) {
                        _handleDrag(details.localPosition.dx, width);
                      },
                      onTapDown: (details) {
                        _handleDrag(details.localPosition.dx, width);
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Right / Base Layer: AFTER (Scan B)
                          SizedBox(
                            width: width,
                            height: 320,
                            child: KoraScanImage(
                              photoPath: widget.scanB.photoPath,
                              scanId: widget.scanB.id,
                              fallbackAsset: ImageResources.onboardingScanWeek6,
                              showMeshOverlay: widget.showZonesOverlay,
                              fit: BoxFit.cover,
                              semanticLabel:
                                  'Scan B After - ${CompareSplitViewerCard._shortDate(widget.scanB.createdAt)}',
                            ),
                          ),

                          // Left / Clipped Layer: BEFORE (Scan A)
                          ClipRect(
                            clipper: _HorizontalSplitClipper(dividerX),
                            child: SizedBox(
                              width: width,
                              height: 320,
                              child: KoraScanImage(
                                photoPath: widget.scanA.photoPath,
                                scanId: widget.scanA.id,
                                fallbackAsset:
                                    ImageResources.onboardingScanWeek1,
                                showMeshOverlay: widget.showZonesOverlay,
                                fit: BoxFit.cover,
                                semanticLabel:
                                    'Scan A Before - ${CompareSplitViewerCard._shortDate(widget.scanA.createdAt)}',
                              ),
                            ),
                          ),

                          // Draggable Vertical Divider Line & Handle
                          Positioned(
                            left: dividerX - 1,
                            top: 0,
                            bottom: 0,
                            child: IgnorePointer(
                              child: Container(
                                width: 2,
                                color: AppColors.grey50,
                              ),
                            ),
                          ),

                          Positioned(
                            left: dividerX - 18,
                            top: 142,
                            child: IgnorePointer(
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.grey50,
                                  border: Border.all(
                                    color: AppColors.primary700,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.grey1050.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.compare_arrows_rounded,
                                  size: 18,
                                  color: AppColors.primary800,
                                ),
                              ),
                            ),
                          ),

                          // Corner Badges
                          Positioned(
                            left: 12,
                            top: 12,
                            child: IgnorePointer(
                              child: _CornerBadge(
                                text:
                                    'BEFORE · ${CompareSplitViewerCard._shortDate(widget.scanA.createdAt)}',
                                textColor: AppColors.grey900,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: IgnorePointer(
                              child: _CornerBadge(
                                text:
                                    'AFTER · ${CompareSplitViewerCard._shortDate(widget.scanB.createdAt)}',
                                textColor: AppColors.primary800,
                              ),
                            ),
                          ),

                          // Bottom subtle hint pill
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 10,
                            child: Center(
                              child: IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey1050.withValues(
                                      alpha: 0.65,
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    'Drag anywhere to compare',
                                    style: AppTypography.bodyXsRegular.copyWith(
                                      color: AppColors.grey50,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanSelectorDropdown extends StatelessWidget {
  const _ScanSelectorDropdown({
    required this.label,
    required this.selectedScan,
    required this.allScans,
    required this.onSelected,
  });

  final String label;
  final ProgressScan selectedScan;
  final List<ProgressScan> allScans;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodyXsBold.copyWith(
              color: AppColors.grey700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: allScans.any((s) => s.id == selectedScan.id)
                  ? selectedScan.id
                  : (allScans.isNotEmpty ? allScans.first.id : null),
              isExpanded: true,
              isDense: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.primary700,
              ),
              items: allScans.map((s) {
                return DropdownMenuItem<String>(
                  value: s.id,
                  child: Text(
                    '${CompareSplitViewerCard._shortDate(s.createdAt)} · ${s.overallScore.toStringAsFixed(0)} pts',
                    style: AppTypography.bodySSemiBold.copyWith(
                      color: AppColors.grey1050,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onSelected(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTogglePill extends StatelessWidget {
  const _ModeTogglePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary700 : AppColors.grey50,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.primary700 : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySSemiBold.copyWith(
            color: isSelected ? AppColors.grey50 : AppColors.grey800,
          ),
        ),
      ),
    );
  }
}

class _CornerBadge extends StatelessWidget {
  const _CornerBadge({
    required this.text,
    required this.textColor,
  });

  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Text(
        text,
        style: AppTypography.bodyXsBold.copyWith(
          color: textColor,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _HorizontalSplitClipper extends CustomClipper<Rect> {
  const _HorizontalSplitClipper(this.splitX);

  final double splitX;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, splitX, size.height);

  @override
  bool shouldReclip(covariant _HorizontalSplitClipper oldClipper) {
    return oldClipper.splitX != splitX;
  }
}
