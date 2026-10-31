// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/di/injection.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_event.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_state.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/did_you_know_carousel.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/skin_scan_result_bottom_sheet.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/step_progress_item.dart';

/// Screen displayed while analyzing skin with blurred face background,
/// live animated step indicators, and educational cards.
class ScanAnalyzingPage extends StatelessWidget {
  /// Creates a [ScanAnalyzingPage].
  const ScanAnalyzingPage({
    required this.imagePath,
    this.useMock = false,
    super.key,
  });

  /// Path to the captured photo.
  final String imagePath;

  /// Whether to use fixture responses to conserve API credits.
  final bool useMock;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SkinAnalysisBloc>()
        ..add(
          StartSkinAnalysisEvent(
            imagePath: imagePath,
            useMock: useMock,
          ),
        ),
      child: _ScanAnalyzingView(imagePath: imagePath),
    );
  }
}

class _ScanAnalyzingView extends StatelessWidget {
  const _ScanAnalyzingView({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SkinAnalysisBloc, SkinAnalysisState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SkinAnalysisStatus.success &&
            state.result != null) {
          unawaited(
            SkinScanResultBottomSheet.show(
              context,
              result: state.result!,
              onSaveToRoutine: () {
                context.go(AppRoutes.home);
              },
            ),
          );
        } else if (state.status == SkinAnalysisStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppErrorColors.shade500,
              content: Text(
                state.errorMessage ?? 'Scan analysis failed. Please try again.',
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppGreyColors.white,
                ),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppGreyColors.shade1050,
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildBlurredBackground(imagePath),
              _buildDarkVignette(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildTopBar(context),
                      const Spacer(),
                      const DidYouKnowCarousel(),
                      const SizedBox(height: 32),
                      _buildStepsSection(state),
                      if (state.isTakingLonger) ...[
                        const SizedBox(height: 20),
                        _buildTakingLongerNotice(),
                      ],
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
              if (state.status == SkinAnalysisStatus.failure)
                _buildFailureOverlay(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlurredBackground(String path) {
    final file = File(path);
    final imageWidget = file.existsSync()
        ? Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
        : Container(color: AppGreyColors.shade1050);

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: imageWidget,
    );
  }

  Widget _buildDarkVignette() {
    return Container(
      color: AppGreyColors.shade1050.withValues(alpha: 0.72),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(
          Icons.close,
          color: AppGreyColors.white,
          size: 24,
        ),
        tooltip: 'Cancel scan',
      ),
    );
  }

  Widget _buildStepsSection(SkinAnalysisState state) {
    final stepIndex = state.currentStepIndex;
    final isDone = state.status == SkinAnalysisStatus.success;

    StepProgressState getState(int index) {
      if (isDone || stepIndex > index) return StepProgressState.completed;
      if (stepIndex == index) return StepProgressState.active;
      return StepProgressState.pending;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepProgressItem(
          title: 'Optimizing & uploading HD image...',
          state: getState(0),
        ),
        const SizedBox(height: 20),
        StepProgressItem(
          title: 'Analysing scan results...',
          state: getState(1),
        ),
        const SizedBox(height: 20),
        StepProgressItem(
          title: 'Building scan report...',
          state: getState(2),
        ),
      ],
    );
  }

  Widget _buildTakingLongerNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppGreyColors.shade1000.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppSecondaryColors.shade400.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.hourglass_top,
            size: 20,
            color: AppSecondaryColors.shade400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Taking a bit longer than usual... Your HD report is almost ready.',
              style: AppTypography.bodySRegular.copyWith(
                color: AppGreyColors.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureOverlay(BuildContext context, SkinAnalysisState state) {
    return Container(
      color: AppGreyColors.shade1050.withValues(alpha: 0.9),
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppErrorColors.shade500.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppErrorColors.shade400,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Analysis Interrupted',
              style: AppTypography.h4Bold.copyWith(
                color: AppGreyColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'We could not complete your skin analysis. Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMRegular.copyWith(
                color: AppGreyColors.shade400,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              onPressed: () {
                context.read<SkinAnalysisBloc>().add(
                  StartSkinAnalysisEvent(
                    imagePath: imagePath,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(
                'Cancel',
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppGreyColors.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
