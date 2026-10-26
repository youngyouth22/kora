// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/skin_analysis/domain/entities/skin_analysis_result.dart';
import 'package:kora/features/skin_analysis/presentation/widgets/skin_scan_result_bottom_sheet.dart';

/// Full screen view presenting the first-scan skin analysis result and AI report.
class ScanResultPage extends StatelessWidget {
  /// Creates a [ScanResultPage].
  const ScanResultPage({this.result, super.key});

  /// The skin analysis result entity.
  final SkinAnalysisResult? result;

  @override
  Widget build(BuildContext context) {
    final effectiveResult = result ?? _fallbackResult;

    return Scaffold(
      backgroundColor: AppGreyColors.white,
      appBar: AppBar(
        backgroundColor: AppGreyColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppGreyColors.shade1050,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SkinScanResultBottomSheet(
        result: effectiveResult,
        isStandalonePage: true,
        onSaveToRoutine: () {
          context.go(AppRoutes.accountSecure);
        },
      ),
    );
  }

  static const SkinAnalysisResult _fallbackResult = SkinAnalysisResult(
    overallScore: 69.3,
    allConcerns: [],
  );
}
