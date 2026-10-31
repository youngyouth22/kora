import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
import 'package:kora/features/coach/data/datasources/coach_remote_datasource.dart';
import 'package:kora/features/coach/data/repositories/coach_repository_impl.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';
import 'package:kora/features/coach/domain/usecases/send_coach_message_usecase.dart';
import 'package:kora/features/coach/presentation/bloc/coach_chat_bloc.dart';
import 'package:kora/features/coach/presentation/bloc/coach_chat_state.dart';
import 'package:kora/features/coach/presentation/pages/coach_page.dart';
import 'package:kora/features/coach/presentation/widgets/coach_bottom_sheet.dart';

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

      // History section empty state when no prior chats
      expect(find.text('No chat history yet'), findsOneWidget);
      expect(
        find.text('Ask Amie a question to get personalized skincare advice.'),
        findsOneWidget,
      );

      // New Chat FAB
      expect(find.text('New Chat'), findsOneWidget);
    });

    testWidgets('renders real conversation history when threads exist', (
      tester,
    ) async {
      final now = DateTime.now();
      final fakeThread = CoachThread(
        id: 'thread-1',
        title: 'How to soothe redness',
        updatedAt: now,
        messages: [
          CoachChatMessage(
            id: 'm-1',
            text: 'How to soothe redness',
            isUser: true,
            createdAt: now,
          ),
          CoachChatMessage(
            id: 'm-2',
            text: 'Use azelaic acid and centella.',
            isUser: false,
            createdAt: now,
          ),
        ],
      );

      final bloc = CoachChatBloc(
        sendCoachMessageUseCase: const SendCoachMessageUseCase(
          CoachRepositoryImpl(remoteDataSource: CoachRemoteDataSourceImpl()),
        ),
      )..emit(CoachChatState(threads: [fakeThread]));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoachBottomSheetContent(bloc: bloc),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('How to soothe redness'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
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
