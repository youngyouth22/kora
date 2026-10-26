import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/core/router/kora_shell_scaffold.dart';

void main() {
  group('KoraShellScaffold Tests', () {
    Widget createTestApp({
      required Size size,
    }) {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) => KoraShellScaffold(
              navigationShell: navigationShell,
            ),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) =>
                        const Center(child: Text('Home Screen')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/routine',
                    builder: (context, state) =>
                        const Center(child: Text('Products Screen')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/skin-check',
                    builder: (context, state) =>
                        const Center(child: Text('Skin Check Screen')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/progress',
                    builder: (context, state) =>
                        const Center(child: Text('Progress Screen')),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/profile',
                    builder: (context, state) =>
                        const Center(child: Text('Profile Screen')),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
      );
    }

    testWidgets('renders bottom bar navigation on compact mobile width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(size: const Size(400, 800)));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Routine'), findsOneWidget);
      expect(find.text('Skin Check'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);

      // Tap on Routine tab
      await tester.tap(find.text('Routine'));
      await tester.pumpAndSettle();

      expect(find.text('Products Screen'), findsOneWidget);
    });

    testWidgets('renders navigation rail on large screen width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(size: const Size(1024, 768)));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);

      // Tap on Progress tab
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      expect(find.text('Progress Screen'), findsOneWidget);
    });
  });
}
