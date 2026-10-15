// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:kora/common/app_themes.dart';
import 'package:kora/core/core.dart';
import 'package:kora/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
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
