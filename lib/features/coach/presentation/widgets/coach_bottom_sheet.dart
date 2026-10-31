// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/common/widgets/custom_bottom_sheet.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';
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

/// Opens the full-height AI Skin Coach modal bottom sheet with PageView
/// navigation.
Future<T?> showCoachBottomSheet<T>(
  BuildContext context, {
  String? initialQuestion,
  bool forceNewThread = false,
}) {
  final mediaQuery = MediaQuery.of(context);
  final statusBarHeight = mediaQuery.viewPadding.top > 0
      ? mediaQuery.viewPadding.top
      : (mediaQuery.padding.top > 0 ? mediaQuery.padding.top : 24.0);
  final sheetHeight = mediaQuery.size.height - statusBarHeight;

  return showCustomModalBottomSheet<T>(
    context: context,
    height: sheetHeight,
    content: CoachBottomSheetContent(
      initialQuestion: initialQuestion,
      forceNewThread: forceNewThread,
    ),
    showDragHandle: false,
    isScrollable: false,
    enableDrag: false,
    isDismissible: false,
    useBlur: false,
    barrierColor: AppGreyColors.shade400,
    backgroundColor: AppGreyColors.white,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
    contentPadding: EdgeInsets.zero,
  );
}

/// Full-height content hosting the AI Skincare Companion Hub (Page 0)
/// and the active Chat Conversation (Page 1) inside an optimized [PageView].
class CoachBottomSheetContent extends StatefulWidget {
  /// Creates a [CoachBottomSheetContent].
  const CoachBottomSheetContent({
    super.key,
    this.initialQuestion,
    this.forceNewThread = false,
    this.bloc,
  });

  /// Optional initial question to immediately pass into the chat.
  final String? initialQuestion;

  /// Whether to force creation of a new conversation thread.
  final bool forceNewThread;

  /// Optional injected [CoachChatBloc] for testing.
  final CoachChatBloc? bloc;

  @override
  State<CoachBottomSheetContent> createState() =>
      _CoachBottomSheetContentState();
}

/// Backward compatibility alias.
typedef CoachBottomSheet = CoachBottomSheetContent;

class _CoachBottomSheetContentState extends State<CoachBottomSheetContent> {
  late final PageController _pageController;
  late final CoachChatBloc _bloc;
  late final bool _ownsBloc;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  int _currentPage = 0;

  final List<String> _quickPrompts = const [
    '✨ Why am I getting small breakouts lately?',
    '🌿 What ingredients suit sensitive skin?',
    '🧴 Build a routine for combination skin',
    '🌙 How to improve skin texture over time',
  ];

  final List<String> _suggestedQuestions = const [
    'How to improve rough skin texture after acne?',
    'Nighttime routine for post-acne spot reduction?',
    'Skincare layering mistakes you should know for acne?',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bloc != null) {
      _bloc = widget.bloc!;
      _ownsBloc = false;
    } else {
      final getIt = GetIt.instance;
      if (!getIt.isRegistered<CoachChatBloc>()) {
        initCoachInjection(getIt);
      }
      if (getIt.isRegistered<CoachChatBloc>()) {
        _bloc = getIt<CoachChatBloc>();
        _ownsBloc = true;
      } else {
        _bloc = CoachChatBloc(
          sendCoachMessageUseCase: const SendCoachMessageUseCase(
            CoachRepositoryImpl(
              remoteDataSource: CoachRemoteDataSourceImpl(),
            ),
          ),
        );
        _ownsBloc = true;
      }
    }

    final startAtChat =
        widget.initialQuestion != null &&
        widget.initialQuestion!.trim().isNotEmpty;
    _currentPage = startAtChat ? 1 : 0;
    _pageController = PageController(initialPage: _currentPage);

