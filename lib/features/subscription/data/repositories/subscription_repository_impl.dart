import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:kora/core/constants/subscription_constants.dart';
import 'package:kora/core/error/failures.dart';
import 'package:kora/features/subscription/data/datasources/revenue_cat_datasource.dart';
import 'package:kora/features/subscription/data/models/subscription_mapper.dart';
import 'package:kora/features/subscription/domain/entities/subscription_offering.dart';
import 'package:kora/features/subscription/domain/entities/subscription_package.dart';
import 'package:kora/features/subscription/domain/entities/subscription_status.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Concrete repository bridging RevenueCat datasource with
/// Clean Architecture domain.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  /// Creates a [SubscriptionRepositoryImpl].
  const SubscriptionRepositoryImpl(this._dataSource);

  final RevenueCatDataSource _dataSource;

  @override
  Stream<SubscriptionStatus> get subscriptionStatusStream =>
      _dataSource.customerInfoStream.map(SubscriptionMapper.fromCustomerInfo);

  @override
  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus() async {
    try {
      final info = await _dataSource.getCustomerInfo();
      return Right(SubscriptionMapper.fromCustomerInfo(info));
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      return Left(
        SubscriptionFailure(
          message: e.message ?? 'Failed to retrieve subscription info.',
          statusCode: errorCode.index,
          cause: e,
        ),
      );
    } on Object catch (e) {
      return Left(
        SubscriptionFailure(
          message: 'An unexpected subscription error occurred: $e',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, SubscriptionOffering>> getCurrentOffering() async {
    try {
      final offerings = await _dataSource.getOfferings();
      final current =
          offerings.current ??
          offerings.all[SubscriptionConstants.defaultOfferingId];

      if (current == null) {
        return const Left(
          SubscriptionFailure(
            message: 'No active subscription offerings found.',
          ),
        );
      }

      return Right(SubscriptionMapper.fromOffering(current));
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      return Left(
        SubscriptionFailure(
          message: e.message ?? 'Failed to retrieve subscription offerings.',
          statusCode: errorCode.index,
          cause: e,
        ),
      );
    } on Object catch (e) {
      return Left(
        SubscriptionFailure(
          message: 'An unexpected error occurred loading offerings: $e',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> purchasePackage(
    SubscriptionPackage package,
  ) async {
    try {
      final info = await _dataSource.purchasePackage(package.identifier);
      return Right(SubscriptionMapper.fromCustomerInfo(info));
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // User deliberately cancelled the store sheet; return current status
        final currentInfo = await _dataSource.getCustomerInfo();
        return Right(SubscriptionMapper.fromCustomerInfo(currentInfo));
      }

      return Left(
        SubscriptionFailure(
          message: e.message ?? 'Failed to complete subscription purchase.',
          statusCode: errorCode.index,
          cause: e,
        ),
      );
    } on Object catch (e) {
      return Left(
        SubscriptionFailure(
          message: 'An unexpected error occurred during purchase: $e',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> restorePurchases() async {
    try {
      final info = await _dataSource.restorePurchases();
      return Right(SubscriptionMapper.fromCustomerInfo(info));
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      return Left(
        SubscriptionFailure(
          message: e.message ?? 'Failed to restore past purchases.',
          statusCode: errorCode.index,
          cause: e,
        ),
      );
    } on Object catch (e) {
      return Left(
        SubscriptionFailure(
          message: 'An unexpected error occurred restoring purchases: $e',
          cause: e,
        ),
      );
    }
  }
}
