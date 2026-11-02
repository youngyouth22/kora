import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/image_resources.dart';

/// Product card preview displayed in step 2 of the product scan tutorial,
/// featuring a rounded container with placeholder image and a mint accent bar.
class ProductCardPreview extends StatelessWidget {
  /// Creates a [ProductCardPreview].
  const ProductCardPreview({
    this.child,
    this.width = 210,
    this.height = 240,
    super.key,
  });

  /// The child illustration or photo. Falls back to a [Placeholder].
  final Widget? child;

  /// Width of the card container.
  final double width;

  /// Height of the card container.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppGreyColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(20),
          child:
              child ??
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  ImageResources.ceraveProductBg,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Placeholder(
                    strokeWidth: 1.5,
                    color: AppColors.primary400,
                  ),
                ),
              ),
        ),
        const SizedBox(height: 8),
        Container(
          width: width,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.primary400,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
