// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/coach/coach_injection.dart';
import 'package:kora/features/coach/data/datasources/coach_remote_datasource.dart';
import 'package:kora/features/coach/data/repositories/coach_repository_impl.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';
import 'package:kora/features/coach/domain/usecases/send_coach_message_usecase.dart';
import 'package:kora/features/coach/presentation/bloc/coach_chat_bloc.dart';
import 'package:kora/features/coach/presentation/bloc/coach_chat_event.dart';
import 'package:kora/features/coach/presentation/bloc/coach_chat_state.dart';

/// Interactive AI Skin Coach chat conversation screen conforming to C14,
/// connected to `POST /api/coach/chat` via [CoachChatBloc].
class CoachChatPage extends StatelessWidget {
  /// Creates a [CoachChatPage] with optional [initialQuestion] and [bloc].
  const CoachChatPage({
    super.key,
    this.initialQuestion,
    this.bloc,
  });

  /// Optional initial question pre-filled or sent upon opening.
  final String? initialQuestion;

  /// Optional injected [CoachChatBloc] for testing.
  final CoachChatBloc? bloc;

  CoachChatBloc _resolveBloc() {
    if (bloc != null) return bloc!;
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<CoachChatBloc>()) {
      initCoachInjection(getIt);
    }
    if (getIt.isRegistered<CoachChatBloc>()) {
      return getIt<CoachChatBloc>();
    }
    return CoachChatBloc(
      sendCoachMessageUseCase: const SendCoachMessageUseCase(
        CoachRepositoryImpl(
          remoteDataSource: CoachRemoteDataSourceImpl(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CoachChatBloc>(
      create: (_) =>
          _resolveBloc()
            ..add(CoachChatStartedEvent(initialQuestion: initialQuestion)),
      child: const _CoachChatView(),
    );
  }
}

class _CoachChatView extends StatefulWidget {
  const _CoachChatView();

  @override
  State<_CoachChatView> createState() => _CoachChatViewState();
}

class _CoachChatViewState extends State<_CoachChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedQuestions = const [
    'How to improve rough skin texture after acne?',
    'Nighttime routine for post-acne spot reduction?',
    'Skincare layering mistakes you should know for acne?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    unawaited(
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }),
    );
  }

  void _sendQuestion(String text) {
    final query = text.trim();
    if (query.isEmpty) return;

    _textController.clear();
    context.read<CoachChatBloc>().add(CoachMessageSentEvent(query));
    _scrollToBottom();
  }

  void _handleSuggestedAction(
    BuildContext context,
    CoachSuggestedAction action,
  ) {
    switch (action.type) {
      case 'log_scan':
        unawaited(context.push(AppRoutes.scanGuide));
      case 'view_experiment':
        unawaited(context.push(AppRoutes.experimentNew));
      case 'routine':
        context.go(AppRoutes.routine);
      default:
        _sendQuestion(action.label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppGreyColors.white,
      body: SafeArea(
        child: BlocConsumer<CoachChatBloc, CoachChatState>(
          listener: (context, state) {
            if (state.status == BaseStatus.success ||
                state.status == BaseStatus.loading) {
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildTopBar(context, state),
                if (state.hasActiveRedFlag) _buildRedFlagBanner(),
                if (state.status == BaseStatus.failure &&
                    state.errorMessage != null)
                  _buildErrorBanner(state.errorMessage!),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    children: [
                      _buildSuggestedQuestions(),
                      const SizedBox(height: 16),
                      ...state.messages.map(
                        (msg) => _buildMessageBubble(context, msg),
                      ),
                      if (state.status == BaseStatus.loading)
                        _buildTypingIndicator(),
                    ],
                  ),
                ),
                _buildInputBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRedFlagBanner() {
    return Semantics(
      container: true,
      label: 'Medical safety alert: consult a physician',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.error50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error300),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.medical_services_outlined,
              color: AppColors.error600,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Symptoms mentioned require professional evaluation. Please consult a physician or dermatologist.',
                style: AppTypography.bodyXsSemiBold.copyWith(
                  color: AppColors.error700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.secondary700,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyXsMedium.copyWith(
                color: AppColors.secondary800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CoachChatState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Back',
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.grey1050,
                size: 28,
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go(AppRoutes.coach);
                }
              },
            ),
          ),
          Semantics(
            button: true,
            label: 'Bookmark conversation',
            child: IconButton(
              icon: Icon(
                state.isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: state.isBookmarked
                    ? AppColors.primary700
                    : AppColors.grey1050,
                size: 24,
              ),
              onPressed: () {
                context.read<CoachChatBloc>().add(
                  const CoachBookmarkToggledEvent(),
                );
              },
            ),
          ),
          const Spacer(),
          Semantics(
            button: true,
            label: 'Close chat',
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.grey1050,
                size: 24,
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _suggestedQuestions.map((question) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _sendQuestion(question),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary100,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: AppTypography.bodyMSemiBold.copyWith(
                          color: AppColors.primary900,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary700,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageBubble(BuildContext context, CoachChatMessage message) {
    final isUser = message.isUser;
    final action = message.suggestedAction;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary700
                    : (message.isRedFlag
                          ? AppColors.error50
                          : AppColors.grey50),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: message.isRedFlag
                            ? AppColors.error300
                            : AppColors.grey300,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey300.withAlpha(60),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: AppTypography.bodyMRegular.copyWith(
                  color: isUser
                      ? AppColors.grey50
                      : (message.isRedFlag
                            ? AppColors.error800
                            : AppColors.grey1050),
                  height: 1.45,
                ),
              ),
            ),
            if (!isUser && action != null) ...[
              const SizedBox(height: 8),
              Semantics(
                button: true,
                label: action.label,
                child: InkWell(
                  onTap: () => _handleSuggestedAction(context, action),
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.primary300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: AppColors.primary700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          action.label,
                          style: AppTypography.bodyXsSemiBold.copyWith(
                            color: AppColors.primary900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary700,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Amie is thinking...',
                style: AppTypography.bodyXsMedium.copyWith(
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: 30,
              minLines: 1,
              style: AppTypography.bodySRegular.copyWith(
                color: AppColors.grey1050,
              ),
              decoration: InputDecoration(
                hintText: 'Write your question...',
                hintStyle: AppTypography.bodySRegular.copyWith(
                  color: AppColors.grey600,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColors.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: const BorderSide(color: AppColors.primary700),
                ),
              ),
              onSubmitted: _sendQuestion,
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: 'Send question',
            child: InkWell(
              onTap: () => _sendQuestion(_textController.text),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary700,
                ),
                child: const Center(
                  child: Icon(
                    Icons.near_me_rounded,
                    color: AppColors.grey50,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
