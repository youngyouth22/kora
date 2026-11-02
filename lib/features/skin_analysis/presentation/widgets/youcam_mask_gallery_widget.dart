// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/kora_scan_image.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_concern.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/skin_concern_mask_viewer.dart';

enum _GalleryFilter { all, attention, strengths }

/// Modern, responsive, flat gallery widget displaying all 16 YouCam AI detection
/// masks, their chromatic heatmaps, raw scores, and inspection overlays.
class YouCamMaskGalleryWidget extends StatefulWidget {
  /// Creates a [YouCamMaskGalleryWidget].
  const YouCamMaskGalleryWidget({
    required this.concerns,
    this.userPhotoPath,
    super.key,
  });

  /// The complete list of evaluated concerns (typically 16 from YouCam AI).
  final List<SkinConcern> concerns;

  /// Optional local or remote path to the user's real scanned skin image.
  final String? userPhotoPath;

  @override
  State<YouCamMaskGalleryWidget> createState() =>
      _YouCamMaskGalleryWidgetState();
}

class _YouCamMaskGalleryWidgetState extends State<YouCamMaskGalleryWidget> {
  _GalleryFilter _filter = _GalleryFilter.all;
  int _selectedIndex = 0;

  List<SkinConcern> get _filteredConcerns {
    switch (_filter) {
      case _GalleryFilter.attention:
        return widget.concerns.where((c) => c.uiScore < 70).toList();
      case _GalleryFilter.strengths:
        return widget.concerns.where((c) => c.uiScore >= 70).toList();
      case _GalleryFilter.all:
        return widget.concerns;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.concerns.isEmpty) return const SizedBox.shrink();

    final filtered = _filteredConcerns;
    final activeList = filtered.isNotEmpty ? filtered : widget.concerns;
    final safeIndex = _selectedIndex.clamp(0, activeList.length - 1);
    final selectedConcern = activeList[safeIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        _buildChromaticLegend(),
        const SizedBox(height: 14),
        _buildFilterChips(context),
        const SizedBox(height: 14),
        _buildHeroMaskCard(context, selectedConcern),
        const SizedBox(height: 16),
        _buildConcernHorizontalChips(activeList, safeIndex),
        const SizedBox(height: 16),
        _buildResponsiveGrid(context, activeList),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppPrimaryColors.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppPrimaryColors.shade200),
              ),
              child: const Icon(
                Icons.center_focus_strong,
                color: AppPrimaryColors.shade700,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'YouCam AI Detection Maps (${widget.concerns.length})',
                style: AppTypography.h5Bold.copyWith(
                  color: AppGreyColors.shade1050,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Visual color-coded heatmaps returned by YouCam AI to track skin improvements across all 16 facial parameters.',
          style: AppTypography.bodySRegular.copyWith(
            color: AppGreyColors.shade700,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildChromaticLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppNeutralColors.shade300,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppNeutralColors.shade500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUCAM CHROMATIC SCALE',
            style: AppTypography.bodyXsBold.copyWith(
              color: AppGreyColors.shade800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendDot(
                color: AppErrorColors.shade500,
                label: 'Red / Coral: Erythema & Blemishes',
              ),
              _LegendDot(
                color: AppPrimaryColors.shade500,
                label: 'Cyan / Teal: Pores & Elastic Tension',
              ),
              _LegendDot(
                color: AppSecondaryColors.shade600,
                label: 'Amber / Gold: Texture, Wrinkles & Sebum',
              ),
              _LegendDot(
                color: Color(0xFF6B46C1),
                label: 'Indigo / Violet: Periorbital & Dark Circles',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final attentionCount = widget.concerns.where((c) => c.uiScore < 70).length;
    final strengthCount = widget.concerns.where((c) => c.uiScore >= 70).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All (${widget.concerns.length})',
            isSelected: _filter == _GalleryFilter.all,
            onTap: () => setState(() {
              _filter = _GalleryFilter.all;
              _selectedIndex = 0;
            }),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Needs Attention ($attentionCount)',
            isSelected: _filter == _GalleryFilter.attention,
            onTap: () => setState(() {
              _filter = _GalleryFilter.attention;
              _selectedIndex = 0;
            }),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Strengths ($strengthCount)',
            isSelected: _filter == _GalleryFilter.strengths,
            onTap: () => setState(() {
              _filter = _GalleryFilter.strengths;
              _selectedIndex = 0;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppPrimaryColors.shade700 : AppGreyColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppPrimaryColors.shade700
                : AppNeutralColors.shade500,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySSemiBold.copyWith(
            color: isSelected ? AppGreyColors.white : AppGreyColors.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroMaskCard(BuildContext context, SkinConcern concern) {
    final maskUrl = concern.maskUrls.isNotEmpty ? concern.maskUrls.first : null;
    final effectivePhoto =
        (maskUrl != null &&
            maskUrl.isNotEmpty &&
            !maskUrl.startsWith('scan-masks/'))
        ? maskUrl
        : widget.userPhotoPath;
    final concernColor = YouCamConcernColorHelper.getColor(concern.id);
    final colorDesc = YouCamConcernColorHelper.getColorDescription(concern.id);
    final isStrength = concern.uiScore >= 70;

    return Container(
      decoration: BoxDecoration(
        color: AppGreyColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isStrength
              ? AppPrimaryColors.shade300
              : AppSecondaryColors.shade300,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: concernColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          concern.displayName,
                          style: AppTypography.h5Bold.copyWith(
                            color: AppGreyColors.shade1050,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isStrength
                            ? AppPrimaryColors.shade50
                            : AppSecondaryColors.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isStrength
                              ? AppPrimaryColors.shade200
                              : AppSecondaryColors.shade200,
                        ),
                      ),
                      child: Text(
                        '${concern.rawScore.round()} / 100',
                        style: AppTypography.bodySSemiBold.copyWith(
                          color: isStrength
                              ? AppPrimaryColors.shade800
                              : AppSecondaryColors.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  colorDesc,
                  style: AppTypography.bodyXsSemiBold.copyWith(
                    color: AppGreyColors.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  concern.advice,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppGreyColors.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Mask viewer canvas
          Container(
            color: AppGreyColors.shade1050,
            height: 220,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                KoraScanImage(
                  photoPath: effectivePhoto,
                  fit: BoxFit.contain,
                  showMeshOverlay: true,
                  zoneHighlight: concern.id,
                  semanticLabel:
                      'YouCam detection mask for ${concern.displayName}',
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: () {
                      unawaited(
                        SkinConcernMaskViewer.show(
                          context,
                          imageUrl: effectivePhoto ?? '',
                          concernTitle: concern.displayName,
                          concernId: concern.id,
                          scoreText: '${concern.rawScore.round()}/100',
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppGreyColors.shade900,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppGreyColors.shade700),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_in,
                            color: AppGreyColors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Inspect in HD',
                            style: AppTypography.bodyXsBold.copyWith(
                              color: AppGreyColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConcernHorizontalChips(
    List<SkinConcern> concerns,
    int activeIndex,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: concerns.asMap().entries.map((entry) {
          final idx = entry.key;
          final concern = entry.value;
          final isSelected = idx == activeIndex;
          final dotColor = YouCamConcernColorHelper.getColor(concern.id);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = idx),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppPrimaryColors.shade50
                      : AppGreyColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppPrimaryColors.shade600
                        : AppNeutralColors.shade500,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      concern.displayName,
                      style: AppTypography.bodyXsSemiBold.copyWith(
                        color: isSelected
                            ? AppPrimaryColors.shade800
                            : AppGreyColors.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    List<SkinConcern> concerns,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 580;

        if (isWide) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: concerns.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
            ),
            itemBuilder: (context, index) {
              return _buildGridCard(context, concerns[index], index);
            },
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: concerns.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _buildGridCard(context, concerns[index], index);
          },
        );
      },
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    SkinConcern concern,
    int index,
  ) {
    final maskUrl = concern.maskUrls.isNotEmpty ? concern.maskUrls.first : null;
    final effectivePhoto =
        (maskUrl != null &&
            maskUrl.isNotEmpty &&
            !maskUrl.startsWith('scan-masks/'))
        ? maskUrl
        : widget.userPhotoPath;
    final dotColor = YouCamConcernColorHelper.getColor(concern.id);
    final isSelected = index == _selectedIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppPrimaryColors.shade50 : AppGreyColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppPrimaryColors.shade600
                : AppNeutralColors.shade500,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Mask thumbnail or color indicator
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppGreyColors.shade1000,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppNeutralColors.shade600),
              ),
              clipBehavior: Clip.antiAlias,
              child: KoraScanImage(
                photoPath: effectivePhoto,
                showMeshOverlay: true,
                zoneHighlight: concern.id,
                semanticLabel: concern.displayName,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          concern.displayName,
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppGreyColors.shade1050,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    YouCamConcernColorHelper.getColorDescription(concern.id),
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppGreyColors.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${concern.rawScore.round()}',
              style: AppTypography.h6Bold.copyWith(
                color: concern.uiScore >= 70
                    ? AppPrimaryColors.shade700
                    : AppSecondaryColors.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.bodyXsRegular.copyWith(
            color: AppGreyColors.shade800,
          ),
        ),
      ],
    );
  }
}
