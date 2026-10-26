// ignore_for_file: document_ignores, prefer_initializing_formals

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/usecase/usecase.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:kora/features/subscription/domain/usecases/check_pro_entitlement_usecase.dart';
import 'package:kora/features/subscription/domain/usecases/get_current_offering_usecase.dart';
import 'package:kora/features/subscription/domain/usecases/purchase_package_usecase.dart';
import 'package:kora/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_state.dart';

/// Orchestrates subscription status verification, offering loading,
/// purchases, and entitlement restoration.
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  /// Creates a [SubscriptionBloc].
  SubscriptionBloc({
    required CheckProEntitlementUseCase checkProEntitlement,
    required GetCurrentOfferingUseCase getCurrentOffering,
    required PurchasePackageUseCase purchasePackage,
    required RestorePurchasesUseCase restorePurchases,
    required SubscriptionRepository repository,
  }) : _checkProEntitlement = checkProEntitlement,
       _getCurrentOffering = getCurrentOffering,
       _purchasePackage = purchasePackage,
       _restorePurchases = restorePurchases,
       _repository = repository,
       super(const SubscriptionState()) {
    on<CheckSubscriptionRequested>(_onCheckSubscriptionRequested);
    on<FetchOfferingRequested>(_onFetchOfferingRequested);
    on<PurchasePackageRequested>(_onPurchasePackageRequested);
    on<RestorePurchasesRequested>(_onRestorePurchasesRequested);
    on<SubscriptionStatusUpdated>(_onSubscriptionStatusUpdated);

    _statusSubscription = _repository.subscriptionStatusStream.listen(
      (status) => add(SubscriptionStatusUpdated(status)),
    );
  }

  final CheckProEntitlementUseCase _checkProEntitlement;
  final GetCurrentOfferingUseCase _getCurrentOffering;
  final PurchasePackageUseCase _purchasePackage;
  final RestorePurchasesUseCase _restorePurchases;
  final SubscriptionRepository _repository;
  StreamSubscription<SubscriptionStatus>? _statusSubscription;

  Future<void> _onCheckSubscriptionRequested(
    CheckSubscriptionRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStepStatus.loading));
    final result = await _checkProEntitlement(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubscriptionStepStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (status) => emit(
        state.copyWith(
          status: SubscriptionStepStatus.success,
          isPro: status.isPro,
          subscriptionStatus: status,
        ),
      ),
    );
  }

  Future<void> _onFetchOfferingRequested(
    FetchOfferingRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStepStatus.loading));
    final result = await _getCurrentOffering(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubscriptionStepStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (offering) {
        final defaultSelected =
            offering.annual ??
            (offering.availablePackages.isNotEmpty
                ? offering.availablePackages.first
                : null);
        emit(
          state.copyWith(
            status: SubscriptionStepStatus.success,
            currentOffering: offering,
            selectedPackage: defaultSelected,
          ),
        );
      },
    );
  }

  Future<void> _onPurchasePackageRequested(
    PurchasePackageRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStepStatus.loading));
    final result = await _purchasePackage(event.package);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubscriptionStepStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (status) => emit(
        state.copyWith(
          status: SubscriptionStepStatus.success,
          isPro: status.isPro,
          subscriptionStatus: status,
        ),
      ),
    );
  }

  Future<void> _onRestorePurchasesRequested(
    RestorePurchasesRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStepStatus.loading));
    final result = await _restorePurchases(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubscriptionStepStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (status) => emit(
        state.copyWith(
          status: SubscriptionStepStatus.success,
          isPro: status.isPro,
          subscriptionStatus: status,
        ),
      ),
    );
  }

  void _onSubscriptionStatusUpdated(
    SubscriptionStatusUpdated event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(
      state.copyWith(
        isPro: event.status.isPro,
        subscriptionStatus: event.status,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    return super.close();
  }
}
