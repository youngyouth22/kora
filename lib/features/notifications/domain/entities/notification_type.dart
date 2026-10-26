import 'package:kora/core/router/app_routes.dart';

/// Exhaustive enumeration of notification types in Kora with predefined
/// copy, default target routes, and strict non-guilt tone guidelines.
enum NotificationType {
  /// N1 (P0) — Weekly scan due reminder.
  /// « Time for your weekly scan. 30 seconds, same spot as last time. »
  scanDue(
    id: 101,
    category: 'scan',
    defaultTitle: 'Time for your weekly scan',
    defaultBody: '30 seconds, same spot as last time.',
    defaultTargetRoute: AppRoutes.scanCapture,
  ),

  /// N2 (P1) — Scan late reminder.
  /// Gentle, non-guilt-tripping reminder.
  scanLate(
    id: 102,
    category: 'scan',
    defaultTitle: 'Your skin check-in is waiting',
    defaultBody: 'Track your changes whenever you are ready.',
    defaultTargetRoute: AppRoutes.scanCapture,
  ),

  /// N3 (P0) — Free trial ending reminder.
  /// « Your free trial ends in 2 days. You can manage it anytime in Settings. »
  trialEnding(
    id: 103,
    category: 'subscription',
    defaultTitle: 'Your free trial ends in 2 days',
    defaultBody: 'You can manage it anytime in Settings.',
    defaultTargetRoute: AppRoutes.profileSubscription,
  ),

  /// N4 (P1) — Experiment verdict ready reminder.
  /// « Your routine experiment verdict is in. Check what worked. »
  verdict(
    id: 104,
    category: 'experiment',
    defaultTitle: 'Experiment verdict is ready',
    defaultBody: 'Your routine experiment verdict is in. Check what worked.',
    defaultTargetRoute: AppRoutes.routine,
  ),

  /// N5 (P1) — Milestone streak & progress achievement.
  /// « 4 weeks of consistent scans. Your skin barrier trend is ready. »
  milestone(
    id: 105,
    category: 'progress',
    defaultTitle: 'Scan milestone reached',
    defaultBody:
        '4 weeks of consistent scans. Your skin barrier trend is ready.',
    defaultTargetRoute: AppRoutes.progress,
  ),

  /// N6 (P1) — Routine hydration reminder.
  /// « Evening routine reminder. Keep your skin hydrated tonight. »
  routine(
    id: 106,
    category: 'routine',
    defaultTitle: 'Evening routine reminder',
    defaultBody: 'Keep your skin hydrated and protected tonight.',
    defaultTargetRoute: AppRoutes.routine,
  ),

  /// N7 (P2) — Win-back reconnection.
  /// Gentle, non-guilt tone: history is always safe.
  winBack(
    id: 107,
    category: 'win_back',
    defaultTitle: 'Your skin history is safe',
    defaultBody: 'Whenever you are ready for a fresh start, Kora is here.',
    defaultTargetRoute: AppRoutes.home,
  );

  /// Creates a [NotificationType] variant.
  const NotificationType({
    required this.id,
    required this.category,
    required this.defaultTitle,
    required this.defaultBody,
    required this.defaultTargetRoute,
  });

  /// Unique notification ID for local notification scheduling.
  final int id;

  /// Semantic categorization (e.g. scan, subscription, routine).
  final String category;

  /// Standard title.
  final String defaultTitle;

  /// Standard body copy.
  final String defaultBody;

  /// Deep link destination when tapped.
  final String defaultTargetRoute;

  /// Factory finding a type from raw string name.
  static NotificationType fromString(String? raw) {
    if (raw == null) return NotificationType.scanDue;
    for (final type in NotificationType.values) {
      if (type.name.toLowerCase() == raw.toLowerCase() ||
          type.category.toLowerCase() == raw.toLowerCase()) {
        return type;
      }
    }
    return NotificationType.scanDue;
  }
}
