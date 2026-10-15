// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Bottom navigation bar shell scaffold for main application tabs.
///
/// Follows Kora design tokens ([AppColors], [AppTypography]) and
/// accessibility guidelines (Semantics, >= 48dp touch targets).
class KoraShellScaffold extends StatelessWidget {
  /// Creates a [KoraShellScaffold] wrapping [navigationShell].
  const KoraShellScaffold({
    required this.navigationShell,
    super.key,
  });

  /// The stateful navigation shell managing active branch and child stack.
  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.grey50,
          border: Border(
            top: BorderSide(
              color: AppColors.grey300,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _onItemTapped(0),
                  semanticLabel: 'Navigate to Home screen',
                ),
                _NavBarItem(
                  icon: Icons.insights_rounded,
                  label: 'Progress',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _onItemTapped(1),
                  semanticLabel: 'Navigate to Skin Progress screen',
                ),
                _NavBarItem(
                  icon: Icons.spa_rounded,
                  label: 'Routine',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onItemTapped(2),
                  semanticLabel: 'Navigate to Routine screen',
                ),
                _NavBarItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Coach',
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => _onItemTapped(3),
                  semanticLabel: 'Navigate to AI Skin Coach screen',
                ),
                _NavBarItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isSelected: navigationShell.currentIndex == 4,
                  onTap: () => _onItemTapped(4),
                  semanticLabel: 'Navigate to Profile and Settings screen',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.semanticLabel,
  });

  static const Color _activeColor = AppColors.primary700;
  static const Color _inactiveColor = AppColors.grey700;

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 56,
            minHeight: 48,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? _activeColor : _inactiveColor,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.bodyXsMedium.copyWith(
                  color: isSelected ? _activeColor : _inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
