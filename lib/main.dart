// ignore_for_file: document_ignores

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kora/common/app_themes.dart';
import 'package:kora/core/core.dart';
import 'package:kora/core/services/revenue_cat_service.dart';
import 'package:kora/di/injection.dart';
import 'package:kora/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } on Object catch (_) {}
  configureDependencies(preferences: prefs);
  try {
    await RevenueCatService.initialize();
  } on Object catch (_) {}
  runApp(const MainApp());
}

/// Root application widget configuring [MaterialApp.router] with [AppRouter].
class MainApp extends StatefulWidget {
  /// Creates the [MainApp].
  const MainApp({
    this.appRouter,
    super.key,
  });

  /// Optional custom [AppRouter] instance (useful for integration tests).
  final AppRouter? appRouter;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = widget.appRouter ?? AppRouter();
    _initNotifications();
  }

  void _initNotifications() {
    try {
      if (sl.isRegistered<NotificationLocalDataSource>()) {
        unawaited(
          sl<NotificationLocalDataSource>().initialize(
            onNotificationTapped: (payload) {
              unawaited(_appRouter.router.push(payload.targetRoute));
            },
          ),
        );
      }
    } on Object catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kora',
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.router,
      theme: AppThemes.lightTheme,
    );
  }
}
