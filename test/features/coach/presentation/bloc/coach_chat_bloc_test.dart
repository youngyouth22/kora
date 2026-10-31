import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/error/exceptions.dart';
import 'package:kora/features/coach/data/datasources/coach_local_datasource.dart';
import 'package:kora/features/coach/data/datasources/coach_remote_datasource.dart';
import 'package:kora/features/coach/data/models/coach_chat_models.dart';
import 'package:kora/features/coach/data/repositories/coach_repository_impl.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';
import 'package:kora/features/coach/domain/usecases/delete_coach_thread_usecase.dart';
import 'package:kora/features/coach/domain/usecases/get_coach_threads_usecase.dart';
import 'package:kora/features/coach/domain/usecases/save_coach_thread_usecase.dart';
import 'package:kora/features/coach/domain/usecases/send_coach_message_usecase.dart';
import 'package:kora/features/coach/presentation/bloc/coach_chat_bloc.dart';
import 'package:kora/features/coach/presentation/bloc/coach_chat_event.dart';

class _FakeCoachRemoteDataSource implements CoachRemoteDataSource {
  bool shouldThrow = false;

  @override
  Future<CoachReplyModel> sendMessage({
    required String message,
    required String threadId,
    CoachContext? coachContext,
    List<CoachChatMessage>? history,
  }) async {
    if (shouldThrow) {
      throw const NetworkException(message: 'Connection lost');
    }
    if (message.toLowerCase().contains('bleed')) {
      return const CoachReplyModel(
        text: 'Please consult a doctor immediately.',
        isRedFlag: true,
      );
    }
    return const CoachReplyModel(
      text: 'Your hydration index is 58. Focus on ceramides.',
      suggestedAction: CoachSuggestedActionModel(
        type: 'log_scan',
        label: 'Faire un nouveau scan rapide',
        payload: {'reason': 'hydration_check'},
      ),
    );
  }
}

class _FakeCoachLocalDataSource implements CoachLocalDataSource {
  final List<CoachThreadModel> _threads = [];

  @override
  Future<List<CoachThreadModel>> getThreads() async => List.of(_threads);

  @override
  Future<CoachThreadModel?> getThread(String threadId) async {
    return _threads.where((t) => t.id == threadId).firstOrNull;
  }

  @override
  Future<void> saveThread(CoachThreadModel thread) async {
    _threads.removeWhere((t) => t.id == thread.id);
    _threads.insert(0, thread);
  }

  @override
  Future<void> deleteThread(String threadId) async {
    _threads.removeWhere((t) => t.id == threadId);
  }
}

