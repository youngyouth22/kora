import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/custom_bottom_sheet.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/core/router/app_session_state.dart';
import 'package:kora/features/guided_capture/presentation/widgets/scan_option_card.dart';

/// Scan type picked in [NewScanSelectionSheet].
enum NewScanChoice {
  /// Face / skin scan.
  face,

  /// Cosmetics & food product scan.
  product,
}

/// Modal bottom sheet presenting scan choices ("Face" vs "Cosmetics & Food")
/// as specified in the Kora design system.
class NewScanSelectionSheet extends StatelessWidget {
  /// Creates a [NewScanSelectionSheet].
  const NewScanSelectionSheet({
    this.sessionState,
    this.onFaceScanSelected,
    this.onProductScanSelected,
    super.key,
  });

  /// Optional session state override for testing.
  final AppSessionState? sessionState;

  /// Optional override callback when Face scan is selected.
  final VoidCallback? onFaceScanSelected;

  /// Optional override callback when Cosmetics & Food scan is selected.
  final VoidCallback? onProductScanSelected;

  /// Displays the modal bottom sheet via [showCustomModalBottomSheet].
  ///
  /// Navigation to the chosen scan only starts once the sheet's exit
  /// animation has fully completed, so the sheet never shows through the
  /// incoming full-screen camera page.
  static Future<void> show(
    BuildContext context, {
    AppSessionState? sessionState,
    VoidCallback? onFaceScanSelected,
    VoidCallback? onProductScanSelected,
  }) async {
    Animation<double>? sheetAnimation;
    final choice = await showCustomModalBottomSheet<NewScanChoice>(
      context: context,
      backgroundColor: AppGreyColors.white,
      barrierColor: AppGreyColors.shade1050.withValues(alpha: 0.35),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      dragHandleColor: AppColors.grey500,
      contentPadding: EdgeInsets.zero,
      content: Builder(
        builder: (sheetContext) {
          sheetAnimation = ModalRoute.of(sheetContext)?.animation;
          return NewScanSelectionSheet(sessionState: sessionState);
        },
      ),
    );
    if (choice == null) return;

    await _waitUntilDismissed(sheetAnimation);
    if (!context.mounted) return;

    switch (choice) {
      case NewScanChoice.face:
        if (onFaceScanSelected != null) {
          onFaceScanSelected();
        } else {
          unawaited(context.push(_faceScanRoute(sessionState)));
        }
      case NewScanChoice.product:
        if (onProductScanSelected != null) {
          onProductScanSelected();
        } else {
          unawaited(context.push(_productScanRoute(sessionState)));
        }
    }
  }

  static Future<void> _waitUntilDismissed(Animation<double>? animation) {
    if (animation == null || animation.status == AnimationStatus.dismissed) {
      return Future<void>.value();
    }
    final completer = Completer<void>();
    void listener(AnimationStatus status) {
      if (status == AnimationStatus.dismissed && !completer.isCompleted) {
        animation.removeStatusListener(listener);
        completer.complete();
      }
    }

    animation.addStatusListener(listener);
    return completer.future;
  }

  static String _faceScanRoute(AppSessionState? sessionState) {
    final effectiveSession =
        sessionState ??
        (GetIt.instance.isRegistered<AppSessionState>()
            ? GetIt.instance<AppSessionState>()
            : null);
    final hasSeenGuide = effectiveSession?.hasSeenScanGuide ?? false;
    return hasSeenGuide ? AppRoutes.scanCapture : AppRoutes.scanGuide;
  }

  static String _productScanRoute(AppSessionState? sessionState) {
    final effectiveSession =
        sessionState ??
        (GetIt.instance.isRegistered<AppSessionState>()
            ? GetIt.instance<AppSessionState>()
            : null);
    final hasSeenTutorial =
        effectiveSession?.hasSeenProductScanTutorial ?? false;
    return hasSeenTutorial
        ? AppRoutes.routineLabel
        : AppRoutes.productScanTutorial;
  }

  void _select(BuildContext context, NewScanChoice choice) {
    // Inline usage (not inside [show]): honour the direct callbacks.
    if (choice == NewScanChoice.face && onFaceScanSelected != null) {
      onFaceScanSelected!();
      return;
    }
    if (choice == NewScanChoice.product && onProductScanSelected != null) {
      onProductScanSelected!();
      return;
    }
    Navigator.of(context).pop(choice);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Semantics(
                button: true,
                label: 'Close scan options',
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 26,
                    color: AppGreyColors.shade1050,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Make a New Scan',
              textAlign: TextAlign.center,
              style: AppTypography.h3Bold.copyWith(
                color: AppGreyColors.shade1050,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what you want to scan with Amie',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLRegular.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ScanOptionCard(
                    title: 'Face',
                    subtitle: 'See the condition of your skin',
                    onTap: () => _select(context, NewScanChoice.face),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ScanOptionCard(
                    title: 'Cosmetics',
                    subtitle: 'See if a skincare product fits you',
                    onTap: () => _select(context, NewScanChoice.product),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
