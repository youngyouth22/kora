import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/features/coach/presentation/widgets/coach_bottom_sheet.dart';

/// Contextual AI Skin Coach companion hub screen (C14 in blueprint).
class CoachPage extends StatelessWidget {
  /// Creates a [CoachPage].
  const CoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: SafeArea(
        child: CoachBottomSheetContent(),
      ),
    );
  }
}
