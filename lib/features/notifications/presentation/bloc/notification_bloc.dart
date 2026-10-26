// ignore_for_file: document_ignores, prefer_initializing_formals

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/enums/status.dart';
import 'package:kora/core/services/notification_permission_service.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/notifications/domain/usecases/dispatch_notification_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/get_notification_preferences_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/handle_notification_tap_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/record_notification_ignored_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/request_notification_permission_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/schedule_trial_reminder_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/schedule_weekly_scan_reminder_usecase.dart';
import 'package:kora/features/notifications/domain/usecases/update_notification_preferences_usecase.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_event.dart';
import 'package:kora/features/notifications/presentation/bloc/notification_state.dart';

/// Orchestrates notification business usecases, preferences synchronization,
/// and authorization lifecycle across the application.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  /// Creates a [NotificationBloc] instance.
  NotificationBloc({
    required GetNotificationPreferencesUseCase getPreferences,
    required UpdateNotificationPreferencesUseCase updatePreferences,
    required ScheduleWeeklyScanReminderUseCase scheduleWeeklyScanReminder,
    required ScheduleTrialReminderUseCase scheduleTrialReminder,
    required DispatchNotificationUseCase dispatchNotification,
    required HandleNotificationTapUseCase handleNotificationTap,
    required RecordNotificationIgnoredUseCase recordNotificationIgnored,
    required RequestNotificationPermissionUseCase requestPermission,
    required NotificationPermissionService permissionService,
  }) : _getPreferences = getPreferences,
       _updatePreferences = updatePreferences,
       _scheduleWeeklyScanReminder = scheduleWeeklyScanReminder,
       _scheduleTrialReminder = scheduleTrialReminder,
       _dispatchNotification = dispatchNotification,
       _handleNotificationTap = handleNotificationTap,
       _recordNotificationIgnored = recordNotificationIgnored,
       _requestPermission = requestPermission,
       _permissionService = permissionService,
       super(const NotificationState()) {
    on<NotificationStarted>(_onStarted);
    on<NotificationPermissionRequested>(_onPermissionRequested);
    on<NotificationWeeklyReminderConfigured>(_onWeeklyReminderConfigured);
    on<NotificationTrialReminderScheduled>(_onTrialReminderScheduled);
    on<NotificationPreferencesUpdated>(_onPreferencesUpdated);
    on<NotificationOpened>(_onNotificationOpened);
    on<NotificationIgnored>(_onNotificationIgnored);
    on<NotificationDispatched>(_onNotificationDispatched);
  }

  final GetNotificationPreferencesUseCase _getPreferences;
  final UpdateNotificationPreferencesUseCase _updatePreferences;
  final ScheduleWeeklyScanReminderUseCase _scheduleWeeklyScanReminder;
  final ScheduleTrialReminderUseCase _scheduleTrialReminder;
  final DispatchNotificationUseCase _dispatchNotification;
  final HandleNotificationTapUseCase _handleNotificationTap;
  final RecordNotificationIgnoredUseCase _recordNotificationIgnored;
  final RequestNotificationPermissionUseCase _requestPermission;
  final NotificationPermissionService _permissionService;

  Future<void> _onStarted(
    NotificationStarted event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: BaseStatus.loading));

    final isGranted = await _permissionService.isPermissionGranted();
    final isPermanentlyDenied = await _permissionService.isPermanentlyDenied();

    final result = await _getPreferences(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          isPermissionGranted: isGranted,
          isPermanentlyDenied: isPermanentlyDenied,
          errorMessage: failure.message,
        ),
      ),
      (preferences) => emit(
        state.copyWith(
          status: BaseStatus.success,
          isPermissionGranted: isGranted,
          isPermanentlyDenied: isPermanentlyDenied,
          preferences: preferences,
        ),
      ),
    );
  }

  Future<void> _onPermissionRequested(
    NotificationPermissionRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: BaseStatus.loading));

    final permResult = await _requestPermission(const NoParams());

    await permResult.fold(
      (failure) async {
        final permanentlyDenied = await _permissionService
            .isPermanentlyDenied();
        emit(
          state.copyWith(
            status: BaseStatus.failure,
            isPermissionGranted: false,
            isPermanentlyDenied: permanentlyDenied,
            errorMessage: failure.message,
          ),
        );
      },
      (isGranted) async {
        if (!isGranted) {
          final permanentlyDenied = await _permissionService
              .isPermanentlyDenied();
          emit(
            state.copyWith(
              status: BaseStatus.success,
              isPermissionGranted: false,
              isPermanentlyDenied: permanentlyDenied,
            ),
          );
          return;
        }

        // Permission granted
        if (event.scheduleScanReminder) {
          final scheduleResult = await _scheduleWeeklyScanReminder(
            ScheduleWeeklyScanParams(
              dayOfWeek: state.preferences.preferredDayOfWeek,
              hour: state.preferences.preferredHour,
              minute: state.preferences.preferredMinute,
            ),
          );

          scheduleResult.fold(
            (failure) => emit(
              state.copyWith(
                status: BaseStatus.failure,
                isPermissionGranted: true,
                errorMessage: failure.message,
              ),
            ),
            (_) => emit(
              state.copyWith(
                status: BaseStatus.success,
                isPermissionGranted: true,
                preferences: state.preferences.copyWith(isEnabled: true),
              ),
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: BaseStatus.success,
              isPermissionGranted: true,
            ),
          );
        }
      },
    );
  }

  Future<void> _onWeeklyReminderConfigured(
    NotificationWeeklyReminderConfigured event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: BaseStatus.loading));

    final result = await _scheduleWeeklyScanReminder(
      ScheduleWeeklyScanParams(
        dayOfWeek: event.dayOfWeek ?? state.preferences.preferredDayOfWeek,
        hour: event.hour ?? state.preferences.preferredHour,
        minute: event.minute ?? state.preferences.preferredMinute,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updatedPrefs = state.preferences.copyWith(
          preferredDayOfWeek:
              event.dayOfWeek ?? state.preferences.preferredDayOfWeek,
          preferredHour: event.hour ?? state.preferences.preferredHour,
          preferredMinute: event.minute ?? state.preferences.preferredMinute,
          isEnabled: true,
        );
        emit(
          state.copyWith(
            status: BaseStatus.success,
            preferences: updatedPrefs,
          ),
        );
      },
    );
  }

  Future<void> _onTrialReminderScheduled(
    NotificationTrialReminderScheduled event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _scheduleTrialReminder(
      ScheduleTrialReminderParams(trialEndDate: event.trialEndDate),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: BaseStatus.success)),
    );
  }

  Future<void> _onPreferencesUpdated(
    NotificationPreferencesUpdated event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: BaseStatus.loading));

    final result = await _updatePreferences(
      UpdatePreferencesParams(event.preferences),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: BaseStatus.success,
          preferences: event.preferences,
        ),
      ),
    );
  }

  Future<void> _onNotificationOpened(
    NotificationOpened event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _handleNotificationTap(
      HandleTapParams(rawPayload: event.rawPayload),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (payload) {
        if (payload != null) {
          emit(
            state.copyWith(
              status: BaseStatus.success,
              lastOpenedPayload: payload,
              preferences: state.preferences.copyWith(
                consecutiveIgnoredCount: 0,
                frequencyMultiplier: 1,
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _onNotificationIgnored(
    NotificationIgnored event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _recordNotificationIgnored(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (updatedPrefs) => emit(
        state.copyWith(
          status: BaseStatus.success,
          preferences: updatedPrefs,
        ),
      ),
    );
  }

  Future<void> _onNotificationDispatched(
    NotificationDispatched event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _dispatchNotification(
      DispatchNotificationParams(
        payload: event.payload,
        scheduledTime: event.scheduledTime,
        isUserExplicitChoice: event.isUserExplicitChoice,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BaseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: BaseStatus.success)),
    );
  }
}
