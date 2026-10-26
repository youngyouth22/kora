import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/features/coach/presentation/pages/coach_chat_page.dart';

void main() {
  group('CoachChatPage Widget Tests', () {
    Widget buildTestApp({
      String? initialQuestion,
      void Function(String route)? onNavigated,
    }) {
      final router = GoRouter(
        initialLocation: '/coach/chat',
        routes: [
          GoRoute(
            path: '/coach/chat',
            builder: (context, state) => CoachChatPage(
              initialQuestion: initialQuestion,
            ),
          ),
          GoRoute(
            path: '/coach',
            builder: (context, state) {
              onNavigated?.call('/coach');
              return const Scaffold(
                body: Center(child: Text('Coach Hub')),
              );
            },
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) {
              onNavigated?.call('/home');
              return const Scaffold(
                body: Center(child: Text('Home Screen')),
              );
            },
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
      );
    }

    testWidgets('renders top bar buttons, question pills, and input field', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Top bar icons
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      expect(find.bySemanticsLabel('Bookmark conversation'), findsOneWidget);
      expect(find.bySemanticsLabel('Close chat'), findsOneWidget);

      // Question pills
      expect(
        find.text('How to improve rough skin texture after acne?'),
        findsOneWidget,
      );
      expect(
        find.text('Nighttime routine for post-acne spot reduction?'),
        findsOneWidget,
      );
      expect(
        find.text('Skincare layering mistakes you should know for acne?'),
        findsOneWidget,
      );

      // Input field
      expect(find.text('Write your question...'), findsOneWidget);
      expect(find.bySemanticsLabel('Send question'), findsOneWidget);
    });

    testWidgets('tapping a suggested question sends it and adds AI response', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(
        find.text('How to improve rough skin texture after acne?'),
      );
      await tester.pump();

      // User message bubble appears
      expect(
        find.text('How to improve rough skin texture after acne?'),
        findsNWidgets(2), // 1 in pill, 1 in message bubble
      );

      // Wait for AI response timer
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // AI message with texture advice appears
      expect(
        find.textContaining('focus on mild chemical exfoliation'),
        findsOneWidget,
      );
    });

    testWidgets('typing a custom question and sending creates bubbles', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'What ingredients work for sensitive skin?',
      );
      await tester.tap(find.bySemanticsLabel('Send question'));
      await tester.pump();

      expect(
        find.text('What ingredients work for sensitive skin?'),
        findsOneWidget,
      );

      // Wait for AI response
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('centella asiatica'),
        findsOneWidget,
      );
    });

    testWidgets('initialQuestion is automatically sent upon entry', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          initialQuestion: 'Nighttime routine for post-acne spot reduction?',
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Wait for response
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Azelaic Acid'),
        findsOneWidget,
      );
    });
  });
}
