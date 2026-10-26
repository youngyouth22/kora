import 'package:get_it/get_it.dart';
import 'package:kora/core/services/notification_permission_service.dart';
import 'package:kora/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:kora/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:kora/features/notifications/domain/repositories/notification_repository.dart';
import 'package:kora/features/notifications/domain/usecases/dispatch_notification_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/evaluate_notification_rules_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/get_notification_preferences_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/handle_notification_tap_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/record_notification_ignored_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/request_notification_permission_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/schedule_trial_reminder_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/schedule_weekly_scan_reminder_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/update_notification_preferences_usecase.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_bloc.dart';

/// Registers all notification layer dependencies into the GetIt
/// service locator.
void initNotificationsInjection(GetIt sl) {
  // Permission Service
  if (!sl.isRegistered<NotificationPermissionService>()) {
    sl.registerLazySingleton<NotificationPermissionService>(
      () => const DefaultNotificationPermissionService(),
    );
  }

  // Datasources
  if (!sl.isRegistered<NotificationLocalDataSource>()) {
    sl.registerLazySingleton<NotificationLocalDataSource>(
      NotificationLocalDataSourceImpl.new,
    );
  }

  // Domain Rules Evaluator
  if (!sl.isRegistered<EvaluateNotificationRulesUseCase>()) {
    sl.registerLazySingleton(
      () => const EvaluateNotificationRulesUseCase(),
    );
  }

  // Repository
  if (!sl.isRegistered<NotificationRepository>()) {
    sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        localDataSource: sl<NotificationLocalDataSource>(),
        permissionService: sl<NotificationPermissionService>(),
        rulesEvaluator: sl<EvaluateNotificationRulesUseCase>(),
      ),
    );
  }

  // Usecases
  if (!sl.isRegistered<GetNotificationPreferencesUseCase>()) {
    sl.registerLazySingleton(
      () => GetNotificationPreferencesUseCase(sl<NotificationRepository>()),
    );
  }

  if (!sl.isRegistered<UpdateNotificationPreferencesUseCase>()) {
    sl.registerLazySingleton(
      () => UpdateNotificationPreferencesUseCase(sl<NotificationRepository>()),
    );
  }

  if (!sl.isRegistered<ScheduleWeeklyScanReminderUseCase>()) {
    sl.registerLazySingleton(
      () => ScheduleWeeklyScanReminderUseCase(sl<NotificationRepository>()),
    );
  }

  if (!sl.isRegistered<ScheduleTrialReminderUseCase>()) {
    sl.registerLazySingleton(
      () => ScheduleTrialReminderUseCase(sl<NotificationRepository>()),
    );
  }

  if (!sl.isRegistered<DispatchNotificationUseCase>()) {
    sl.registerLazySingleton(
      () => DispatchNotificationUseCase(sl<NotificationRepository>()),
    );
  }

  if (!sl.isRegistered<HandleNotificationTapUseCase>()) {
    sl.registerLazySingleton(
      () => HandleNotificationTapUseCase(sl<NotificationRepository>()),
    );
  }

  if (!sl.isRegistered<RecordNotificationIgnoredUseCase>()) {
    sl.registerLazySingleton(
      () => RecordNotificationIgnoredUseCase(sl<NotificationRepository>()),
    );
  }

  if (!sl.isRegistered<RequestNotificationPermissionUseCase>()) {
    sl.registerLazySingleton(
      () => RequestNotificationPermissionUseCase(sl<NotificationRepository>()),
    );
  }

  // BLoC
  if (!sl.isRegistered<NotificationBloc>()) {
    sl.registerFactory(
      () => NotificationBloc(
        getPreferences: sl<GetNotificationPreferencesUseCase>(),
        updatePreferences: sl<UpdateNotificationPreferencesUseCase>(),
        scheduleWeeklyScanReminder: sl<ScheduleWeeklyScanReminderUseCase>(),
        scheduleTrialReminder: sl<ScheduleTrialReminderUseCase>(),
        dispatchNotification: sl<DispatchNotificationUseCase>(),
        handleNotificationTap: sl<HandleNotificationTapUseCase>(),
        recordNotificationIgnored: sl<RecordNotificationIgnoredUseCase>(),
        requestPermission: sl<RequestNotificationPermissionUseCase>(),
        permissionService: sl<NotificationPermissionService>(),
      ),
    );
  }
}
