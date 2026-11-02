import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:kora/features/home/domain/entities/home_dashboard_data.dart';
import 'package:kora/features/home/home_injection.dart';
import 'package:kora/features/home/presentation/bloc/home_bloc.dart';
import 'package:kora/features/home/presentation/bloc/home_event.dart';
import 'package:kora/features/home/presentation/bloc/home_state.dart';
import 'package:kora/features/home/presentation/widgets/day_streak_bar.dart';
import 'package:kora/features/home/presentation/widgets/streak_detail_bottom_sheet.dart';

/// Main home dashboard screen conforming to C01 & S01 specifications,
/// backed by [HomeBloc] and live SQLite DAOs.
class HomePage extends StatelessWidget {
  /// Creates a [HomePage].
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sl = GetIt.instance;
    if (!sl.isRegistered<HomeBloc>()) {
      initHomeInjection(sl);
    }

    return BlocProvider<HomeBloc>(
      create: (_) => sl<HomeBloc>()..add(const HomeStarted()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _showSkinCheckinDialog(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
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
                    context.read<HomeBloc>().add(
                      const HomeSkinCheckinSubmitted(3),
                    );
                    Navigator.of(dialogContext).pop();
                  },
                ),
                const SizedBox(height: 8),
                _CheckinOptionTile(
                  label: 'Slightly Irritated / Dry',
                  icon: Icons.sentiment_neutral_rounded,
                  onTap: () {
                    context.read<HomeBloc>().add(
                      const HomeSkinCheckinSubmitted(2),
                    );
                    Navigator.of(dialogContext).pop();
                  },
                ),
                const SizedBox(height: 8),
                _CheckinOptionTile(
                  label: 'Red / Broken Out',
                  icon: Icons.sentiment_dissatisfied_rounded,
                  onTap: () {
                    context.read<HomeBloc>().add(
                      const HomeSkinCheckinSubmitted(1),
                    );
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning, \n ';
    } else if (hour >= 12 && hour < 18) {
      return 'Good afternoon, \n ';
    } else {
      return 'Good evening, \n ';
    }
  }

  List<StreakDay> _buildStreakDays(HomeDashboardData? data) {
    return DayStreakBar.buildCurrentWeekDays(
      completedDays: data?.streakDaysCompleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      floatingActionButton: _buildMascotFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final data = state.data;

            return RefreshIndicator(
              color: AppColors.primary700,
              onRefresh: () async {
                final completer = Completer<void>();
                context.read<HomeBloc>().add(const HomeRefreshed());
                unawaited(
                  Future<void>.delayed(
                    const Duration(milliseconds: 400),
                  ).then((_) => completer.complete()),
                );
                return completer.future;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, data),
                    const SizedBox(height: 16),
                    _buildStreakBar(context, data),
                    const SizedBox(height: 20),
                    _buildNextBestActionCard(context, data),
                    const SizedBox(height: 20),
                    _buildDailyPlanSection(context, data),
                    const SizedBox(height: 20),
                    _buildActiveExperimentCard(context, data),
                    const SizedBox(height: 20),
                    _buildTrendSection(context, data),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeDashboardData? data) {
    final userName = data?.userName ?? 'there';

    return Row(
      spacing: 20,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppTypography.h3Medium.copyWith(
                color: AppGreyColors.shade1050,
                height: 1.36,
                overflow: TextOverflow.ellipsis,
              ),
              children: [
                TextSpan(text: _timeGreeting()),
                TextSpan(
                  text: userName,
                  style: AppTypography.h3Medium.copyWith(
                    color: AppBadgeColors.valueIcon,
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (data != null) {
              unawaited(
                StreakDetailBottomSheet.show(
                  context,
                  currentStreak: data.currentStreak,
                  longestStreak: data.longestStreak,
                  weeklyScanStreak: data.weeklyScanStreak,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(100),
          child: Container(
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
        ),
      ],
    );
  }

  Widget _buildStreakBar(BuildContext context, HomeDashboardData? data) {
    return DayStreakBar(
      days: _buildStreakDays(data),
      onDayTap: data == null
          ? null
          : (_) {
              unawaited(
                StreakDetailBottomSheet.show(
                  context,
                  currentStreak: data.currentStreak,
                  longestStreak: data.longestStreak,
                  weeklyScanStreak: data.weeklyScanStreak,
                ),
              );
            },
    );
  }

  Widget _buildNextBestActionCard(
    BuildContext context,
    HomeDashboardData? data,
  ) {
    final hasScan = data?.hasBaselineScan ?? false;
    final isDueToday = data?.isScanDueToday ?? false;
    final daysRemaining = data?.daysUntilNextScan ?? 0;
    final timingLabel = data?.nextScanDateLabel ?? 'Upcoming scan';

    final badgeLabel = !hasScan
        ? 'START HERE'
        : (isDueToday ? 'SCAN READY' : 'UPCOMING SCAN');

    final title = !hasScan
        ? 'Take your baseline scan'
        : (isDueToday
              ? 'Your weekly scan is due today'
              : 'Next scan in $daysRemaining days');

    final subtitle = !hasScan
        ? 'Your first scan establishes your calibrated starting point.'
        : 'Weekly scans provide the most reliable trends. '
              'Keep the same spot and lighting.';

    final buttonLabel = !hasScan
        ? 'Start first scan'
        : (isDueToday ? 'Start weekly scan' : 'Preview scan guide');

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
                  badgeLabel,
                  style: AppTypography.bodyXsBold.copyWith(
                    color: AppColors.grey50,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timingLabel,
                style: AppTypography.bodyXsMedium.copyWith(
                  color: AppColors.primary900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.h5Bold.copyWith(color: AppColors.grey1050),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySRegular.copyWith(
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: buttonLabel,
            height: 48,
            backgroundColor: AppColors.primary700,
            onPressed: () async {
              final session = GetIt.instance.isRegistered<AppSessionState>()
                  ? GetIt.instance<AppSessionState>()
                  : null;
              final hasSeenGuide = session?.hasSeenScanGuide ?? false;
              final route = hasSeenGuide
                  ? AppRoutes.scanCapture
                  : AppRoutes.scanGuide;
              await context.push(route);
              if (context.mounted) {
                context.read<HomeBloc>().add(const HomeRefreshed());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPlanSection(
    BuildContext context,
    HomeDashboardData? data,
  ) {
    final completedCount = data?.completedDailyTasks ?? 0;
    final morningDone = data?.morningRoutineDone ?? false;
    final eveningDone = data?.eveningRoutineDone ?? false;
    final checkinDone = data?.skinCheckinDone ?? false;
    final tipDone = data?.dailyTipRead ?? false;

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
              '$completedCount/4 completed',
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
                subtitle: morningDone
                    ? 'Completed for today'
                    : 'Cleanse, treat, protect',
                done: morningDone,
                onTap: () => context.go(AppRoutes.buildRoutinePath('am')),
              ),
              const Divider(height: 1, color: AppColors.grey200),
              _buildTaskTile(
                title: 'Evening routine',
                subtitle: eveningDone
                    ? 'Completed for today'
                    : 'Cleanse and repair',
                done: eveningDone,
                onTap: () => context.go(AppRoutes.buildRoutinePath('pm')),
              ),
              const Divider(height: 1, color: AppColors.grey200),
              _buildTaskTile(
                title: 'Skin check-in',
                subtitle: checkinDone
                    ? 'Completed for today'
                    : '2 taps · keeps your streak',
                done: checkinDone,
                onTap: () => _showSkinCheckinDialog(context),
              ),
              const Divider(height: 1, color: AppColors.grey200),
              _buildTaskTile(
                title: 'Today’s skin tip',
                subtitle: 'Why mineral sunscreen protects sensitive skin',
                done: tipDone,
                onTap: () => context.read<HomeBloc>().add(
                  HomeDailyTipToggled(read: !tipDone),
                ),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.grey500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveExperimentCard(
    BuildContext context,
    HomeDashboardData? data,
  ) {
    final hasExperiment = data?.activeExperimentTitle != null;

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
        if (hasExperiment && data != null)
          Builder(
            builder: (context) {
              final expDay = data.activeExperimentDay ?? 1;
              final expTotal = data.activeExperimentTotalDays ?? 42;
              final targets = data.activeExperimentTargets;
              final targetsLabel = targets != null
                  ? ' · Targeting $targets'
                  : '';
              final adh = ((data.activeExperimentAdherence ?? 0.8) * 100)
                  .toInt();

              return KoraCard(
                onTap: () => context.push(
                  AppRoutes.buildExperimentPath(data.activeExperimentId ?? ''),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          data.activeExperimentTitle ?? '',
                          style: AppTypography.bodyLBold.copyWith(
                            color: AppColors.grey1050,
                          ),
                        ),
                        const Spacer(),
                        KoraDeltaPill(
                          delta: data.scoreDelta ?? 0,
                          isStable: (data.scoreDelta ?? 0).abs() < 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Day $expDay of $expTotal$targetsLabel',
                      style: AppTypography.bodySRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (expDay / expTotal).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.grey200,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adherence: $adh% (good for verdict)',
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
              );
            },
          )
        else
          KoraCard(
            onTap: () => context.push(AppRoutes.experimentNew),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary200),
                  ),
                  child: const Icon(
                    Icons.science_outlined,
                    color: AppColors.primary700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start a product experiment',
                        style: AppTypography.bodyMSemiBold.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Measure the statistical impact of your active formula',
                        style: AppTypography.bodyXsRegular.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary700,
                  size: 20,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTrendSection(BuildContext context, HomeDashboardData? data) {
    final hasScore = data?.overallScore != null;

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
                  hasScore ? '${data!.overallScore}' : '--',
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
                        if (hasScore && (data!.scoreDelta != null)) ...[
                          const SizedBox(width: 6),
                          KoraDeltaPill(delta: data.scoreDelta!),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasScore
                          ? (data?.scoreSubtitle ??
                                'Calibrated skin health tracking')
                          : 'Complete a scan to see your skin trajectory',
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
                  Positioned(
                    top: 10,
                    left: 8,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.primary300,
                    ),
                  ),
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
