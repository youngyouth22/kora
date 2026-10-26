import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/constants/mascot_pose.dart';
import 'package:kora/common/image_resources.dart';
import 'package:kora/common/widgets/custom_bottom_sheet.dart';
import 'package:kora/common/widgets/mascot_illustration.dart';

/// Opens the full-height AI Skin Coach modal bottom sheet with PageView
/// navigation.
Future<T?> showCoachBottomSheet<T>(
  BuildContext context, {
  String? initialQuestion,
}) {
  final mediaQuery = MediaQuery.of(context);
  final statusBarHeight = mediaQuery.viewPadding.top > 0
      ? mediaQuery.viewPadding.top
      : (mediaQuery.padding.top > 0 ? mediaQuery.padding.top : 24.0);
  // Sheet takes the whole screen height except only the status bar:
  final sheetHeight = mediaQuery.size.height - statusBarHeight;

  return showCustomModalBottomSheet<T>(
    context: context,
    height: sheetHeight,
    content: CoachBottomSheetContent(initialQuestion: initialQuestion),
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
  });

  /// Optional initial question to immediately pass into the chat.
  final String? initialQuestion;

  @override
  State<CoachBottomSheetContent> createState() =>
      _CoachBottomSheetContentState();
}

/// Backward compatibility alias.
typedef CoachBottomSheet = CoachBottomSheetContent;

class _CoachBottomSheetContentState extends State<CoachBottomSheetContent> {
  late final PageController _pageController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _messages = [];
  bool _isBookmarked = false;

  final List<String> _quickPrompts = const [
    '✨ Why am I getting small breakouts lately?',
    '🌿 What ingredients suit sensitive skin?',
    '🧴 Build a routine for combination skin',
    '🌙 How to improve skin texture over time',
  ];

  final List<Map<String, String>> _historyItems = const [
    {
      'title': '🌿 Post-acne care routine suggestion',
      'date': 'Nov 9',
    },
    {
      'title': '☀️ Morning routine update',
      'date': 'Nov 8',
    },
  ];

  final List<String> _suggestedQuestions = const [
    'How to improve rough skin texture after acne?',
    'Nighttime routine for post-acne spot reduction?',
    'Skincare layering mistakes you should know for acne?',
  ];

  @override
  void initState() {
    super.initState();
    final startAtChat =
        widget.initialQuestion != null &&
        widget.initialQuestion!.trim().isNotEmpty;
    _currentPage = startAtChat ? 1 : 0;
    _pageController = PageController(initialPage: _currentPage);

    if (startAtChat) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendQuestion(widget.initialQuestion!.trim());
      });
    }
  }

  @override
  void dispose() {
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
    unawaited(
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
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

    setState(() {
      _messages.add({
        'isUser': true,
        'text': query,
      });
    });
    _textController.clear();
    _scrollToBottom();

    unawaited(
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        final response = _generateCoachResponse(query);
        setState(() {
          _messages.add({
            'isUser': false,
            'text': response,
          });
        });
        _scrollToBottom();
      }),
    );
  }

  String _generateCoachResponse(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('texture')) {
      return 'To refine rough post-breakout texture without compromising '
          'your barrier, focus on mild chemical exfoliation like PHA or '
          'lactic acid 1-2 times weekly, paired with ceramide-rich hydration.';
    } else if (lower.contains('spot') || lower.contains('dark')) {
      return 'For post-blemish spots, a nightly regimen with Niacinamide '
          '(2-5%) and Azelaic Acid helps restore tone balance. Remember '
          'broad-spectrum SPF every morning to prevent darkening.';
    } else if (lower.contains('layer') || lower.contains('mistake')) {
      return 'A common layering mistake is applying actives before hydration '
          'or mixing low-pH acids with retinoids. Apply from thinnest texture '
          'to thickest, allowing each step to absorb.';
    } else if (lower.contains('sensitive')) {
      return 'For sensitive skin, prioritize centella asiatica, madecassoside, '
          'and hyaluronic acid, while steering clear of added fragrance '
          'and drying alcohols.';
    }
    return 'I noted your question! Supporting your skin barrier with '
        'consistent hydration, gentle non-foaming cleansing, and daily SPF 50 '
        'will help maintain balance. Would you like to log this?';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentPage > 0) {
          _navigateToHub();
        }
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _buildHubPage(context),
            _buildChatPage(context),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // PAGE 0: AI COMPANION HUB
  // ===========================================================================
  Widget _buildHubPage(BuildContext context) {
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
            _buildHubTopBar(context),
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
                    _buildHistorySection(context),
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

  Widget _buildHubTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Bookmark conversation hub',
            child: IconButton(
              icon: SvgPicture.asset(
                _isBookmarked
                    ? ImageResources.bookMarkIcon
                    : ImageResources.bookMarkIcon,
                colorFilter: ColorFilter.mode(
                  _isBookmarked ? AppColors.primary700 : AppColors.grey1050,
                  BlendMode.srcIn,
                ),
                height: 24,
              ),
              onPressed: () {
                setState(() => _isBookmarked = !_isBookmarked);
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
      spacing: 12,
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
            _navigateToChat(cleanPrompt);
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

  Widget _buildHistorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: 12,
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
              onTap: _navigateToChat,
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
        ..._historyItems.map((item) {
          final title = item['title']!;
          final date = item['date']!;

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
                  onTap: () => _navigateToChat(title),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      spacing: 4,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  style: AppTypography.bodyMMedium.copyWith(
                                    color: AppColors.grey1050,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Text(
                                date,
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
          onTap: _navigateToChat,
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
  Widget _buildChatPage(BuildContext context) {
    return Scaffold(
      backgroundColor: AppGreyColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildChatTopBar(context),
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
                  ..._messages.map(_buildMessageBubble),
                ],
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTopBar(BuildContext context) {
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
                _isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: _isBookmarked
                    ? AppColors.primary700
                    : AppColors.grey1050,
                size: 24,
              ),
              onPressed: () {
                setState(() => _isBookmarked = !_isBookmarked);
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

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary700 : AppColors.grey50,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 18),
            ),
            border: isUser ? null : Border.all(color: AppColors.grey300),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey300.withAlpha(60),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: AppTypography.bodySRegular.copyWith(
              color: isUser ? AppColors.grey50 : AppColors.grey1050,
              height: 1.45,
            ),
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
