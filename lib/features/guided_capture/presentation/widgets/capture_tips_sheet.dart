import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/custom_bottom_sheet.dart';
import 'package:kora/common/widgets/primary_button.dart';

/// Tutorial model representing an individual scan preparation step.
class TutorialStep {
  /// Creates a [TutorialStep].
  const TutorialStep({
    required this.stepNumber,
    required this.title,
    required this.buttonText,
  });

  /// 1-based index displayed in the circular badge.
  final int stepNumber;

  /// Main guidance title text.
  final String title;

  /// Label shown on the action button for this step.
  final String buttonText;
}

/// A non-dismissible, stepped tutorial bottom sheet shown before scanning
/// or triggered via the help action.
///
/// Features:
/// - 3 guidance steps in a responsive [PageView].
/// - 100% responsive dynamic height animated via [AnimatedSize].
/// - No hardcoded height values.
/// - Circular step number badges.
/// - Action CTA button navigating between steps or closing the tutorial.
/// - Non-dismissible modal preventing back-gesture or barrier dismissal.
class CaptureTipsSheet extends StatefulWidget {
  /// Creates a [CaptureTipsSheet].
  const CaptureTipsSheet({super.key});

  /// The 3 canonical tutorial steps.
  static const List<TutorialStep> steps = [
    TutorialStep(
      stepNumber: 1,
      title: 'Find an area\nwith good lighting',
      buttonText: 'Next',
    ),
    TutorialStep(
      stepNumber: 2,
      title: 'For the best results\ntake everything off,\neven make up',
      buttonText: 'Next',
    ),
    TutorialStep(
      stepNumber: 3,
      title:
          "Pull your hair back\nso it doesn't touch your face,\n"
          'and remove glasses',
      buttonText: 'Got it',
    ),
  ];

  /// Presents the tutorial bottom sheet via [showCustomModalBottomSheet].
  static Future<void> show(BuildContext context) {
    return showCustomModalBottomSheet<void>(
      context: context,
      backgroundColor: AppGreyColors.white,
      barrierColor: AppGreyColors.shade1050.withValues(alpha: 0.35),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      showDragHandle: false,
      isDismissible: false,
      enableDrag: false,
      useBlur: false,
      isScrollable: false,
      contentPadding: EdgeInsets.zero,
      content: const CaptureTipsSheet(),
    );
  }

  @override
  State<CaptureTipsSheet> createState() => _CaptureTipsSheetState();
}

class _CaptureTipsSheetState extends State<CaptureTipsSheet> {
  late final PageController _pageController;
  int _currentIndex = 0;
  final Map<int, double> _stepHeights = {};

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

  void _onNext() {
    if (_currentIndex < CaptureTipsSheet.steps.length - 1) {
      final nextIndex = _currentIndex + 1;
      setState(() => _currentIndex = nextIndex);
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStep = CaptureTipsSheet.steps[_currentIndex];
    // Responsive fallback height relative to screen height if not yet measured.
    final fallbackHeight = MediaQuery.sizeOf(context).height * 0.28;
    final currentHeight = _stepHeights[_currentIndex] ?? fallbackHeight;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex > 0) {
          final previousIndex = _currentIndex - 1;
          setState(() => _currentIndex = previousIndex);
          _pageController.animateToPage(
            previousIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            child: SizedBox(
              height: currentHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: CaptureTipsSheet.steps.length,
                onPageChanged: (index) {
                  if (_currentIndex != index) {
                    setState(() => _currentIndex = index);
                  }
                },
                itemBuilder: (context, index) {
                  return _StepContent(
                    step: CaptureTipsSheet.steps[index],
                    onMeasuredHeight: (height) {
                      if (_stepHeights[index] != height) {
                        setState(() {
                          _stepHeights[index] = height;
                        });
                      }
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: PrimaryButton(
              key: ValueKey<int>(_currentIndex),
              text: activeStep.buttonText,
              onPressed: _onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepContent extends StatefulWidget {
  const _StepContent({
    required this.step,
    required this.onMeasuredHeight,
  });

  final TutorialStep step;
  final ValueChanged<double> onMeasuredHeight;

  @override
  State<_StepContent> createState() => _StepContentState();
}

class _StepContentState extends State<_StepContent> {
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final context = _contentKey.currentContext;
    final renderBox = context?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      widget.onMeasuredHeight(renderBox.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          key: _contentKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 28),
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppGreyColors.shade1050,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${widget.step.stepNumber}',
                style: AppTypography.h4Medium.copyWith(
                  color: AppGreyColors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.step.title,
              textAlign: TextAlign.center,
              style: AppTypography.h3Medium.copyWith(
                color: AppGreyColors.shade1050,
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
