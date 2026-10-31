import 'package:flutter/material.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Aperçu réaliste d'une notification : icône de l'app, en-tête, titre et
/// message. Le message s'anime quand le jour ou l'heure change. Deux cartes
/// fantômes empilées derrière donnent de la profondeur.
class NotificationPreviewCard extends StatelessWidget {
  /// Creates a [NotificationPreviewCard].
  const NotificationPreviewCard({
    required this.title,
    required this.body,
    super.key,
  });

  /// Notification title.
  final String title;

  /// Notification body, updated live by the parent.
  final String body;

  Widget _ghost({
    required double inset,
    required double bottom,
    required double alpha,
  }) {
    return Positioned(
      left: inset,
      right: inset,
      bottom: bottom,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.neutral50.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.grey200),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Notification preview. $title. $body',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _ghost(inset: 26, bottom: -14, alpha: 0.55),
            _ghost(inset: 13, bottom: -7, alpha: 0.85),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.grey200),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary900.withValues(alpha: 0.10),
                    blurRadius: 32,
                    spreadRadius: -8,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary700, AppColors.primary900],
                      ),
                    ),
                    child: const Icon(
                      Icons.face_retouching_natural_rounded,
                      color: AppColors.neutral50,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'KORA',
                              style: AppTypography.bodyMSemiBold.copyWith(
                                fontSize: 11,
                                letterSpacing: 0.8,
                                color: AppColors.grey500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'now',
                              style: AppTypography.bodyMRegular.copyWith(
                                fontSize: 11.5,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          title,
                          style: AppTypography.bodyMSemiBold.copyWith(
                            fontSize: 15,
                            color: AppColors.grey1050,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              ...previous,
                              ?current,
                            ],
                          ),
                          child: Text(
                            body,
                            key: ValueKey(body),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMRegular.copyWith(
                              fontSize: 13.5,
                              height: 1.35,
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
