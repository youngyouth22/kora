import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/widgets/stepped_tutorial_sheet.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/routine/presentation/widgets/product_card_preview.dart';
import 'package:kora/features/routine/presentation/widgets/viewfinder_reticle_frame.dart';

/// Stepped tutorial page guiding the user through capturing or uploading a
/// product photo.
///
/// Features:
/// - Step 1: Viewfinder with camera reticle corner brackets framing the
///   product.
/// - Step 2: Gallery product card preview with mint indicator bar and dismiss
///   action.
/// - Reusable [SteppedTutorialSheet] at the bottom with step badges and CTAs.
/// - Idempotently marks tutorial as seen in [AppSessionState].
class ProductScanTutorialPage extends StatefulWidget {
  /// Creates a [ProductScanTutorialPage].
  const ProductScanTutorialPage({
    this.sessionState,
    this.onTutorialFinished,
    super.key,
  });

  /// Optional [AppSessionState] for dependency injection or testing.
  final AppSessionState? sessionState;

  /// Optional completion callback overriding default navigation.
  final VoidCallback? onTutorialFinished;

  @override
  State<ProductScanTutorialPage> createState() =>
      _ProductScanTutorialPageState();
}

class _ProductScanTutorialPageState extends State<ProductScanTutorialPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  static const List<TutorialStep> _steps = [
    TutorialStep(
      stepNumber: 1,
      title: 'Take a picture of the\nproduct face...',
      buttonText: 'Next',
      buttonBackgroundColor: AppColors.primary100,
      buttonTextColor: AppColors.primary900,
    ),
    TutorialStep(
      stepNumber: 2,
      title: '... or upload a photo\nfrom your gallery',
      buttonText: 'Got it',
      buttonBackgroundColor: AppColors.primary500,
      buttonTextColor: AppGreyColors.white,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishTutorial() {
    final session =
        widget.sessionState ??
        (GetIt.instance.isRegistered<AppSessionState>()
            ? GetIt.instance<AppSessionState>()
            : null);
    session?.markProductScanTutorialSeen();

    if (widget.onTutorialFinished != null) {
      widget.onTutorialFinished!();
      return;
    }

    if (mounted) {
      context.pushReplacement(AppRoutes.routineLabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey1050,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar with Close button on Step 2 (and accessible on step 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: Semantics(
                  button: true,
                  label: 'Close tutorial and continue to scanner',
                  child: Material(
                    color: AppGreyColors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _finishTutorial,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.grey1050,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Visual Frame Area (Step 1 Viewfinder / Step 2 Card)
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _currentIndex == 0
                      ? const ViewfinderReticleFrame(
                          key: ValueKey('viewfinder_frame'),
                        )
                      : const ProductCardPreview(
                          key: ValueKey('product_card_preview'),
                        ),
                ),
              ),
            ),

            // Stepped Guidance Bottom Container
            Container(
              decoration: const BoxDecoration(
                color: AppGreyColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SteppedTutorialSheet(
                steps: _steps,
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                onComplete: _finishTutorial,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
