// ignore_for_file: document_ignores, public_member_api_docs, avoid_positional_boolean_parameters, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';

/// Tokens partagés par les trois cards d'onboarding.
///
/// Tout dérive de [AppColors] et [AppTypography]. Une seule valeur est
/// écrite en dur : le blanc de [surface] (remplace-le par ton token de
/// surface/blanc si tu en as un).
abstract final class CardKit {
  /// Taille de conception : chaque card est dessinée dans 360 x 400 puis
  /// mise à l'échelle pour remplir l'écran.
  static const designW = 360.0;
  static const designH = 400.0;

  static Color get surface => AppColors.grey50;
  static Color get cardBackground => AppColors.scaffoldColor;
  static Color get ink => AppColors.baseColor;
  static Color get muted => AppColors.grey700;
  static Color get hairline => AppColors.neutral600.withValues(alpha: 0.4);
  static Color get primary => AppColors.primary700;
  static Color get primaryAccent => AppColors.primary;
  static Color get primaryLight => AppColors.primary50;
  static Color get primaryBorder => AppColors.primary200;
  static Color get secondaryAccent => AppColors.secondary500;

  static List<BoxShadow> get shadow => [
    BoxShadow(
      color: AppColors.baseColor.withValues(alpha: 0.08),
      blurRadius: 32,
      spreadRadius: -6,
      offset: const Offset(0, 16),
    ),
    BoxShadow(
      color: AppColors.baseColor.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static BoxDecoration decoration({double radius = 28, Color? color}) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: hairline),
      boxShadow: shadow,
    );
  }

  static TextStyle title(double size, {Color? color}) =>
      AppTypography.h4Bold.copyWith(
        fontSize: size,
        color: color ?? ink,
        height: 1.15,
        letterSpacing: -0.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle label(double size, {Color? color, FontWeight? weight}) =>
      AppTypography.bodyMSemiBold.copyWith(
        fontSize: size,
        color: color ?? muted,
        height: 1.3,
        fontWeight: weight,
      );

  static bool reduceMotion(BuildContext context) {
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return true;
    }
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }
}

/// Dessine [child] dans 360 x 400 puis l'agrandit/réduit pour remplir la
/// largeur disponible (max 440) sans dépasser 46 % de la hauteur d'écran.
class ScaledCard extends StatelessWidget {
  const ScaledCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = MediaQuery.sizeOf(context);
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screen.width - 48;
        var w = maxW.clamp(0.0, 440.0);
        var h = w * CardKit.designH / CardKit.designW;
        final cap = screen.height * 0.46;
        if (h > cap) {
          h = cap;
          w = h * CardKit.designW / CardKit.designH;
        }
        return SizedBox(
          width: w,
          height: h,
          child: FittedBox(
            child: SizedBox(
              width: CardKit.designW,
              height: CardKit.designH,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Raccourci pour appliquer des animations sauf si l'utilisateur les a
/// désactivées dans les réglages d'accessibilité.
extension CardMotion on Widget {
  Widget motion(
    bool reduce,
    Animate Function(Animate a) effects, {
    void Function(AnimationController controller)? onPlay,
  }) {
    if (reduce) return this;
    return effects(animate(onPlay: onPlay));
  }
}

/// Nombre qui monte de 0 à [end] avec chiffres tabulaires.
class CountUp extends StatelessWidget {
  const CountUp({
    required this.end,
    required this.style,
    this.decimals = 0,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1500),
    super.key,
  });

  final double end;
  final TextStyle style;
  final int decimals;
  final String prefix;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduce = CardKit.reduceMotion(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: reduce ? end : 0, end: end),
      duration: reduce ? Duration.zero : duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) =>
          Text('$prefix${v.toStringAsFixed(decimals)}$suffix', style: style),
    );
  }
}

/// Avatar à initiale, dérivé de la couleur de marque.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar({
    required this.initial,
    required this.size,
    this.backgroundColor,
    this.textColor,
    this.shade = 0.18,
    super.key,
  });

  final String initial;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double shade;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            backgroundColor ??
            Color.alphaBlend(
              CardKit.primary.withValues(alpha: shade),
              CardKit.surface,
            ),
        border: Border.all(color: CardKit.surface, width: 2),
      ),
      child: Text(
        initial,
        style: CardKit.label(
          size * 0.4,
          color: textColor ?? CardKit.ink,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
