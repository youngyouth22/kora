import 'package:flutter_test/flutter_test.dart';
import 'package:kora/core/services/app_preferences_service.dart';
import 'package:kora/features/coach/data/datasources/coach_local_datasource.dart';
import 'package:kora/features/coach/data/models/coach_chat_models.dart';

class _FakePreferencesService implements AppPreferencesService {
  String? _threadsJson;
  String? _coachThreadId;

  @override
  String? get coachThreadsJson => _threadsJson;

  @override
  Future<void> setCoachThreadsJson(String jsonString) async {
    _threadsJson = jsonString;
  }

  @override
  String? get coachThreadId => _coachThreadId;

  @override
  Future<void> setCoachThreadId(String threadId) async {
    _coachThreadId = threadId;
  }

  @override
  bool get hasSeenCaptureTips => false;

  @override
  bool get hasSeenProductScanTutorial => false;

  @override
  bool get hasSeenScanGuide => false;

  @override
  bool get isOnboardingCompleted => false;

  @override
  Future<void> clear() async {
    _threadsJson = null;
    _coachThreadId = null;
  }

  @override
  Future<void> setHasSeenCaptureTips({required bool seen}) async {}

  @override
  Future<void> setHasSeenProductScanTutorial({required bool seen}) async {}

  @override
  Future<void> setHasSeenScanGuide({required bool seen}) async {}

  @override
  Future<void> setOnboardingCompleted({required bool completed}) async {}
}

void main() {
  group('CoachLocalDataSource', () {
    late _FakePreferencesService fakePrefs;
    late CoachLocalDataSourceImpl dataSource;

    setUp(() {
      fakePrefs = _FakePreferencesService();
      dataSource = CoachLocalDataSourceImpl(preferencesService: fakePrefs);
    });

    test('returns empty list when no threads stored', () async {
      final threads = await dataSource.getThreads();
      expect(threads, isEmpty);
    });

    test('saves and retrieves threads ordered newest first', () async {
      final t1 = CoachThreadModel(
        id: 'thread-1',
        title: 'First chat',
        updatedAt: DateTime(2026, 10),
      );
      final t2 = CoachThreadModel(
        id: 'thread-2',
        title: 'Second chat',
        updatedAt: DateTime(2026, 10, 2),
      );

      await dataSource.saveThread(t1);
      await dataSource.saveThread(t2);

      final retrieved = await dataSource.getThreads();
      expect(retrieved.length, 2);
      expect(retrieved.first.id, 'thread-2');
      expect(retrieved.last.id, 'thread-1');

      final single = await dataSource.getThread('thread-1');
      expect(single?.title, 'First chat');
    });

    test('deletes thread by ID', () async {
      final t1 = CoachThreadModel(
        id: 'thread-1',
        title: 'First chat',
        updatedAt: DateTime.now(),
      );
      await dataSource.saveThread(t1);
      expect((await dataSource.getThreads()).length, 1);

      await dataSource.deleteThread('thread-1');
      expect(await dataSource.getThreads(), isEmpty);
    });
  });
}
