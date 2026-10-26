import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';

/// Tutorial model representing an individual scan preparation or guidance step.
class TutorialStep {
  /// Creates a [TutorialStep].
  const TutorialStep({
    required this.stepNumber,
    required this.title,
    required this.buttonText,
    this.buttonBackgroundColor,
    this.buttonTextColor,
  });

  /// 1-based index displayed in the circular badge.
  final int stepNumber;

  /// Main guidance title text.
  final String title;

  /// Label shown on the action button for this step.
  final String buttonText;

  /// Optional background color override for this step's CTA button.
  final Color? buttonBackgroundColor;

  /// Optional text color override for this step's CTA button.
  final Color? buttonTextColor;
}

/// A reusable stepped tutorial sheet with dynamic intrinsic height measurement,
/// circular step badge, and smooth AnimatedSize transition between steps.
class SteppedTutorialSheet extends StatefulWidget {
  /// Creates a [SteppedTutorialSheet].
  const SteppedTutorialSheet({
    required this.steps,
    this.pageController,
    this.onPageChanged,
    this.onComplete,
    this.canPop = false,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 24),
    super.key,
  });

  /// List of tutorial steps displayed sequentially.
  final List<TutorialStep> steps;

  /// External [PageController] if synchronized with external widgets.
  final PageController? pageController;

  /// Callback when active step page changes.
  final ValueChanged<int>? onPageChanged;

  /// Callback triggered when the final step CTA is pressed.
  final VoidCallback? onComplete;

  /// Whether user can dismiss via system back gesture.
  final bool canPop;

  /// Padding applied below the stepped content around the CTA button.
  final EdgeInsetsGeometry padding;

  @override
  State<SteppedTutorialSheet> createState() => _SteppedTutorialSheetState();
}

class _SteppedTutorialSheetState extends State<SteppedTutorialSheet> {
  late final PageController _internalController;
  int _currentIndex = 0;
  final Map<int, double> _stepHeights = {};

  PageController get _effectiveController =>
      widget.pageController ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = PageController();
    if (widget.pageController != null) {
      _currentIndex = widget.pageController!.hasClients
          ? widget.pageController!.page?.round() ?? 0
          : 0;
    }
  }

  @override
  void dispose() {
    if (widget.pageController == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < widget.steps.length - 1) {
      final nextIndex = _currentIndex + 1;
      setState(() => _currentIndex = nextIndex);
      widget.onPageChanged?.call(nextIndex);
      _effectiveController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    final activeStep = widget.steps[_currentIndex];
    final fallbackHeight = MediaQuery.sizeOf(context).height * 0.28;
    final currentHeight = _stepHeights[_currentIndex] ?? fallbackHeight;

    return PopScope(
      canPop: widget.canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex > 0) {
          final previousIndex = _currentIndex - 1;
          setState(() => _currentIndex = previousIndex);
          widget.onPageChanged?.call(previousIndex);
          _effectiveController.animateToPage(
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
                controller: _effectiveController,
                itemCount: widget.steps.length,
                onPageChanged: (index) {
                  if (_currentIndex != index) {
                    setState(() => _currentIndex = index);
                    widget.onPageChanged?.call(index);
                  }
                },
                itemBuilder: (context, index) {
                  return _TutorialStepItem(
                    step: widget.steps[index],
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
            padding: widget.padding,
            child: PrimaryButton(
              key: ValueKey<int>(_currentIndex),
              text: activeStep.buttonText,
              backgroundColor: activeStep.buttonBackgroundColor,
              textColor: activeStep.buttonTextColor,
              onPressed: _onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialStepItem extends StatefulWidget {
  const _TutorialStepItem({
    required this.step,
    required this.onMeasuredHeight,
  });

  final TutorialStep step;
  final ValueChanged<double> onMeasuredHeight;

  @override
  State<_TutorialStepItem> createState() => _TutorialStepItemState();
}

class _TutorialStepItemState extends State<_TutorialStepItem> {
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final element = _contentKey.currentContext;
    if (element == null || !element.mounted) return;
    final renderBox = element.findRenderObject() as RenderBox?;
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
