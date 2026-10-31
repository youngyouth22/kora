// ignore_for_file: document_ignores, prefer_initializing_formals

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';
import 'package:kora/features/coach/domain/usecases/delete_coach_thread_usecase.dart';
import 'package:kora/features/coach/domain/usecases/get_coach_threads_usecase.dart';
import 'package:kora/features/coach/domain/usecases/save_coach_thread_usecase.dart';
import 'package:kora/features/coach/domain/usecases/send_coach_message_usecase.dart';
import 'package:kora/features/coach/presentation/bloc/coach_chat_event.dart';
import 'package:kora/features/coach/presentation/bloc/coach_chat_state.dart';

/// BLoC orchestrating the Kora AI Coach conversation, real thread persistence,
/// medical safety gating, and suggested actions.
class CoachChatBloc extends Bloc<CoachChatEvent, CoachChatState> {
  /// Creates a [CoachChatBloc].
  CoachChatBloc({
    required SendCoachMessageUseCase sendCoachMessageUseCase,
    GetCoachThreadsUseCase? getCoachThreadsUseCase,
    SaveCoachThreadUseCase? saveCoachThreadUseCase,
    DeleteCoachThreadUseCase? deleteCoachThreadUseCase,
    AppPreferencesService? preferencesService,
  }) : _sendCoachMessageUseCase = sendCoachMessageUseCase,
       _getCoachThreadsUseCase = getCoachThreadsUseCase,
       _saveCoachThreadUseCase = saveCoachThreadUseCase,
       _deleteCoachThreadUseCase = deleteCoachThreadUseCase,
       _preferencesService = preferencesService,
       super(const CoachChatState()) {
    on<CoachChatStartedEvent>(_onStarted);
    on<CoachThreadsLoadedEvent>(_onThreadsLoaded);
    on<CoachThreadSelectedEvent>(_onThreadSelected);
    on<CoachThreadDeletedEvent>(_onThreadDeleted);
    on<CoachNewChatStartedEvent>(_onNewChatStarted);
    on<CoachMessageSentEvent>(_onMessageSent);
    on<CoachBookmarkToggledEvent>(_onBookmarkToggled);
  }

  final SendCoachMessageUseCase _sendCoachMessageUseCase;
  final GetCoachThreadsUseCase? _getCoachThreadsUseCase;
  final SaveCoachThreadUseCase? _saveCoachThreadUseCase;
  final DeleteCoachThreadUseCase? _deleteCoachThreadUseCase;
  final AppPreferencesService? _preferencesService;

  Future<void> _onStarted(
    CoachChatStartedEvent event,
    Emitter<CoachChatState> emit,
  ) async {
    // 1. Load real saved conversation threads
    var threads = state.threads;
    if (_getCoachThreadsUseCase != null) {
      final threadsResult = await _getCoachThreadsUseCase(const NoParams());
      threadsResult.fold(
        (_) {},
        (loadedThreads) => threads = loadedThreads,
      );
    }

    var resolvedThreadId = event.threadId;
    var initialMessages = <CoachChatMessage>[];

    if (event.forceNewThread) {
      resolvedThreadId = 'thread-${DateTime.now().millisecondsSinceEpoch}';
      if (_preferencesService != null) {
        unawaited(_preferencesService.setCoachThreadId(resolvedThreadId));
      }
    } else if (resolvedThreadId != null) {
      final found = threads.where((t) => t.id == resolvedThreadId).firstOrNull;
      if (found != null) {
        initialMessages = found.messages;
      }
    } else {
      resolvedThreadId = _preferencesService?.coachThreadId;
      if (resolvedThreadId == null || resolvedThreadId.isEmpty) {
        resolvedThreadId = 'thread-${DateTime.now().millisecondsSinceEpoch}';
        if (_preferencesService != null) {
          unawaited(_preferencesService.setCoachThreadId(resolvedThreadId));
        }
      } else {
        final found = threads
            .where((t) => t.id == resolvedThreadId)
            .firstOrNull;
        if (found != null) {
          initialMessages = found.messages;
        }
      }
    }

    emit(
      state.copyWith(
        threads: threads,
        threadId: resolvedThreadId,
        messages: initialMessages,
      ),
    );

    final initial = event.initialQuestion?.trim();
    if (initial != null && initial.isNotEmpty) {
      add(CoachMessageSentEvent(initial));
    }
  }

  Future<void> _onThreadsLoaded(
    CoachThreadsLoadedEvent event,
    Emitter<CoachChatState> emit,
  ) async {
    if (_getCoachThreadsUseCase == null) return;
    final result = await _getCoachThreadsUseCase(const NoParams());
    result.fold(
      (_) {},
      (threads) => emit(state.copyWith(threads: threads)),
    );
  }

