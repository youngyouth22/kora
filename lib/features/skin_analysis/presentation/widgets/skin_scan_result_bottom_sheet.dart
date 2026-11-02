// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/kora_scan_image.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/features/coach/presentation/widgets/coach_bottom_sheet.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_concern.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_report.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/profile_chip_view.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/routine_preview_card.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/skin_concern_mask_viewer.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/youcam_mask_gallery_widget.dart';

/// Comprehensive bottom sheet & page content presenting the AI Skin Analyst
/// first-scan results alongside YouCam detection mask images.
class SkinScanResultBottomSheet extends StatelessWidget {
  /// Creates a [SkinScanResultBottomSheet].
  const SkinScanResultBottomSheet({
    required this.result,
    this.onSaveToRoutine,
    this.isStandalonePage = false,
    super.key,
  });

  /// The complete skin analysis result and AI report.
  final SkinAnalysisResult result;

  /// Callback when user taps "Save to My Routine".
  final VoidCallback? onSaveToRoutine;

  /// Whether this widget is rendered as a standalone page rather than a bottom sheet.
  final bool isStandalonePage;

  /// Shows the bottom sheet in [context].
  static Future<void> show(
    BuildContext context, {
    required SkinAnalysisResult result,
    VoidCallback? onSaveToRoutine,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SkinScanResultBottomSheet(
        result: result,
        onSaveToRoutine: onSaveToRoutine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isStandalonePage) {
      return ColoredBox(
        color: AppGreyColors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: _buildContentList(context),
              ),
            ),
            _buildBottomAction(context),
          ],
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.50,
      maxChildSize: 0.97,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppGreyColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildDragHandle(),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _buildContentList(context),
                ),
              ),
              _buildBottomAction(context),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildContentList(BuildContext context) {
    final report = result.report;

    return [
      _buildHeader(report),
      const SizedBox(height: 16),
      if (report != null && report.profileChips.isNotEmpty) ...[
        _buildProfileChipsRow(report.profileChips),
        const SizedBox(height: 20),
      ],
      _buildOverallScoreCard(report),
      const SizedBox(height: 16),
      if (report?.goalValidation != null) ...[
        _buildGoalValidationCard(report!.goalValidation!),
        const SizedBox(height: 20),
      ] else ...[
        _buildSummaryMetricsRow(),
        const SizedBox(height: 20),
      ],
      _buildSectionTitle(
        title: 'Areas Needing Attention',
        subtitle: 'YouCam detection overlays and targeted care recommendations',
        badgeColor: AppSecondaryColors.shade500,
        icon: Icons.priority_high,
      ),
      const SizedBox(height: 12),
      ...result.areasNeedingAttention.asMap().entries.map(
        (entry) => _buildProblemCardWithImage(
          context: context,
          concern: entry.value,
          rank: entry.key + 1,
        ),
      ),
      if (report != null && report.regions.isNotEmpty) ...[
        const SizedBox(height: 20),
        _buildSectionTitle(
          title: 'Regional Breakdown',
          subtitle: 'Specific anatomical insights from your scan',
          badgeColor: AppPrimaryColors.shade600,
          icon: Icons.face_retouching_natural,
        ),
        const SizedBox(height: 12),
        ...report.regions.map(_buildRegionCard),
      ],
      const SizedBox(height: 28),
      _buildSectionTitle(
        title: 'Your Skin Strengths',
        subtitle: 'Celebrated resilience and healthy indicators',
        badgeColor: AppPrimaryColors.shade500,
        icon: Icons.verified,
      ),
      const SizedBox(height: 12),
      if (report != null && report.strengths.isNotEmpty)
        ...report.strengths.asMap().entries.map(
          (entry) => _buildStrengthItemCard(
            item: entry.value,
            rank: entry.key + 1,
          ),
        )
      else
        ...result.strengths.asMap().entries.map(
          (entry) => _buildLegacyStrengthCard(
            concern: entry.value,
            rank: entry.key + 1,
          ),
        ),
      if (report != null && report.routinePreview.isNotEmpty) ...[
        const SizedBox(height: 28),
        _buildSectionTitle(
          title: 'Recommended Routine',
          subtitle: 'Calibrated steps for your skin baseline',
          badgeColor: AppPrimaryColors.shade700,
          icon: Icons.checklist_rounded,
        ),
        const SizedBox(height: 12),
        ...report.routinePreview.map(
          (step) => RoutinePreviewCard(step: step),
        ),
      ],
      if (report != null && report.coachMessage.isNotEmpty) ...[
        const SizedBox(height: 20),
        _buildCoachMessageCard(context, report.coachMessage),
      ],
      if (report != null && report.safety.needsProfessionalReview) ...[
        const SizedBox(height: 20),
        _buildSafetyAlertCard(report.safety),
      ],
      const SizedBox(height: 28),
      YouCamMaskGalleryWidget(
        concerns: result.allConcerns,
        userPhotoPath: result.resizedImageUrl,
      ),
      const SizedBox(height: 28),
      _buildMedicalDisclaimer(report?.disclaimers),
      const SizedBox(height: 100),
    ];
  }

  Widget _buildDragHandle() {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: AppGreyColors.shade300,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  Widget _buildHeader(SkinReport? report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Skin Health Report',
                style: AppTypography.h3Bold.copyWith(
                  color: AppGreyColors.shade1050,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppPrimaryColors.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPrimaryColors.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 13,
                    color: AppPrimaryColors.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI Verified',
                    style: AppTypography.bodySSemiBold.copyWith(
                      color: AppPrimaryColors.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (report != null && report.headline.isNotEmpty)
          Text(
            report.headline,
            style: AppTypography.bodyLBold.copyWith(
              color: AppPrimaryColors.shade900,
            ),
          ),
        if (report != null && report.summary.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            report.summary,
            style: AppTypography.bodyMRegular.copyWith(
              color: AppGreyColors.shade700,
            ),
          ),
        ] else ...[
          const SizedBox(height: 4),
          Text(
            'Detailed HD breakdown based on 16 dermatological parameters',
            style: AppTypography.bodyMRegular.copyWith(
              color: AppGreyColors.shade700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileChipsRow(List<ProfileChip> chips) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        itemBuilder: (context, index) {
          return ProfileChipView(chip: chips[index]);
        },
      ),
    );
  }

  Widget _buildOverallScoreCard(SkinReport? report) {
    final score = report?.overall.score ?? result.overallScore;
    final scoreInt = score.round();
    final caption =
        report?.overall.caption ?? 'Your starting point, not a verdict.';
    final band = report?.overall.band;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppNeutralColors.shade500,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppNeutralColors.shade600),
      ),
      child: Row(
        children: [
          _ScoreRing(score: score),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _scoreHeadline(scoreInt),
                        style: AppTypography.h5Bold.copyWith(
                          color: AppGreyColors.shade1050,
                        ),
                      ),
                    ),
                    if (band != null) _buildBandBadge(band),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  caption,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppGreyColors.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandBadge(String band) {
    Color bg;
    Color fg;
    String label;

    switch (band.toLowerCase()) {
      case 'strength':
        bg = AppPrimaryColors.shade100;
        fg = AppPrimaryColors.shade800;
        label = 'Strength';
      case 'good':
        bg = AppPrimaryColors.shade50;
        fg = AppPrimaryColors.shade700;
        label = 'Good';
      case 'moderate':
        bg = AppSecondaryColors.shade50;
        fg = AppSecondaryColors.shade800;
        label = 'Moderate';
      case 'watch':
        bg = AppSecondaryColors.shade100;
        fg = AppSecondaryColors.shade900;
        label = 'Watch';
      case 'focus':
      default:
        bg = AppErrorColors.shade50;
        fg = AppErrorColors.shade700;
        label = 'Focus';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.bodyXsBold.copyWith(color: fg),
      ),
    );
  }

  static String _scoreHeadline(int score) {
    if (score >= 85) return 'Optimal Skin Health';
    if (score >= 70) return 'Healthy & Balanced';
    if (score >= 55) return 'Moderate Vitality';
    return 'Care Needed';
  }

  Widget _buildGoalValidationCard(GoalValidation goalValidation) {
    final percent = (goalValidation.value * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppSecondaryColors.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppSecondaryColors.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.track_changes,
                    size: 18,
                    color: AppSecondaryColors.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Goal: ${goalValidation.goal.toUpperCase()}',
                    style: AppTypography.bodyMSemiBold.copyWith(
                      color: AppSecondaryColors.shade900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppSecondaryColors.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percent% alignment',
                  style: AppTypography.bodyXsBold.copyWith(
                    color: AppSecondaryColors.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            goalValidation.explanation,
            style: AppTypography.bodySRegular.copyWith(
              color: AppGreyColors.shade800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetricsRow() {
    return Row(
      children: [
        if (result.skinType != null)
          Expanded(
            child: _buildMetricTile(
              label: 'Skin Type',
              value: result.skinType!.overallType,
              subtext: result.skinType!.tZoneType != null
                  ? 'T-Zone: ${result.skinType!.tZoneType}'
                  : null,
              icon: Icons.water_drop_outlined,
              iconColor: AppPrimaryColors.shade700,
              bgColor: AppPrimaryColors.shade50,
            ),
          ),
        if (result.skinType != null && result.skinAge != null)
          const SizedBox(width: 12),
        if (result.skinAge != null)
          Expanded(
            child: _buildMetricTile(
              label: 'Skin Age',
              value: '${result.skinAge} yrs',
              subtext: 'Estimated index',
              icon: Icons.calendar_today_outlined,
              iconColor: AppSecondaryColors.shade700,
              bgColor: AppSecondaryColors.shade50,
            ),
          ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    String? subtext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppGreyColors.shade700,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodyLSemiBold.copyWith(
                    color: AppGreyColors.shade1050,
                  ),
                ),
                if (subtext != null)
                  Text(
                    subtext,
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppGreyColors.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required Color badgeColor,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: badgeColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.h6Bold.copyWith(
                  color: AppGreyColors.shade1050,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppGreyColors.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a problem/concern card featuring its YouCam detection mask image.
  Widget _buildProblemCardWithImage({
    required BuildContext context,
    required SkinConcern concern,
    required int rank,
  }) {
    final maskUrl = concern.maskUrls.isNotEmpty ? concern.maskUrls.first : null;
    final effectivePhoto =
        (maskUrl != null &&
            maskUrl.isNotEmpty &&
            !maskUrl.startsWith('scan-masks/'))
        ? maskUrl
        : result.resizedImageUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppGreyColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppSecondaryColors.shade200),
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
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppSecondaryColors.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '#$rank',
                              style: AppTypography.bodyXsBold.copyWith(
                                color: AppSecondaryColors.shade800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          concern.displayName,
                          style: AppTypography.bodyLSemiBold.copyWith(
                            color: AppGreyColors.shade1050,
                          ),
                        ),
                      ],
                    ),
                    _buildScoreBadge(concern.rawScore.round(), true),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStars(concern.starRating),
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
          // YouCam AI Detection Mask Image / Real Scanned Face
          if (effectivePhoto != null && effectivePhoto.isNotEmpty) ...[
            Container(
              color: AppNeutralColors.shade300,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.center_focus_strong,
                            size: 14,
                            color: AppSecondaryColors.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'YouCam AI Detection Mask',
                            style: AppTypography.bodyXsBold.copyWith(
                              color: AppSecondaryColors.shade800,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          unawaited(
                            SkinConcernMaskViewer.show(
                              context,
                              imageUrl: effectivePhoto,
                              concernTitle: concern.displayName,
                              scoreText: '${concern.rawScore.round()}/100',
                              concernId: concern.id,
                            ),
                          );
                        },
                        child: Text(
                          'Pinch to Zoom',
                          style: AppTypography.bodyXsSemiBold.copyWith(
                            color: AppPrimaryColors.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label:
                        'YouCam detection overlay for ${concern.displayName}',
                    image: true,
                    child: GestureDetector(
                      onTap: () {
                        unawaited(
                          SkinConcernMaskViewer.show(
                            context,
                            imageUrl: effectivePhoto,
                            concernTitle: concern.displayName,
                            scoreText: '${concern.rawScore.round()}/100',
                            concernId: concern.id,
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          color: AppGreyColors.shade1000,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              KoraScanImage(
                                photoPath: effectivePhoto,
                                showMeshOverlay: true,
                                zoneHighlight: concern.id,
                                semanticLabel:
                                    'Detection mask for ${concern.displayName}',
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppGreyColors.shade1050.withValues(
                                      alpha: 0.75,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.zoom_in,
                                        color: AppGreyColors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Inspect HD',
                                        style: AppTypography.bodyXsMedium
                                            .copyWith(
                                              color: AppGreyColors.white,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegionCard(RegionItem region) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppGreyColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppNeutralColors.shade600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                region.title,
                style: AppTypography.bodyLSemiBold.copyWith(
                  color: AppGreyColors.shade1050,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppPrimaryColors.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  region.area.replaceAll('_', ' ').toUpperCase(),
                  style: AppTypography.bodyXsBold.copyWith(
                    color: AppPrimaryColors.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            region.observation,
            style: AppTypography.bodySRegular.copyWith(
              color: AppGreyColors.shade800,
            ),
          ),
          if (region.whyItMatters.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              region.whyItMatters,
              style: AppTypography.bodyXsRegular.copyWith(
                color: AppGreyColors.shade700,
                height: 1.3,
              ),
            ),
          ],
          if (region.suggestedFocus.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppPrimaryColors.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    size: 14,
                    color: AppPrimaryColors.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      region.suggestedFocus,
                      style: AppTypography.bodyXsMedium.copyWith(
                        color: AppPrimaryColors.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStrengthItemCard({
    required StrengthItem item,
    required int rank,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppGreyColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPrimaryColors.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppPrimaryColors.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: AppTypography.bodyXsBold.copyWith(
                      color: AppPrimaryColors.shade800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTypography.bodyLSemiBold.copyWith(
                    color: AppGreyColors.shade1050,
                  ),
                ),
              ),
              const Icon(
                Icons.check_circle,
                size: 18,
                color: AppPrimaryColors.shade600,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: AppTypography.bodySRegular.copyWith(
              color: AppGreyColors.shade800,
              height: 1.4,
            ),
          ),
          if (item.evidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: item.evidence.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppPrimaryColors.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${e.concern.replaceAll('_', ' ')}: ${e.raw.round()}',
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppPrimaryColors.shade800,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegacyStrengthCard({
    required SkinConcern concern,
    required int rank,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppGreyColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPrimaryColors.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppPrimaryColors.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: AppTypography.bodyXsBold.copyWith(
                          color: AppPrimaryColors.shade800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    concern.displayName,
                    style: AppTypography.bodyLSemiBold.copyWith(
                      color: AppGreyColors.shade1050,
                    ),
                  ),
                ],
              ),
              _buildScoreBadge(concern.rawScore.round(), false),
            ],
          ),
          const SizedBox(height: 8),
          _buildStars(concern.starRating),
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
    );
  }

  Widget _buildCoachMessageCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPrimaryColors.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPrimaryColors.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MascotIllustration(
            pose: MascotPose.success,
            size: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coach Note',
                  style: AppTypography.bodyLSemiBold.copyWith(
                    color: AppPrimaryColors.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTypography.bodySRegular.copyWith(
                    color: AppGreyColors.shade800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  button: true,
                  label: 'Ask Kora Coach about my report',
                  child: InkWell(
                    onTap: () {
                      unawaited(
                        showCoachBottomSheet<void>(
                          context,
                          initialQuestion:
                              'Can you explain my skin scan score of '
                              '${result.overallScore.round()}/100 and how to '
                              'prioritize my routine?',
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppPrimaryColors.shade100,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppPrimaryColors.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 14,
                            color: AppPrimaryColors.shade800,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ask Kora Coach',
                            style: AppTypography.bodyXsSemiBold.copyWith(
                              color: AppPrimaryColors.shade900,
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

  Widget _buildSafetyAlertCard(SafetyReport safety) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppErrorColors.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppErrorColors.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppErrorColors.shade500,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professional Review Recommended',
                  style: AppTypography.bodySSemiBold.copyWith(
                    color: AppErrorColors.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  safety.reasons.isNotEmpty ? safety.reasons.join(', ') : 'We recommend discussing your skin baseline with a certified dermatologist.',
                  style: AppTypography.bodyXsRegular.copyWith(
                    color: AppErrorColors.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(int score, bool isAttentionArea) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAttentionArea
            ? AppSecondaryColors.shade50
            : AppPrimaryColors.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$score / 100',
        style: AppTypography.bodySSemiBold.copyWith(
          color: isAttentionArea
              ? AppSecondaryColors.shade800
              : AppPrimaryColors.shade800,
        ),
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        final isFilled = index < rating;
        return Icon(
          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16,
          color: isFilled
              ? AppSecondaryColors.shade600
              : AppGreyColors.shade400,
        );
      }),
    );
  }

  Widget _buildMedicalDisclaimer(List<String>? disclaimers) {
    final text = disclaimers != null && disclaimers.isNotEmpty
        ? disclaimers.join(' ')
        : 'This is an AI-based skin analysis, not a clinical assessment or medical care. Results are for reference only; for any skin-health concerns, please consult a dermatologist.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppGreyColors.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppGreyColors.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyXsRegular.copyWith(
                color: AppGreyColors.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppGreyColors.white,
        border: Border(
          top: BorderSide(
            color: AppNeutralColors.shade400,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          text: 'Save to My Routine',
          onPressed: () {
            if (onSaveToRoutine != null) {
              onSaveToRoutine!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
    );
  }
}

/// Circular score ring painter.
class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(76, 76),
            painter: _ScoreRingPainter(progress: (score / 100).clamp(0.0, 1.0)),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.round()}',
                style: AppTypography.h5Bold.copyWith(
                  color: AppGreyColors.shade1050,
                  height: 1,
                ),
              ),
              Text(
                '/100',
                style: AppTypography.bodyXsRegular.copyWith(
                  color: AppGreyColors.shade700,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    // Track
    final trackPaint = Paint()
      ..color = AppGreyColors.shade300
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = AppPrimaryColors.shade500
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
