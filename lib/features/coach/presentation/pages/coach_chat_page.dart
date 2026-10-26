import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/core/router/app_routes.dart';

/// Interactive AI Skin Coach chat conversation screen conforming to C14.
class CoachChatPage extends StatefulWidget {
  /// Creates a [CoachChatPage] with optional [initialQuestion].
  const CoachChatPage({
    super.key,
    this.initialQuestion,
  });

  /// Optional initial question pre-filled or sent upon opening.
  final String? initialQuestion;

  @override
  State<CoachChatPage> createState() => _CoachChatPageState();
}

class _CoachChatPageState extends State<CoachChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isBookmarked = false;

  final List<String> _suggestedQuestions = const [
    'How to improve rough skin texture after acne?',
    'Nighttime routine for post-acne spot reduction?',
    'Skincare layering mistakes you should know for acne?',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestion != null &&
        widget.initialQuestion!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendQuestion(widget.initialQuestion!.trim());
      });
    }
  }

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

    setState(() {
      _messages.add({
        'isUser': true,
        'text': query,
      });
    });
    _textController.clear();
    _scrollToBottom();

    // Simulated contextual AI response conforming to non-medical guidelines
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
    return Scaffold(
      backgroundColor: AppGreyColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
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

  Widget _buildTopBar(BuildContext context) {
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
            style: AppTypography.bodyMRegular.copyWith(
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
