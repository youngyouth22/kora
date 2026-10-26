import 'package:get_it/get_it.dart';
import 'package:kora/core/database/app_database.dart';
import 'package:kora/core/database/daos/experiment_dao.dart';
import 'package:kora/core/database/daos/profile_dao.dart';
import 'package:kora/core/database/daos/routine_dao.dart';
import 'package:kora/core/database/daos/scan_dao.dart';
import 'package:kora/core/database/daos/sync_mutation_dao.dart';
import 'package:kora/core/network/network_info.dart';
import 'package:kora/core/network/network_info_impl.dart';
import 'package:kora/core/services/camera_permission_service.dart';
import 'package:kora/core/sync/supabase_sync_driver.dart';
import 'package:kora/core/sync/sync_engine.dart';
import 'package:kora/features/auth/auth_injection.dart';
import 'package:kora/features/experiment/experiment_injection.dart';
import 'package:kora/features/guided_capture/guided_capture_injection.dart';
import 'package:kora/features/notifications/notifications_injection.dart';
import 'package:kora/features/onboarding/data/repositories/user_profile_repository_impl.dart';
import 'package:kora/features/onboarding/domain/repositories/user_profile_repository.dart';
import 'package:kora/features/onboarding/onboarding_injection.dart';
import 'package:kora/features/product_scanner/product_scanner_injection.dart';
import 'package:kora/features/routine/routine_injection.dart';
import 'package:kora/features/skin_analysis/data/repositories/scan_record_repository_impl.dart';
import 'package:kora/features/skin_analysis/domain/repositories/scan_record_repository.dart';
import 'package:kora/features/skin_analysis/skin_analysis_injection.dart';
import 'package:kora/features/splash/splash_injection.dart';
import 'package:kora/features/subscription/subscription_injection.dart';
import 'package:supabase/supabase.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Central entry point to register all application dependencies.
void configureDependencies() {
  // Core Infrastructure: Network & Database
  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(() => const NetworkInfoImpl());
  }

  if (!sl.isRegistered<AppDatabase>()) {
    sl.registerLazySingleton<AppDatabase>(AppDatabase.new);
  }

  // Drift Data Access Objects
  if (!sl.isRegistered<ProfileDao>()) {
    sl.registerLazySingleton<ProfileDao>(() => ProfileDao(sl<AppDatabase>()));
  }

  if (!sl.isRegistered<ScanDao>()) {
    sl.registerLazySingleton<ScanDao>(() => ScanDao(sl<AppDatabase>()));
  }

  if (!sl.isRegistered<RoutineDao>()) {
    sl.registerLazySingleton<RoutineDao>(() => RoutineDao(sl<AppDatabase>()));
  }

  if (!sl.isRegistered<ExperimentDao>()) {
    sl.registerLazySingleton<ExperimentDao>(
      () => ExperimentDao(sl<AppDatabase>()),
    );
  }

  if (!sl.isRegistered<SyncMutationDao>()) {
    sl.registerLazySingleton<SyncMutationDao>(
      () => SyncMutationDao(sl<AppDatabase>()),
    );
  }

  // Sync Engine & Outbox Processor
  if (!sl.isRegistered<RemoteSyncDriver>()) {
    sl.registerLazySingleton<RemoteSyncDriver>(
      () => SupabaseSyncDriver(
        client: sl.isRegistered<SupabaseClient>() ? sl<SupabaseClient>() : null,
      ),
    );
  }

  if (!sl.isRegistered<SyncEngine>()) {
    sl.registerLazySingleton<SyncEngine>(
      () => SyncEngine(
        database: sl<AppDatabase>(),
        mutationDao: sl<SyncMutationDao>(),
        remoteDriver: sl<RemoteSyncDriver>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );
  }

  // Repositories (Offline-First)
  if (!sl.isRegistered<UserProfileRepository>()) {
    sl.registerLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(
        profileDao: sl<ProfileDao>(),
        mutationDao: sl<SyncMutationDao>(),
        syncEngine: sl<SyncEngine>(),
      ),
    );
  }

  if (!sl.isRegistered<ScanRecordRepository>()) {
    sl.registerLazySingleton<ScanRecordRepository>(
      () => ScanRecordRepositoryImpl(
        scanDao: sl<ScanDao>(),
        mutationDao: sl<SyncMutationDao>(),
        syncEngine: sl<SyncEngine>(),
      ),
    );
  }

  if (!sl.isRegistered<CameraPermissionService>()) {
    sl.registerLazySingleton<CameraPermissionService>(
      () => const DefaultCameraPermissionService(),
    );
  }

  initOnboardingInjection(sl);
  initNotificationsInjection(sl);
  initSplashInjection(sl);
  initGuidedCaptureInjection(sl);
  initSkinAnalysisInjection(sl);
  initSubscriptionInjection(sl);
  initAuthInjection(sl);
  initRoutineInjection(sl);
  initProductScannerInjection(sl);
  initExperimentInjection(sl);
}