    _bloc.add(
      CoachChatStartedEvent(
        initialQuestion: startAtChat ? widget.initialQuestion!.trim() : null,
        forceNewThread: widget.forceNewThread,
      ),
    );
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      unawaited(_bloc.close());
    }
    _pageController.dispose();
    _textController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _navigateToChat([String? prompt]) {
    if (prompt != null && prompt.trim().isNotEmpty) {
      _sendQuestion(prompt.trim());
    }
    setState(() => _currentPage = 1);
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _navigateToHub() {
    setState(() => _currentPage = 0);
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendQuestion(String text) {
    final query = text.trim();
    if (query.isEmpty) return;

    _textController.clear();
    _bloc.add(CoachMessageSentEvent(query));
    _scrollToBottom();
  }

  void _handleSuggestedAction(
    BuildContext context,
    CoachSuggestedAction action,
  ) {
    final type = action.type.toLowerCase();
    if (type.contains('scan')) {
      Navigator.of(context).maybePop();
      try {
        unawaited(context.push(AppRoutes.scanGuide));
      } on Object catch (_) {}
    } else if (type.contains('routine') || type.contains('product')) {
      Navigator.of(context).maybePop();
      try {
        context.go(AppRoutes.routine);
      } on Object catch (_) {}
    } else if (type.contains('experiment') || type.contains('progress')) {
      Navigator.of(context).maybePop();
      try {
        context.go(AppRoutes.progress);
      } on Object catch (_) {}
    } else {
      _sendQuestion(action.label);
    }
  }

  String _formatDate(DateTime date) {
    final localNow = DateTime.now();
    final localDate = date.toLocal();
    final isSameDay =
        localNow.year == localDate.year &&
        localNow.month == localDate.month &&
        localNow.day == localDate.day;
    if (isSameDay) {
      return 'Today';
    }
    final yesterday = localNow.subtract(const Duration(days: 1));
    final isYesterday =
        yesterday.year == localDate.year &&
        yesterday.month == localDate.month &&
        yesterday.day == localDate.day;
    if (isYesterday) {
      return 'Yesterday';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[localDate.month - 1]} ${localDate.day}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CoachChatBloc>.value(
      value: _bloc,
      child: BlocConsumer<CoachChatBloc, CoachChatState>(
        listener: (context, state) {
          if (state.messages.isNotEmpty && _currentPage == 1) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: _currentPage == 0,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (_currentPage > 0) {
                _navigateToHub();
              }
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildHubPage(context, state),
                  _buildChatPage(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // PAGE 0: AI COMPANION HUB
  // ===========================================================================
  Widget _buildHubPage(BuildContext context, CoachChatState state) {
    return Scaffold(
      backgroundColor: AppGreyColors.white,
      resizeToAvoidBottomInset: false,
      floatingActionButton: _buildNewChatFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildHubTopBar(context, state),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMascotHeader(),
                    const SizedBox(height: 32),
                    _buildStartChatSection(context),
                    const SizedBox(height: 32),
                    _buildHistorySection(context, state),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubTopBar(BuildContext context, CoachChatState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Bookmark conversation hub',
            child: IconButton(
              icon: SvgPicture.asset(
                ImageResources.bookMarkIcon,
                colorFilter: ColorFilter.mode(
                  state.isBookmarked
                      ? AppColors.primary700
                      : AppColors.grey1050,
                  BlendMode.srcIn,
                ),
                height: 24,
              ),
              onPressed: () {
                _bloc.add(const CoachBookmarkToggledEvent());
              },
            ),
          ),
          const Spacer(),
          Semantics(
            button: true,
            label: 'Close coach hub',
            child: IconButton(
              icon: SvgPicture.asset(
                ImageResources.cancelIcon,
                colorFilter: const ColorFilter.mode(
                  AppColors.grey1050,
                  BlendMode.srcIn,
                ),
                height: 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 240,
                sigmaY: 40,
                tileMode: TileMode.decal,
              ),
              child: Container(
                width: 80,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(63, 90),
                  ),
                ),
              ),
            ),
            const Center(
              child: MascotIllustration(
                pose: MascotPose.wave,
                size: 130,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Hi I'm Amie,\nyour skincare companion",
          textAlign: TextAlign.center,
          style: AppTypography.h4Medium.copyWith(
            color: AppColors.grey1050,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildStartChatSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            'Start a chat',
            maxLines: 1,
            style: AppTypography.bodyLMedium.copyWith(
              color: AppColors.grey800,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 80,
          ),
          physics: const NeverScrollableScrollPhysics(),
          children: _quickPrompts
              .map(
                (prompt) => _buildPromptCard(
                  prompt: prompt,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPromptCard({
    required String prompt,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPrimaryColors.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppPrimaryColors.shade400.withAlpha(100),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final cleanPrompt = prompt
                .replaceFirst(RegExp(r'^[^\w]+'), '')
                .trim();
            _bloc.add(CoachNewChatStartedEvent(initialQuestion: cleanPrompt));
            _navigateToChat();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              prompt,
              maxLines: 3,
              style: AppTypography.bodyMMedium.copyWith(
                color: AppPrimaryColors.shade800,
                overflow: TextOverflow.ellipsis,
                height: 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, CoachChatState state) {
    final threads = state.threads;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'History',
                style: AppTypography.bodyLMedium.copyWith(
                  color: AppColors.grey800,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (threads.isNotEmpty) {
                  _bloc.add(CoachThreadSelectedEvent(threads.first.id));
                }
                _navigateToChat();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'See all',
                  style: AppTypography.bodyMMedium.copyWith(
                    color: AppColors.primary700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (threads.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppGreyColors.shade400,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppPrimaryColors.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary700,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No chat history yet',
                        style: AppTypography.bodyMMedium.copyWith(
                          color: AppColors.grey1050,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ask Amie a question to get personalized skincare advice.',
                        style: AppTypography.bodySRegular.copyWith(
                          color: AppGreyColors.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...threads.map((thread) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppGreyColors.shade400,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey300.withAlpha(140),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _bloc.add(CoachThreadSelectedEvent(thread.id));
                      _navigateToChat();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    thread.title,
                                    maxLines: 1,
                                    style: AppTypography.bodyMMedium.copyWith(
                                      color: AppColors.grey1050,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(thread.updatedAt),
                                  style: AppTypography.bodySRegular.copyWith(
                                    color: AppGreyColors.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            ImageResources.arrowRight,
                            colorFilter: const ColorFilter.mode(
                              AppGreyColors.shade1050,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildNewChatFab(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Start new chat',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _bloc.add(const CoachNewChatStartedEvent());
            _navigateToChat();
          },
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary700,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary900.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: AppColors.grey50,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'New Chat',
                  style: AppTypography.bodyMSemiBold.copyWith(
                    color: AppColors.grey50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PAGE 1: CHAT CONVERSATION
  // ===========================================================================
  Widget _buildChatPage(BuildContext context, CoachChatState state) {
    return Scaffold(
      backgroundColor: AppGreyColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildChatTopBar(context, state),
            if (state.hasActiveRedFlag) _buildRedFlagBanner(),
            if (state.status == BaseStatus.failure &&
                state.errorMessage != null)
              _buildErrorBanner(state.errorMessage!),
            Expanded(
              child: ListView(
                controller: _chatScrollController,
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

  Widget _buildRedFlagBanner() {
    return Semantics(
      liveRegion: true,
      label: 'Medical safety alert: professional dermatological review advised',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error600,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Safety Alert',
                    style: AppTypography.bodyMSemiBold.copyWith(
                      color: AppColors.error700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your symptoms require attention from a healthcare '
                    'professional or dermatologist. Please pause active '
                    'skincare products and seek medical advice.',
                    style: AppTypography.bodyXsRegular.copyWith(
                      color: AppColors.error700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTopBar(BuildContext context, CoachChatState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Back to companion hub',
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.grey1050,
                size: 28,
              ),
              onPressed: _navigateToHub,
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
                _bloc.add(const CoachBookmarkToggledEvent());
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
              onPressed: () => Navigator.of(context).pop(),
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
    final isRedFlag = message.isRedFlag;
    final action = message.suggestedAction;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary700
                    : (isRedFlag ? AppColors.error50 : AppColors.grey50),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isRedFlag
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
                style: AppTypography.bodySRegular.copyWith(
                  color: isUser
                      ? AppColors.grey50
                      : (isRedFlag ? AppColors.error700 : AppColors.grey1050),
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (!isUser && action != null) ...[
            const SizedBox(height: 8),
            Semantics(
              button: true,
              label: 'Suggested action: ${action.label}',
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.primary50,
                  side: const BorderSide(color: AppColors.primary400),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                onPressed: () => _handleSuggestedAction(context, action),
                icon: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppColors.primary700,
                ),
                label: Text(
                  action.label,
                  style: AppTypography.bodyXsSemiBold.copyWith(
                    color: AppColors.primary900,
                  ),
                ),
              ),
            ),
          ],
        ],
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
      decoration: const BoxDecoration(
        color: AppColors.scaffoldColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
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
