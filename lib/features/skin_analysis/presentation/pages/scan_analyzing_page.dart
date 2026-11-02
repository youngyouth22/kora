// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/common/widgets/secondary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/di/injection.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_bloc.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_event.dart';
import 'package:kora/features/skin_analysis/presentation/bloc/skin_analysis_state.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/did_you_know_carousel.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/face_sparkle_overlay.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/skin_scan_result_bottom_sheet.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/step_progress_item.dart';

/// Screen displayed while analyzing skin with an unblurred face preview,
/// sparkling ML Kit landmark constellation overlay, and an ergonomic bottom
/// sheet showcasing step progress and educational insights.
class ScanAnalyzingPage extends StatelessWidget {
  /// Creates a [ScanAnalyzingPage].
  const ScanAnalyzingPage({
    required this.imagePath,
    this.useMock = false,
    this.bloc,
    super.key,
  });

  /// Path to the captured photo.
  final String imagePath;

  /// Whether to use fixture responses to conserve API credits.
  final bool useMock;

  /// Optional override BLoC (useful for testing).
  final SkinAnalysisBloc? bloc;

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<SkinAnalysisBloc>.value(
        value: bloc!,
        child: _ScanAnalyzingView(
          imagePath: imagePath,
          useMock: useMock,
        ),
      );
    }

    return BlocProvider(
      create: (context) => sl<SkinAnalysisBloc>()
        ..add(
          StartSkinAnalysisEvent(
            imagePath: imagePath,
            useMock: useMock,
          ),
        ),
      child: _ScanAnalyzingView(
        imagePath: imagePath,
        useMock: useMock,
      ),
    );
  }
}

class _ScanAnalyzingView extends StatelessWidget {
  const _ScanAnalyzingView({
    required this.imagePath,
    required this.useMock,
  });

  final String imagePath;
  final bool useMock;

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
              // 1. Crisp, unblurred user face photo
              _buildPhotoBackground(imagePath),

              // 2. Subtle lighting gradient vignette
              _buildSubtleVignette(),

              // 3. Shimmering star constellation on anatomical facial landmarks
              if (state.status != SkinAnalysisStatus.failure)
                FaceSparkleOverlay(imagePath: imagePath),

              // 4. Minimalist top bar with dismiss action
              _buildTopBar(context),

              // 5. Bottom sheet with loading steps or failure retry
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomSheet(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoBackground(String path) {
    final file = path.isNotEmpty ? File(path) : null;
    if (file != null && file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return const ColoredBox(
      color: AppGreyColors.shade1050,
      child: Center(
        child: Icon(
          Icons.face_retouching_natural,
          size: 72,
          color: AppPrimaryColors.shade400,
        ),
      ),
    );
  }

  Widget _buildSubtleVignette() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.22, 0.65, 1.0],
          colors: [
            AppGreyColors.shade1050.withValues(alpha: 0.5),
            Colors.transparent,
            Colors.transparent,
            AppGreyColors.shade1050.withValues(alpha: 0.35),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 12),
          child: Semantics(
            button: true,
            label: 'Cancel scan',
            child: Container(
              decoration: BoxDecoration(
                color: AppGreyColors.shade1050.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.close,
                  color: AppGreyColors.white,
                  size: 22,
                ),
                tooltip: 'Cancel scan',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, SkinAnalysisState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
      decoration: BoxDecoration(
        color: AppGreyColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppGreyColors.shade1050.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppGreyColors.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.status == SkinAnalysisStatus.failure)
              _buildFailureContent(context, state)
            else
              _buildLoadingContent(state),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent(SkinAnalysisState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAnalysisHeader(state),
        const SizedBox(height: 18),
        _buildStepsSection(state),
        const SizedBox(height: 18),
        if (state.isTakingLonger)
          _buildTakingLongerNotice()
        else
          const DidYouKnowCarousel(isDarkBackground: false),
      ],
    );
  }

  Widget _buildAnalysisHeader(SkinAnalysisState state) {
    return Row(
      children: [
        const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppPrimaryColors.shade500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dermatological Skin Analysis',
                style: AppTypography.h6Bold.copyWith(
                  color: AppGreyColors.shade1050,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getStepSubtitle(state),
                style: AppTypography.bodySRegular.copyWith(
                  color: AppGreyColors.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStepSubtitle(SkinAnalysisState state) {
    switch (state.currentStepIndex) {
      case 0:
        return 'Optimizing HD image & mapping facial contours...';
      case 1:
        return 'Analyzing skin texture, pores & concerns...';
      case 2:
        return 'Generating your comprehensive report...';
      default:
        return 'Processing your skin scan...';
    }
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
          isDarkBackground: false,
        ),
        const SizedBox(height: 16),
        StepProgressItem(
          title: 'Analysing scan results...',
          state: getState(1),
          isDarkBackground: false,
        ),
        const SizedBox(height: 16),
        StepProgressItem(
          title: 'Building scan report...',
          state: getState(2),
          isDarkBackground: false,
        ),
      ],
    );
  }

  Widget _buildTakingLongerNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppSecondaryColors.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppSecondaryColors.shade200,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.hourglass_top,
            size: 20,
            color: AppSecondaryColors.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Taking a bit longer than usual... Your HD report is almost ready.',
              style: AppTypography.bodySRegular.copyWith(
                color: AppSecondaryColors.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureContent(BuildContext context, SkinAnalysisState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppErrorColors.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 32,
              color: AppErrorColors.shade400,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Analysis Interrupted',
          textAlign: TextAlign.center,
          style: AppTypography.h5Bold.copyWith(
            color: AppGreyColors.shade1050,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          state.errorMessage ?? 'We could not complete your skin analysis. Please check your connection and try again.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySRegular.copyWith(
            color: AppGreyColors.shade700,
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: 'Try Again',
          onPressed: () {
            context.read<SkinAnalysisBloc>().add(
              StartSkinAnalysisEvent(
                imagePath: imagePath,
                useMock: useMock,
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          text: 'Retake',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
