// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Design-system compliant page transition helper for Kora routes.
///
/// Follows Kora Rules Article 6:
/// - 200–300ms animation duration with ease-out curve.
/// - Respects platform accessibility "reduce motion" preferences.
CustomTransitionPage<T> buildKoraTransitionPage<T>({
  required Widget child,
  required LocalKey key,
  String? name,
}) {
  return CustomTransitionPage<T>(
    key: key,
    name: name,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduceMotion) {
        return child;
      }

      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}
