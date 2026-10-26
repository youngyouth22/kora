import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Processing view displaying the captured product photo with an animated
/// emerald laser line scanning continuously while backend analysis executes.
class ProcessingScanView extends StatefulWidget {
  /// Creates a [ProcessingScanView].
  const ProcessingScanView({
    required this.imagePath,
    required this.onBack,
    super.key,
  });

  /// Path to the captured or picked photo file.
  final String imagePath;

  /// Callback when the user taps back.
  final VoidCallback onBack;

  @override
  State<ProcessingScanView> createState() => _ProcessingScanViewState();
}

class _ProcessingScanViewState extends State<ProcessingScanView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _laserAnimation = CurvedAnimation(
      parent: _laserController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.grey1050,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Back button (Round white circle top-left)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: 'Back to camera',
                  child: Material(
                    color: AppGreyColors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: widget.onBack,
                      child: const Padding(
                        padding: EdgeInsets.all(9),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.grey1050,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),

            // 2. Central Product Photo Card with Laser Scanning Beam
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AspectRatio(
                aspectRatio: 0.72,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardHeight = constraints.maxHeight;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Card container with rounded corners
                        Positioned.fill(
                          left: 8,
                          right: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: widget.imagePath.isNotEmpty
                                ? Image.file(
                                    File(widget.imagePath),
                                    fit: BoxFit.cover,
                                  )
                                : const ColoredBox(
                                    color: AppColors.grey950,
                                    child: Center(
                                      child: Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 72,
                                        color: AppColors.primary400,
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                        // Animated scanning laser line
                        AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, _) {
                            final topOffset =
                                20.0 +
                                (_laserAnimation.value * (cardHeight - 44.0));

                            return Positioned(
                              top: topOffset,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 5.5,
                                decoration: BoxDecoration(
                                  color: AppColors.primary400,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary400.withValues(
                                        alpha: 0.65,
                                      ),
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: AppColors.primary500.withValues(
                                        alpha: 0.40,
                                      ),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const Spacer(flex: 2),

            // 3. Bottom text: "Processing the image."
            Padding(
              padding: const EdgeInsets.only(bottom: 54),
              child: Text(
                'Processing the image.',
                textAlign: TextAlign.center,
                style: AppTypography.h5Medium.copyWith(
                  color: AppGreyColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
