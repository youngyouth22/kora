import 'package:get_it/get_it.dart';
import 'package:kora/features/subscription/data/datasources/revenue_cat_datasource.dart';
import 'package:kora/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:kora/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:kora/features/subscription/domain/usecases/check_pro_entitlement_usecase.dart';
import 'package:kora/features/subscription/domain/usecases/get_current_offering_usecase.dart';
import 'package:kora/features/subscription/domain/usecases/purchase_package_usecase.dart';
import 'package:kora/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:kora/features/subscription/presentation/bloc/subscription_bloc.dart';

/// Registers all subscription and RevenueCat dependencies
/// in the service locator.
void initSubscriptionInjection(GetIt sl) {
  // Datasource
  if (!sl.isRegistered<RevenueCatDataSource>()) {
    sl.registerLazySingleton<RevenueCatDataSource>(
      RevenueCatDataSourceImpl.new,
    );
  }

  // Repository
  if (!sl.isRegistered<SubscriptionRepository>()) {
    sl.registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(sl<RevenueCatDataSource>()),
    );
  }

  // Usecases
  if (!sl.isRegistered<CheckProEntitlementUseCase>()) {
    sl.registerLazySingleton(
      () => CheckProEntitlementUseCase(sl<SubscriptionRepository>()),
    );
  }

  if (!sl.isRegistered<GetCurrentOfferingUseCase>()) {
    sl.registerLazySingleton(
      () => GetCurrentOfferingUseCase(sl<SubscriptionRepository>()),
    );
  }

  if (!sl.isRegistered<PurchasePackageUseCase>()) {
    sl.registerLazySingleton(
      () => PurchasePackageUseCase(sl<SubscriptionRepository>()),
    );
  }

  if (!sl.isRegistered<RestorePurchasesUseCase>()) {
    sl.registerLazySingleton(
      () => RestorePurchasesUseCase(sl<SubscriptionRepository>()),
    );
  }

  // BLoC
  if (!sl.isRegistered<SubscriptionBloc>()) {
    sl.registerFactory(
      () => SubscriptionBloc(
        checkProEntitlement: sl<CheckProEntitlementUseCase>(),
        getCurrentOffering: sl<GetCurrentOfferingUseCase>(),
        purchasePackage: sl<PurchasePackageUseCase>(),
        restorePurchases: sl<RestorePurchasesUseCase>(),
        repository: sl<SubscriptionRepository>(),
      ),
    );
  }
}
