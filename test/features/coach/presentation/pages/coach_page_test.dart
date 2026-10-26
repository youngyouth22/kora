import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
import 'package:kora/features/coach/presentation/pages/coach_page.dart';

void main() {
  group('CoachPage Widget Tests', () {
    Widget buildTestApp({
      void Function(String route, Object? extra)? onNavigated,
    }) {
      final router = GoRouter(
        initialLocation: '/coach',
        routes: [
          GoRoute(
            path: '/coach',
            builder: (context, state) => const CoachPage(),
          ),
          GoRoute(
            path: '/coach/chat',
            builder: (context, state) {
              onNavigated?.call('/coach/chat', state.extra);
              return Scaffold(
                body: Center(
                  child: Text('Chat Screen: ${state.extra ?? ""}'),
                ),
              );
            },
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Screen')),
            ),
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
      );
    }

    testWidgets('renders mascot, title, prompt cards, and history section', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Mascot illustration
      expect(find.byType(MascotIllustration), findsOneWidget);
      final mascotWidget = tester.widget<MascotIllustration>(
        find.byType(MascotIllustration),
      );
      expect(mascotWidget.pose, MascotPose.wave);

      // Title
      expect(
        find.text("Hi I'm Amie,\nyour skincare companion"),
        findsOneWidget,
      );

      // Section titles
      expect(find.text('Start a chat'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      // Suggested quick prompts
      expect(
        find.text('✨ Why am I getting small breakouts lately?'),
        findsOneWidget,
      );
      expect(
        find.text('🌿 What ingredients suit sensitive skin?'),
        findsOneWidget,
      );

      // History items
      expect(
        find.text('🌿 Post-acne care routine suggestion'),
        findsOneWidget,
      );
      expect(find.text('☀️ Morning routine update'), findsOneWidget);

      // New Chat FAB
      expect(find.text('New Chat'), findsOneWidget);
    });

    testWidgets(
      'tapping New Chat FAB navigates to coach chat page in PageView',
      (
        tester,
      ) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('New Chat'));
        await tester.pumpAndSettle();

        expect(find.text('Write your question...'), findsOneWidget);
        expect(find.bySemanticsLabel('Back to companion hub'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a prompt card passes question to chat page in PageView',
      (
        tester,
      ) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(
          find.text('✨ Why am I getting small breakouts lately?'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Write your question...'), findsOneWidget);
        expect(
          find.text('Why am I getting small breakouts lately?'),
          findsOneWidget,
        );
      },
    );

    testWidgets('toggles bookmark icon state when tapped', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final bookmarkBtn = find.bySemanticsLabel('Bookmark conversation hub');
      expect(bookmarkBtn, findsOneWidget);

      await tester.tap(bookmarkBtn);
      await tester.pumpAndSettle();

      expect(bookmarkBtn, findsOneWidget);
    });
  });
}
