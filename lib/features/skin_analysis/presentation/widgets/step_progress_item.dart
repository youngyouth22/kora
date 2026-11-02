// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Step state indicator.
enum StepProgressState {
  /// Step is upcoming and has not started yet.
  pending,

  /// Step is currently running.
  active,

  /// Step has finished successfully.
  completed,
}

/// A single step row matching the screenshot design:
/// - Circular check badge on the left
/// - Step label on top
/// - Progress bar underneath
class StepProgressItem extends StatefulWidget {
  /// Creates a [StepProgressItem].
  const StepProgressItem({
    required this.title,
    required this.state,
    this.isDarkBackground = true,
    super.key,
  });

  /// Label describing the step (e.g. "Analysing scan results...").
  final String title;

  /// Progress state of this step.
  final StepProgressState state;

  /// Whether the item is rendered on a dark background (adjusts contrast).
  final bool isDarkBackground;

  @override
  State<StepProgressItem> createState() => _StepProgressItemState();
}

class _StepProgressItemState extends State<StepProgressItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _animation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    if (widget.state == StepProgressState.active) {
      _progressController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant StepProgressItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == StepProgressState.active &&
        oldWidget.state != StepProgressState.active) {
      _progressController.repeat(reverse: true);
    } else if (widget.state != StepProgressState.active &&
        oldWidget.state == StepProgressState.active) {
      _progressController.stop();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.state == StepProgressState.completed;
    final isActive = widget.state == StepProgressState.active;

    final textColor = widget.isDarkBackground
        ? AppGreyColors.white
        : AppGreyColors.shade1050;

    return Semantics(
      label:
          '${widget.title}: ${isCompleted
              ? "Completed"
              : isActive
              ? "In progress"
              : "Pending"}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildStatusIcon(isCompleted, isActive),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.title,
                  style: AppTypography.bodyLMedium.copyWith(
                    color: textColor,
                    fontWeight: isCompleted || isActive
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildProgressBar(isCompleted, isActive),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(bool isCompleted, bool isActive) {
    if (isCompleted) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppPrimaryColors.shade500,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 14,
          color: AppGreyColors.white,
        ),
      );
    }

    if (isActive) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppPrimaryColors.shade400,
            width: 2,
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppPrimaryColors.shade400,
              ),
            ),
          ),
        ),
      );
    }

    final inactiveBorderColor = widget.isDarkBackground
        ? AppGreyColors.shade600
        : AppGreyColors.shade300;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: inactiveBorderColor,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isCompleted, bool isActive) {
    final trackColor = widget.isDarkBackground
        ? AppGreyColors.white.withValues(alpha: 0.2)
        : AppGreyColors.shade200;

    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isCompleted) {
            return Container(
              height: 6,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: AppPrimaryColors.shade500,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }

          if (isActive) {
            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                // Smooth back-and-forth progress between 20% and 85%
                final fillWidth =
                    constraints.maxWidth * (0.2 + (_animation.value * 0.65));
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 6,
                    width: fillWidth,
                    decoration: BoxDecoration(
                      color: AppPrimaryColors.shade500,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
