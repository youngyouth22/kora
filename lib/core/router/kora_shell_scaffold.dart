import 'dart:async';

import 'package:adaptive_responsive_nav/adaptive_responsive_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/features/guided_capture/presentation/widgets/new_scan_selection_sheet.dart';

/// Responsive shell scaffold for main application tabs (Home, Progress,
/// Routine, Coach, Profile).
///
/// Uses the reusable [AdaptiveResponsiveScaffold] to adapt between an
/// animated bottom navigation bar on compact mobile devices and an animated
/// navigation rail on tablet and desktop devices.
class KoraShellScaffold extends StatelessWidget {
  /// Creates a [KoraShellScaffold] wrapping [navigationShell].
  const KoraShellScaffold({
    required this.navigationShell,
    super.key,
  });

  /// The stateful navigation shell managing active branch and child stack.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AdaptiveResponsiveScaffold(
      navigationShell: navigationShell,
      onDestinationTap: (index) {
        if (index == 2) {
          unawaited(NewScanSelectionSheet.show(context));
          return false;
        }
        return true;
      },
      backgroundColor: AppColors.neutral50,
      bottomBarBackgroundColor: AppColors.grey50,
      railBackgroundColor: AppColors.grey50,
      selectedColor: AppColors.primary700,
      unselectedColor: AppColors.grey700,
      indicatorColor: AppColors.primary100,
      dividerColor: AppColors.grey400,
      selectedLabelStyle: AppTypography.bodyXsMedium.copyWith(
        color: AppColors.primary700,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.bodyXsMedium.copyWith(
        color: AppColors.grey700,
      ),
      destinations: const [
        AdaptiveNavDestination(
          index: 0,
          title: 'Home',
          icon: ImageResources.homeIcon,
          semanticLabel: 'Navigate to Home screen',
        ),
        AdaptiveNavDestination(
          index: 1,
          title: 'Routine',
          icon: ImageResources.productIcon,
          semanticLabel: 'Navigate to Products and Routine screen',
        ),
        AdaptiveNavDestination(
          index: 2,
          title: 'Skin Check',
          icon: ImageResources.scanIcon,
          semanticLabel: 'Navigate to Skin Check screen',
        ),
        AdaptiveNavDestination(
          index: 3,
          title: 'Progress',
          icon: ImageResources.progressIcon,
          semanticLabel: 'Navigate to Skin Progress screen',
        ),
        AdaptiveNavDestination(
          index: 4,
          title: 'Me',
          icon: ImageResources.profileIcon,
          semanticLabel: 'Navigate to Profile and Settings screen',
        ),
      ],
    );
  }
}