void main() {
  group('CoachChatBloc & Repository', () {
    late _FakeCoachRemoteDataSource fakeRemote;
    late _FakeCoachLocalDataSource fakeLocal;
    late CoachRepositoryImpl repository;
    late SendCoachMessageUseCase sendUseCase;
    late GetCoachThreadsUseCase getThreadsUseCase;
    late SaveCoachThreadUseCase saveThreadUseCase;
    late DeleteCoachThreadUseCase deleteThreadUseCase;

    setUp(() {
      fakeRemote = _FakeCoachRemoteDataSource();
      fakeLocal = _FakeCoachLocalDataSource();
      repository = CoachRepositoryImpl(
        remoteDataSource: fakeRemote,
        localDataSource: fakeLocal,
      );
      sendUseCase = SendCoachMessageUseCase(repository);
      getThreadsUseCase = GetCoachThreadsUseCase(repository);
      saveThreadUseCase = SaveCoachThreadUseCase(repository);
      deleteThreadUseCase = DeleteCoachThreadUseCase(repository);
    });

    test(
      'serializes CoachChatRequestModel and deserializes CoachReplyModel '
      '(direct + Mastra)',
      () {
        const request = CoachChatRequestModel(
          message: 'Ma peau tiraille',
          threadId: 'thread-123',
          userId: 'user-456',
          userJwt: 'jwt-789',
          coachContext: CoachContext(
            lastScanDate: '2026-10-25',
            activeExperiment: 'Niacinamide 10%',
            currentConcern: 'dryness',
          ),
        );

        final reqJson = request.toJson();
        expect(reqJson['threadId'], 'thread-123');
        expect(reqJson['userId'], 'user-456');
        expect(
          (reqJson['coachContext'] as Map<String, dynamic>)['currentConcern'],
          'dryness',
        );

        // Standard direct payload
        final replyModel = CoachReplyModel.fromJson(const {
          'text': 'Hydratez votre peau.',
          'isRedFlag': false,
          'suggestedAction': {
            'type': 'log_scan',
            'label': 'Faire un nouveau scan rapide',
            'payload': {'reason': 'hydration_check'},
          },
        });
        final entity = replyModel.toEntity();
        expect(entity.text, 'Hydratez votre peau.');
        expect(entity.isRedFlag, isFalse);
        expect(entity.suggestedAction?.type, 'log_scan');

        // Mastra agent toolInvocations response payload
        final mastraReplyModel = CoachReplyModel.fromJson(const {
          'text': 'Improving rough skin texture...',
          'toolInvocations': [
            {
              'toolName': 'suggest_action',
              'result': {
                'type': 'start_experiment',
                'label': 'Start a texture experiment',
                'payload': {
                  'targets': ['texture'],
                },
              },
            },
          ],
        });
        expect(mastraReplyModel.text, 'Improving rough skin texture...');
        expect(mastraReplyModel.suggestedAction?.type, 'start_experiment');
        expect(
          mastraReplyModel.suggestedAction?.label,
          'Start a texture experiment',
        );
      },
    );

    test(
      'emits loading then success with assistant message and persists thread',
      () async {
        final bloc =
            CoachChatBloc(
                sendCoachMessageUseCase: sendUseCase,
                getCoachThreadsUseCase: getThreadsUseCase,
                saveCoachThreadUseCase: saveThreadUseCase,
                deleteCoachThreadUseCase: deleteThreadUseCase,
              )
              ..add(const CoachChatStartedEvent())
              ..add(const CoachMessageSentEvent('My skin feels dry'));

        await Future<void>.delayed(const Duration(milliseconds: 60));

        expect(bloc.state.status, BaseStatus.success);
        expect(bloc.state.messages.length, 2);
        expect(bloc.state.messages.first.isUser, isTrue);
        expect(bloc.state.messages.last.isUser, isFalse);
        expect(
          bloc.state.messages.last.suggestedAction?.label,
          'Faire un nouveau scan rapide',
        );
        expect(bloc.state.hasActiveRedFlag, isFalse);
        expect(bloc.state.threads.length, 1);
        expect(bloc.state.threads.first.title, 'My skin feels dry');

        await bloc.close();
      },
    );

    test(
      'activates hasActiveRedFlag when backend returns isRedFlag: true',
      () async {
        final bloc = CoachChatBloc(
          sendCoachMessageUseCase: sendUseCase,
          getCoachThreadsUseCase: getThreadsUseCase,
          saveCoachThreadUseCase: saveThreadUseCase,
          deleteCoachThreadUseCase: deleteThreadUseCase,
        )..add(const CoachMessageSentEvent('My mole is bleeding'));

        await Future<void>.delayed(const Duration(milliseconds: 60));

        expect(bloc.state.status, BaseStatus.success);
        expect(bloc.state.hasActiveRedFlag, isTrue);
        expect(bloc.state.messages.last.isRedFlag, isTrue);
        await bloc.close();
      },
    );

    test('emits failure state when network fails', () async {
      fakeRemote.shouldThrow = true;
      final bloc = CoachChatBloc(
        sendCoachMessageUseCase: sendUseCase,
        getCoachThreadsUseCase: getThreadsUseCase,
        saveCoachThreadUseCase: saveThreadUseCase,
        deleteCoachThreadUseCase: deleteThreadUseCase,
      )..add(const CoachMessageSentEvent('Hello'));

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(bloc.state.status, BaseStatus.failure);
      expect(bloc.state.errorMessage, 'Connection lost');
      await bloc.close();
    });

    test('toggles bookmark state', () async {
      final bloc = CoachChatBloc(sendCoachMessageUseCase: sendUseCase);
      expect(bloc.state.isBookmarked, isFalse);

      bloc.add(const CoachBookmarkToggledEvent());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.isBookmarked, isTrue);
      await bloc.close();
    });

    test('handles selecting an existing conversation thread', () async {
      final pastDate = DateTime(2026, 10, 20);
      fakeLocal._threads.add(
        CoachThreadModel(
          id: 'thread-old',
          title: 'Past acne question',
          updatedAt: pastDate,
          messages: [
            CoachChatMessageModel(
              id: 'msg-1',
              text: 'Past acne question',
              isUser: true,
              createdAt: pastDate,
            ),
            CoachChatMessageModel(
              id: 'msg-2',
              text: 'Try salicylic acid.',
              isUser: false,
              createdAt: pastDate,
            ),
          ],
        ),
      );

      final bloc = CoachChatBloc(
        sendCoachMessageUseCase: sendUseCase,
        getCoachThreadsUseCase: getThreadsUseCase,
        saveCoachThreadUseCase: saveThreadUseCase,
        deleteCoachThreadUseCase: deleteThreadUseCase,
      )..add(const CoachChatStartedEvent());

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(bloc.state.threads.length, 1);

      bloc.add(const CoachThreadSelectedEvent('thread-old'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.threadId, 'thread-old');
      expect(bloc.state.messages.length, 2);
      expect(bloc.state.messages.first.text, 'Past acne question');

      await bloc.close();
    });
  });
}
