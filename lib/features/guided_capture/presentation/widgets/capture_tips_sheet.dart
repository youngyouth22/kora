import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/widgets/custom_bottom_sheet.dart';
import 'package:kora/common/widgets/stepped_tutorial_sheet.dart';

export 'package:kora/common/widgets/stepped_tutorial_sheet.dart'
    show TutorialStep;

/// A non-dismissible, stepped tutorial bottom sheet shown before scanning
/// or triggered via the help action.
///
/// Features:
/// - 3 guidance steps in a responsive [PageView].
/// - 100% responsive dynamic height animated via [AnimatedSize].
/// - Circular step number badges.
/// - Action CTA button navigating between steps or closing the tutorial.
/// - Non-dismissible modal preventing back-gesture or barrier dismissal.
class CaptureTipsSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SteppedTutorialSheet(
      steps: steps,
      onComplete: () => Navigator.of(context).pop(),
    );
  }
}
