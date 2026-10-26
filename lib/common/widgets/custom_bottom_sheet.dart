import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Shows an adaptive modal bottom sheet adhering to the Kora design system.
///
/// Unlike fixed-height sheets, this sheet dynamically wraps its [content]
/// height, while enforcing a maximum constraint ([maxHeightFactor] or
/// [maxHeight]) to avoid viewport overflows on smaller devices.
///
/// Key features:
/// - **Self-sizing / Wrap-content**: Adapts directly to intrinsic height.
/// - **Keyboard-aware**: Automatically adjusts its bottom padding when a
///   virtual keyboard appears ([MediaQueryData.viewInsets]).
/// - **Safe area compliant**: Protects bottom edge from home indicators.
/// - **Optional blur backdrop**: Applies a frosted blur behind the route.
/// - **Optional title**: Does not render a title/divider unless provided.
/// - **Accessible drag handle**: Displays a polished top drag indicator.
Future<T?> showCustomModalBottomSheet<T>({
  required BuildContext context,
  required Widget content,
  String? title,
  Color? titleColor,
  TextStyle? titleStyle,
  Color? backgroundColor,
  Color? barrierColor,
  Color? dragHandleColor,
  bool showDragHandle = true,
  bool enableDrag = true,
  bool isDismissible = true,
  bool useBlur = true,
  double blurSigma = 3.0,
  double? height,
  double? maxHeight,
  double maxHeightFactor = 0.9,
  BorderRadiusGeometry? borderRadius,
  EdgeInsetsGeometry? contentPadding,
  bool isScrollable = true,
  bool useRootNavigator = true,
}) {
  Widget modalWidget = CustomBottomSheetContent(
    content: content,
    title: title,
    titleColor: titleColor,
    titleStyle: titleStyle,
    backgroundColor: backgroundColor,
    dragHandleColor: dragHandleColor,
    showDragHandle: showDragHandle,
    height: height,
    maxHeight: maxHeight,
    maxHeightFactor: maxHeightFactor,
    borderRadius: borderRadius,
    contentPadding: contentPadding,
    isScrollable: isScrollable,
  );

  if (useBlur) {
    modalWidget = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: modalWidget,
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor ?? AppColors.baseColor.withValues(alpha: 0.6),
    builder: (context) => modalWidget,
  );
}

/// The reusable container and layout for modal bottom sheets in Kora.
class CustomBottomSheetContent extends StatelessWidget {
  /// Creates a [CustomBottomSheetContent].
  const CustomBottomSheetContent({
    required this.content,
    super.key,
    this.title,
    this.titleColor,
    this.titleStyle,
    this.backgroundColor,
    this.dragHandleColor,
    this.showDragHandle = true,
    this.height,
    this.maxHeight,
    this.maxHeightFactor = 0.9,
    this.borderRadius,
    this.contentPadding,
    this.isScrollable = true,
  });

  /// The main widget content displayed within the bottom sheet.
  final Widget content;

  /// Optional title displayed at the top of the sheet.
  /// If null, no title or divider is rendered.
  final String? title;

  /// Color override for the [title].
  final Color? titleColor;

  /// TextStyle override for the [title]. Defaults to [AppTypography.h4Bold].
  final TextStyle? titleStyle;

  /// Surface background color. Defaults to [AppColors.scaffoldColor].
  final Color? backgroundColor;

  /// Drag handle pill color override.
  final Color? dragHandleColor;

  /// Whether to render the drag indicator pill at the top. Defaults to true.
  final bool showDragHandle;

  /// Explicit height constraint for the sheet. When set, the sheet takes
  /// this exact height instead of wrapping content.
  final double? height;

  /// Explicit maximum height constraint. Overrides [maxHeightFactor].
  final double? maxHeight;

  /// Proportional maximum height relative to viewport height (0.0 to 1.0).
  /// Defaults to 0.9 (90% of screen height).
  final double maxHeightFactor;

  /// Border radius override for top corners. Defaults to 24dp rounded corners.
  final BorderRadiusGeometry? borderRadius;

  /// Inner padding applied around [content].
  final EdgeInsetsGeometry? contentPadding;

  /// Whether the content column is wrapped in a [SingleChildScrollView].
  /// Defaults to true. Set to false if [content] already handles scrolling.
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final calculatedMaxHeight =
        height ?? maxHeight ?? (mediaQuery.size.height * maxHeightFactor);
    final effectiveBorderRadius =
        borderRadius ?? const BorderRadius.vertical(top: Radius.circular(24));
    final effectiveBgColor = backgroundColor ?? AppColors.scaffoldColor;
    final isExplicitFill = height != null && !isScrollable;

    final effectiveContent = isExplicitFill
        ? Expanded(child: content)
        : content;

    final children = <Widget>[
      if (showDragHandle)
        Semantics(
          label: 'Drag handle',
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              height: 4,
              width: 36,
              decoration: BoxDecoration(
                color:
                    dragHandleColor ??
                    AppGreyColors.shade600.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      if (title != null) ...[
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 16,
          ),
          child: Text(
            title!,
            textAlign: TextAlign.center,
            style: (titleStyle ?? AppTypography.h4Bold).copyWith(
              color: titleColor ?? AppGreyColors.shade1050,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(
            color: AppColors.neutral600,
            thickness: 1,
            height: 1,
          ),
        ),
      ],
      if (contentPadding != null) ...[
        if (isExplicitFill)
          Expanded(
            child: Padding(
              padding: contentPadding!,
              child: content,
            ),
          )
        else
          Padding(
            padding: contentPadding!,
            child: effectiveContent,
          ),
      ] else
        effectiveContent,
    ];

    final body = Column(
      mainAxisSize: isExplicitFill ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    return Container(
      width: double.infinity,
      height: height,
      constraints: BoxConstraints(maxHeight: calculatedMaxHeight),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: effectiveBorderRadius,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: mediaQuery.viewInsets.bottom,
          ),
          child: isScrollable
              ? SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: body,
                )
              : body,
        ),
      ),
    );
  }
}
