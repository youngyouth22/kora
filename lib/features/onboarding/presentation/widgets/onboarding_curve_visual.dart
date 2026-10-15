import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Stylized visual representation featuring a curve and skin tone avatars.
class OnboardingCurveVisual extends StatelessWidget {
  /// Creates an [OnboardingCurveVisual].
  const OnboardingCurveVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Stylized curve illustrating skincare journey with diverse tones',
      image: true,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.neutral200,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.neutral600),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CurveAccentPainter(),
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AvatarDot(
                  color: Color(0xFF8D5524),
                  label: 'Deep skin tone avatar',
                ),
                SizedBox(width: 10),
                _AvatarDot(
                  color: Color(0xFFC68642),
                  label: 'Warm olive skin tone avatar',
                ),
                SizedBox(width: 10),
                _AvatarDot(
                  color: Color(0xFFE0AC69),
                  label: 'Medium neutral skin tone avatar',
                ),
                SizedBox(width: 10),
                _AvatarDot(
                  color: Color(0xFFF1C27D),
                  label: 'Fair golden skin tone avatar',
                ),
                SizedBox(width: 10),
                _AvatarDot(
                  color: Color(0xFFFFDBAC),
                  label: 'Light porcelain skin tone avatar',
                ),
              ],
            ),
            Positioned(
              bottom: 12,
              child: Text(
                'Personalized for every skin tone',
                style: AppTypography.bodySRegular.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarDot extends StatelessWidget {
  const _AvatarDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: AppColors.grey50,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey1050.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurveAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary100.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.3,
        size.width * 0.6,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.75,
        size.width,
        size.height * 0.25,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
