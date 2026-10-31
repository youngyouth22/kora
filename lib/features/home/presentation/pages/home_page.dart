import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/common/widgets/kora_card.dart';
import 'package:kora/common/widgets/kora_delta_pill.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/coach/presentation/widgets/coach_bottom_sheet.dart';
import 'package:kora/features/home/presentation/widgets/day_streak_bar.dart';

/// Main home dashboard screen conforming to C01 & S01 specifications.
class HomePage extends StatefulWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mock daily routine tasks states
  bool _morningRoutineDone = true;
  bool _eveningRoutineDone = false;
  bool _skinCheckinDone = false;
  bool _dailyTipRead = true;

  void _showSkinCheckinDialog() {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.grey300),
            ),
            title: Text(
              'How does your skin feel today?',
              style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CheckinOptionTile(
                  label: 'Calm & Balanced',
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  onTap: () {
                    setState(() => _skinCheckinDone = true);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _CheckinOptionTile(
                  label: 'Slightly Irritated / Dry',
                  icon: Icons.sentiment_neutral_rounded,
                  onTap: () {
                    setState(() => _skinCheckinDone = true);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _CheckinOptionTile(
                  label: 'Red / Broken Out',
                  icon: Icons.sentiment_dissatisfied_rounded,
                  onTap: () {
                    setState(() => _skinCheckinDone = true);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      floatingActionButton: _buildMascotFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary700,
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                const DayStreakBar(),
                const SizedBox(height: 20),
                _buildNextBestActionCard(context),
                const SizedBox(height: 20),
                _buildDailyPlanSection(),
                const SizedBox(height: 20),
                _buildActiveExperimentCard(context),
                const SizedBox(height: 20),
                _buildTrendSection(context),
                const SizedBox(height: 20),
                _buildEducationalSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      spacing: 20,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.h3Medium.copyWith(
                color: AppGreyColors.shade1050,
                height: 1.36,
                overflow: TextOverflow.ellipsis,
              ),
              children: [
                const TextSpan(
                  text: 'Good morning, \n ',
                ),
                TextSpan(
                  text: 'Amina',
                  style: AppTypography.h3Medium.copyWith(
                    color: AppBadgeColors.valueIcon,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppGreyColors.white,
            border: Border.all(color: AppColors.grey300),
          ),
          child: SvgPicture.asset(
            ImageResources.flameIcon,
            width: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.primary600,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextBestActionCard(BuildContext context) {
    return KoraCard(
      backgroundColor: AppColors.primary50,
      borderColor: AppColors.primary200,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary700,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UPCOMING SCAN',
                  style: AppTypography.bodyXsBold.copyWith(
                    color: AppColors.grey50,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Sunday at 6 PM',
                style: AppTypography.bodyXsMedium.copyWith(
                  color: AppColors.primary900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Next scan in 4 days',
            style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
          ),
          const SizedBox(height: 4),
          Text(
            'Weekly scans provide the most reliable trends. '
            'Keep the same spot and lighting.',
            style: AppTypography.bodySRegular.copyWith(
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Preview scan guide',
            height: 48,
            backgroundColor: AppColors.primary700,
            onPressed: () {
              final session = GetIt.instance.isRegistered<AppSessionState>()
                  ? GetIt.instance<AppSessionState>()
                  : null;
              final hasSeenGuide = session?.hasSeenScanGuide ?? false;
              if (hasSeenGuide) {
                unawaited(context.push(AppRoutes.scanCapture));
              } else {
                unawaited(context.push(AppRoutes.scanGuide));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Plan',
              style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
            ),
            Text(
              '2/4 completed',
              style: AppTypography.bodyXsMedium.copyWith(
                color: AppColors.grey700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        KoraCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildTaskTile(
                title: 'Morning routine',
                subtitle: 'Cleanse, treat, protect',
                done: _morningRoutineDone,
                onChanged: (val) => setState(() => _morningRoutineDone = val),
              ),
              const Divider(height: 1, color: AppColors.grey200),
              _buildTaskTile(
                title: 'Evening routine',
                subtitle: 'Cleanse and repair',
                done: _eveningRoutineDone,
                onChanged: (val) => setState(() => _eveningRoutineDone = val),
              ),
              const Divider(height: 1, color: AppColors.grey200),
              _buildTaskTile(
                title: 'Skin check-in',
                subtitle: _skinCheckinDone
                    ? 'Completed for today'
                    : '2 taps · keeps your streak',
                done: _skinCheckinDone,
                onChanged: (_) => _showSkinCheckinDialog(),
              ),
              const Divider(height: 1, color: AppColors.grey200),
              _buildTaskTile(
                title: 'Today’s skin tip',
                subtitle: 'Why mineral sunscreen protects sensitive skin',
                done: _dailyTipRead,
                onChanged: (val) => setState(() => _dailyTipRead = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTile({
    required String title,
    required String subtitle,
    required bool done,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!done),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.primary700 : Colors.transparent,
                border: Border.all(
                  color: done ? AppColors.primary700 : AppColors.grey400,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: done
                  ? const Icon(Icons.check, size: 14, color: AppColors.grey50)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMSemiBold.copyWith(
                      color: done ? AppColors.grey600 : AppColors.grey1050,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveExperimentCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Experiment',
              style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
            ),
            InkWell(
              onTap: () => context.push(AppRoutes.experimentNew),
              child: Text(
                '+ New',
                style: AppTypography.bodySMedium.copyWith(
                  color: AppColors.primary700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        KoraCard(
          onTap: () => context.push(AppRoutes.buildExperimentPath('1')),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Retinol test 0.3%',
                    style: AppTypography.bodyLBold.copyWith(
                      color: AppColors.grey1050,
                    ),
                  ),
                  const Spacer(),
                  const KoraDeltaPill(delta: -1, isStable: true),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Day 12 of 42 · Targeting Redness & Pores',
                style: AppTypography.bodySRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 12 / 42,
                  minHeight: 6,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary700),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Adherence: 82% (good for verdict)',
                    style: AppTypography.bodyXsMedium.copyWith(
                      color: AppColors.grey800,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Details',
                        style: AppTypography.bodyXsSemiBold.copyWith(
                          color: AppColors.primary700,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.primary700,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Skin Trajectory',
              style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
            ),
            InkWell(
              onTap: () => context.go(AppRoutes.progress),
              child: Text(
                'View all',
                style: AppTypography.bodySMedium.copyWith(
                  color: AppColors.primary700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        KoraCard(
          onTap: () => context.go(AppRoutes.progress),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '75',
                  style: AppTypography.h4Bold.copyWith(
                    color: AppColors.primary900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Overall Health',
                          style: AppTypography.bodyMSemiBold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const KoraDeltaPill(delta: 3),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hydration up +4 pts · Redness stable',
                      style: AppTypography.bodySRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEducationalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'From Skin Academy',
              style: AppTypography.h6Bold.copyWith(color: AppColors.grey1050),
            ),
            InkWell(
              onTap: () => context.push(AppRoutes.learn),
              child: Text(
                'Explore',
                style: AppTypography.bodySMedium.copyWith(
                  color: AppColors.primary700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        KoraCard(
          onTap: () => context.push(AppRoutes.buildLearnVideoPath('1')),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: const Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.primary700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to start retinol without purging',
                      style: AppTypography.bodyMSemiBold.copyWith(
                        color: AppColors.grey1050,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dr. Sam Ellis · 8 min guide',
                      style: AppTypography.bodyXsRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMascotFab(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Semantics(
        button: true,
        label: 'Open AI Skincare Companion Chat',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => unawaited(showCoachBottomSheet(context)),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppGreyColors.white,
                border: Border.all(color: AppColors.primary200, width: 1.5),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  // Top-left sparkle
                  Positioned(
                    top: 10,
                    left: 8,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.primary300,
                    ),
                  ),
                  // Bottom-right sparkle
                  Positioned(
                    bottom: 10,
                    right: 8,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 10,
                      color: AppColors.primary400,
                    ),
                  ),
                  MascotIllustration(
                    pose: MascotPose.callToAction,
                    size: 54,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckinOptionTile extends StatelessWidget {
  const _CheckinOptionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppColors.grey1050,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
