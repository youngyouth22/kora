import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:kora/features/splash/presentation/bloc/splash_event.dart';
import 'package:kora/features/splash/presentation/bloc/splash_state.dart';

/// Bootstrapping splash screen for Kora.
///
/// Dispatches [SplashStartedEvent] to resolve session and onboarding status,
/// then notifies [AppSessionState] to trigger reactive GoRouter redirection.
class SplashScreen extends StatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({
    this.sessionState,
    this.bloc,
    super.key,
  });

  /// Injected session state to complete initialization.
  final AppSessionState? sessionState;

  /// Optional injected [SplashBloc] for testability.
  final SplashBloc? bloc;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final SplashBloc _bloc;
  late final AnimationController _rotationController;
  Timer? _statusTimer;
  int _statusIndex = 0;

  static const List<String> _loadingStatuses = [
    'Initialisation de Kora...',
    'Chargement de votre profil de peau...',
    'Synchronisation de vos analyses...',
    'Préparation de votre espace...',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? GetIt.instance<SplashBloc>();
    _bloc.add(const SplashStartedEvent());

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _statusTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!mounted) return;
      setState(() {
        _statusIndex = (_statusIndex + 1) % _loadingStatuses.length;
      });
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _rotationController.dispose();
    if (widget.bloc == null) {
      unawaited(_bloc.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>.value(
      value: _bloc,
      child: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state.status == BaseStatus.success &&
              state.bootstrapData != null) {
            final data = state.bootstrapData!;
            widget.sessionState?.completeInitialization(
              isOnboardingCompleted: data.isOnboardingCompleted,
              isAuthenticated: data.isAuthenticated,
            );
          }
        },
        builder: (context, state) {
          Widget content;
          if (state.status == BaseStatus.failure) {
            content = _buildErrorView(context, state);
          } else if (state.status == BaseStatus.success) {
            content = const SizedBox.shrink();
          } else {
            content = _buildLoadingView(context);
          }

          return Scaffold(
            backgroundColor: AppColors.scaffoldColor,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: content,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    final currentStatus = _loadingStatuses[_statusIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Center: Kora Logo surrounded by an elegant circular loader
        Semantics(
          label: 'Kora Logo avec indicateur de chargement circulaire',
          child: SizedBox(
            width: 156,
            height: 156,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated rotating loader ring around the logo
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(156, 156),
                      painter: _CircularLoaderPainter(
                        rotationAngle:
                            _rotationController.value * 2 * math.pi,
                      ),
                    );
                  },
                ),

                // Center circular container framing the Kora logo
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppGreyColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppGreyColors.shade800.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ClipOval(
                    child: Image.asset(
                      ImageResources.koraLogo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          'KORA',
                          style: AppTypography.h4Bold.copyWith(
                            color: AppPrimaryColors.shade800,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 36),

        // Brand name
        Text(
          'KORA',
          style: AppTypography.h3Bold.copyWith(
            color: AppPrimaryColors.shade800,
            letterSpacing: 6,
          ),
        ),

        const SizedBox(height: 12),

        // Loading status text underneath the logo
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Semantics(
            liveRegion: true,
            label: currentStatus,
            child: Text(
              currentStatus,
              key: ValueKey<String>(currentStatus),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMRegular.copyWith(
                color: AppGreyColors.shade800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, SplashState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 56,
          color: AppErrorColors.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'Initialization Failed',
          textAlign: TextAlign.center,
          style: AppTypography.h4Bold.copyWith(
            color: AppColors.baseColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.errorMessage ??
              'Unable to load your application state. Please try again.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMRegular.copyWith(
            color: AppGreyColors.shade800,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPrimaryColors.shade600,
              foregroundColor: AppColors.scaffoldColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _bloc.add(const SplashStartedEvent()),
            child: Text(
              'Retry',
              style: AppTypography.bodyLBold.copyWith(
                color: AppColors.scaffoldColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter rendering a smooth circular loader track and gradient arc
/// around the logo.
class _CircularLoaderPainter extends CustomPainter {
  const _CircularLoaderPainter({required this.rotationAngle});

  final double rotationAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;

    // Background track ring
    final trackPaint = Paint()
      ..color = AppPrimaryColors.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(center, radius, trackPaint);

    // Rotating gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(rotationAngle)
      ..translate(-center.dx, -center.dy);

    final sweepGradient = SweepGradient(
      colors: [
        AppPrimaryColors.shade400.withValues(alpha: 0.1),
        AppPrimaryColors.shade500,
        AppPrimaryColors.shade700,
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final arcPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.5;

    // Draw ~280 degrees arc
    canvas
      ..drawArc(
        rect,
        0,
        1.55 * math.pi,
        false,
        arcPaint,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _CircularLoaderPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle;
  }
}