  void _onThreadSelected(
    CoachThreadSelectedEvent event,
    Emitter<CoachChatState> emit,
  ) {
    final thread = state.threads
        .where((t) => t.id == event.threadId)
        .firstOrNull;
    if (thread != null) {
      if (_preferencesService != null) {
        unawaited(_preferencesService.setCoachThreadId(thread.id));
      }
      emit(
        state.copyWith(
          threadId: thread.id,
          messages: thread.messages,
          hasActiveRedFlag: false,
          clearError: true,
          status: BaseStatus.success,
        ),
      );
    }
  }

  Future<void> _onThreadDeleted(
    CoachThreadDeletedEvent event,
    Emitter<CoachChatState> emit,
  ) async {
    if (_deleteCoachThreadUseCase != null) {
      await _deleteCoachThreadUseCase(event.threadId);
    }
    final updatedThreads = state.threads
        .where((t) => t.id != event.threadId)
        .toList();
    emit(state.copyWith(threads: updatedThreads));
  }

  void _onNewChatStarted(
    CoachNewChatStartedEvent event,
    Emitter<CoachChatState> emit,
  ) {
    final newThreadId = 'thread-${DateTime.now().millisecondsSinceEpoch}';
    if (_preferencesService != null) {
      unawaited(_preferencesService.setCoachThreadId(newThreadId));
    }

    emit(
      state.copyWith(
        threadId: newThreadId,
        messages: const [],
        hasActiveRedFlag: false,
        clearError: true,
        status: BaseStatus.initial,
      ),
    );

    final initial = event.initialQuestion?.trim();
    if (initial != null && initial.isNotEmpty) {
      add(CoachMessageSentEvent(initial));
    }
  }

  Future<void> _onMessageSent(
    CoachMessageSentEvent event,
    Emitter<CoachChatState> emit,
  ) async {
    final query = event.text.trim();
    if (query.isEmpty) return;

    final now = DateTime.now();
    final userMsg = CoachChatMessage(
      id: 'user-${now.microsecondsSinceEpoch}',
      text: query,
      isUser: true,
      createdAt: now,
    );

    final priorMessages = state.messages;
    final updatedMessages = [...priorMessages, userMsg];

    emit(
      state.copyWith(
        status: BaseStatus.loading,
        messages: updatedMessages,
        clearError: true,
      ),
    );

    final result = await _sendCoachMessageUseCase(
      SendCoachMessageParams(
        message: query,
        threadId:
            state.threadId ?? 'thread-${DateTime.now().millisecondsSinceEpoch}',
        coachContext: event.coachContext,
        history: priorMessages,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: BaseStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (reply) async {
        final replyNow = DateTime.now();
        final aiMsg = CoachChatMessage(
          id: 'ai-${replyNow.microsecondsSinceEpoch}',
          text: reply.text,
          isUser: false,
          createdAt: replyNow,
          isRedFlag: reply.isRedFlag,
          suggestedAction: reply.suggestedAction,
        );

        final allMessages = [...updatedMessages, aiMsg];
        final activeThreadId =
            state.threadId ?? 'thread-${replyNow.millisecondsSinceEpoch}';

        // Derive title from first user query in conversation
        final firstUserMsg =
            allMessages.where((m) => m.isUser).firstOrNull?.text ?? query;
        final title = firstUserMsg.length > 55
            ? '${firstUserMsg.substring(0, 52)}...'
            : firstUserMsg;

        final updatedThread = CoachThread(
          id: activeThreadId,
          title: title,
          updatedAt: replyNow,
          messages: allMessages,
        );

        // Persist real conversation thread
        if (_saveCoachThreadUseCase != null) {
          unawaited(_saveCoachThreadUseCase(updatedThread));
        }

        // Update in-memory threads list with updated thread at index 0
        final updatedThreads = <CoachThread>[
          updatedThread,
          ...state.threads.where((t) => t.id != activeThreadId),
        ];

        emit(
          state.copyWith(
            status: BaseStatus.success,
            messages: allMessages,
            threads: updatedThreads,
            threadId: activeThreadId,
            hasActiveRedFlag: state.hasActiveRedFlag || reply.isRedFlag,
          ),
        );
      },
    );
  }

  void _onBookmarkToggled(
    CoachBookmarkToggledEvent event,
    Emitter<CoachChatState> emit,
  ) {
    emit(state.copyWith(isBookmarked: !state.isBookmarked));
  }
}
