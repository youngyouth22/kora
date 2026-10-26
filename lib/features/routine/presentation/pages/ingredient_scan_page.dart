import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';

/// Screen for scanning ingredient labels via camera OCR (C09 in blueprint).
class IngredientScanPage extends StatefulWidget {
  /// Creates an [IngredientScanPage].
  const IngredientScanPage({super.key});

  @override
  State<IngredientScanPage> createState() => _IngredientScanPageState();
}

class _IngredientScanPageState extends State<IngredientScanPage> {
  bool _isAnalyzing = false;

  Future<void> _onCapture() async {
    setState(() => _isAnalyzing = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      context.pushReplacement(AppRoutes.buildRoutineIngredientsPath('demo-1'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey1050,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.grey50,
        title: Text(
          'Scan Label',
          style: AppTypography.h5Bold.copyWith(color: AppColors.grey50),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Text(
                'Frame the full ingredients (INCI) list',
                style: AppTypography.bodyLMedium.copyWith(
                  color: AppColors.grey50,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Hold steady and ensure even indoor or window lighting.',
                style: AppTypography.bodySRegular.copyWith(
                  color: AppColors.grey400,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              // OCR Viewfinder box with corner brackets
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.grey950.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary400, width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.document_scanner_rounded,
                        size: 48,
                        color: AppColors.primary400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Align text inside this frame',
                        style: AppTypography.bodySMedium.copyWith(
                          color: AppColors.grey300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Capture Button
              PrimaryButton(
                text: _isAnalyzing ? 'Analyzing INCI text...' : 'Capture label',
                height: 52,
                isLoading: _isAnalyzing,
                backgroundColor: AppColors.primary700,
                onPressed: _isAnalyzing ? null : _onCapture,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
