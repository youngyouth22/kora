// ignore_for_file: document_ignores, one_member_abstracts, lines_longer_than_80_chars, prefer_initializing_formals

import 'package:kora/core/network/api_endpoints.dart';
import 'package:kora/core/network/kora_ai_api_client.dart';
import 'package:kora/features/coach/data/models/coach_chat_models.dart';
import 'package:kora/features/coach/domain/entities/coach_chat_entities.dart';

/// Remote datasource contract for the Kora AI Skin Coach.
abstract class CoachRemoteDataSource {
  /// Dispatches a chat message to the Kora AI backend and returns [CoachReplyModel].
  Future<CoachReplyModel> sendMessage({
    required String message,
    required String threadId,
    CoachContext? coachContext,
    List<CoachChatMessage>? history,
  });
}

/// Production implementation calling Mastra `skinCoach` agent on Render with
/// local red-flag safety detection and offline resilience.
class CoachRemoteDataSourceImpl implements CoachRemoteDataSource {
  /// Creates a [CoachRemoteDataSourceImpl].
  const CoachRemoteDataSourceImpl({
    KoraAiApiClient? aiApiClient,
  }) : _aiApiClient = aiApiClient;

  final KoraAiApiClient? _aiApiClient;

  @override
  Future<CoachReplyModel> sendMessage({
    required String message,
    required String threadId,
    CoachContext? coachContext,
    List<CoachChatMessage>? history,
  }) async {
    // 1. Immediate local emergency red-flag safety filter
    final redFlagReply = _checkRedFlag(message);
    if (redFlagReply != null) {
      return redFlagReply;
    }

    final client = _aiApiClient;
    if (client != null && await client.isConfigured()) {
      try {
        final messagesList = <Map<String, String>>[
          if (history != null)
            for (final m in history)
              {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              },
          {
            'role': 'user',
            'content': message,
          },
        ];

        final requestData = <String, dynamic>{
          'messages': messagesList,
          'threadId': threadId,
          if (coachContext != null) 'coachContext': coachContext.toJson(),
        };

        final responseJson = await client.post(
          ApiEndpoints.coachChat,
          data: requestData,
        );

        return CoachReplyModel.fromJson(responseJson);
      } on Object {
        // Fallback to local heuristic answer when Render instance is waking up, offline, or times out
        return _synthesizeFallbackReply(message);
      }
    }

    // Resilient local fallback when offline or before MASTRA_API_SECRET is set.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _synthesizeFallbackReply(message);
  }

  static CoachReplyModel? _checkRedFlag(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('bleed') ||
        lower.contains('saign') ||
        lower.contains('swelling') ||
        lower.contains('gonfl') ||
        lower.contains('mole') ||
        lower.contains('grain de beauté') ||
        lower.contains('severe pain') ||
        lower.contains('douleur aiguë') ||
        lower.contains('infection')) {
      return const CoachReplyModel(
        text: 'Your symptoms require attention from a qualified healthcare professional or dermatologist. Please pause active skincare products and consult a doctor promptly.',
        isRedFlag: true,
      );
    }
    return null;
  }

  static CoachReplyModel _synthesizeFallbackReply(String query) {
    final lower = query.toLowerCase();

    if (lower.contains('texture')) {
      return const CoachReplyModel(
        text: 'To refine rough post-breakout texture without compromising your barrier, focus on mild chemical exfoliation like PHA or lactic acid 1-2 times weekly, paired with ceramide-rich hydration.',
        suggestedAction: CoachSuggestedActionModel(
          type: 'log_scan',
          label: 'Run a quick texture scan',
          payload: {'reason': 'texture_check'},
        ),
      );
    } else if (lower.contains('spot') || lower.contains('dark')) {
      return const CoachReplyModel(
        text: 'For post-blemish spots, a nightly regimen with Niacinamide (2-5%) and Azelaic Acid helps restore tone balance. Remember broad-spectrum SPF every morning to prevent darkening.',
        suggestedAction: CoachSuggestedActionModel(
          type: 'view_experiment',
          label: 'Start a spot fading test',
          payload: {'concern': 'age_spot'},
        ),
      );
    } else if (lower.contains('layer') || lower.contains('mistake')) {
      return const CoachReplyModel(
        text: 'A common layering mistake is applying actives before hydration or mixing low-pH acids with retinoids. Apply from thinnest texture to thickest, allowing each step to absorb.',
      );
    } else if (lower.contains('sensitive') || lower.contains('tiraille')) {
      return const CoachReplyModel(
        text: 'For sensitive skin, prioritize centella asiatica, madecassoside, and hyaluronic acid, while steering clear of added fragrance and drying alcohols.',
        suggestedAction: CoachSuggestedActionModel(
          type: 'log_scan',
          label: 'Check hydration with a scan',
          payload: {'reason': 'hydration_check'},
        ),
      );
    }

    return const CoachReplyModel(
      text: 'Supporting your skin barrier with consistent hydration, gentle non-foaming cleansing, and daily SPF 50 will help maintain balance. Would you like to check your current skin score?',
      suggestedAction: CoachSuggestedActionModel(
        type: 'log_scan',
        label: 'Start a weekly skin scan',
        payload: {'reason': 'general_check'},
      ),
    );
  }
}
