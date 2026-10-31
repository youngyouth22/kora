// ignore_for_file: document_ignores, prefer_initializing_formals

import 'dart:convert';

import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/features/coach/data/models/coach_chat_models.dart';

/// Contract for local storage of Kora AI Coach conversation threads.
abstract class CoachLocalDataSource {
  /// Loads all stored conversation threads ordered newest first.
  Future<List<CoachThreadModel>> getThreads();

  /// Retrieves a specific thread by its [threadId].
  Future<CoachThreadModel?> getThread(String threadId);

  /// Saves or updates a conversation [thread].
  Future<void> saveThread(CoachThreadModel thread);

  /// Removes a conversation thread by its [threadId].
  Future<void> deleteThread(String threadId);
}

/// Implementation of [CoachLocalDataSource] backed by [AppPreferencesService].
class CoachLocalDataSourceImpl implements CoachLocalDataSource {
  /// Creates a [CoachLocalDataSourceImpl].
  const CoachLocalDataSourceImpl({
    AppPreferencesService? preferencesService,
  }) : _preferencesService = preferencesService;

  final AppPreferencesService? _preferencesService;

  @override
  Future<List<CoachThreadModel>> getThreads() async {
    final rawJson = _preferencesService?.coachThreadsJson;
    if (rawJson == null || rawJson.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        final threads = <CoachThreadModel>[];
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            threads.add(CoachThreadModel.fromJson(item));
          }
        }
        threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return threads;
      }
    } on Object {
      // In case of corrupt JSON, return empty list gracefully
    }
    return const [];
  }

  @override
  Future<CoachThreadModel?> getThread(String threadId) async {
    final threads = await getThreads();
    for (final t in threads) {
      if (t.id == threadId) return t;
    }
    return null;
  }

  @override
  Future<void> saveThread(CoachThreadModel thread) async {
    final threads = await getThreads();
    final updatedList = <CoachThreadModel>[thread];

    for (final existing in threads) {
      if (existing.id != thread.id) {
        updatedList.add(existing);
      }
    }

    updatedList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final encoded = jsonEncode(
      updatedList.map((t) => t.toJson()).toList(),
    );
    if (_preferencesService != null) {
      await _preferencesService.setCoachThreadsJson(encoded);
    }
  }

  @override
  Future<void> deleteThread(String threadId) async {
    final threads = await getThreads();
    final filtered = threads.where((t) => t.id != threadId).toList();

    final encoded = jsonEncode(
      filtered.map((t) => t.toJson()).toList(),
    );
    if (_preferencesService != null) {
      await _preferencesService.setCoachThreadsJson(encoded);
    }
  }
}
