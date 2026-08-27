import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:centrow_sales/modules/core/controllers/login_controller.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
import 'package:centrow_sales/modules/core/repositories/region_repository.dart';
import 'package:centrow_sales/modules/sales/controllers/sales_dashboard_controller.dart';
import 'package:centrow_sales/modules/sales/repositories/sales_dashboard_repository.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_controller.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_controller.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_form_controller.dart';
import 'package:centrow_sales/modules/sales/controllers/product_controller.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/service_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/product_repository.dart';
import 'package:centrow_sales/modules/pc/controllers/product_mapping_controller.dart';
import 'package:centrow_sales/modules/pc/controllers/treatment_method_controller.dart';
import 'package:centrow_sales/modules/pc/repositories/product_mapping_repository.dart';
import 'package:centrow_sales/modules/pc/repositories/treatment_method_repository.dart';
import 'package:centrow_sales/modules/core/repositories/uom_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/shared/network/auth_token_holder.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/storage/local_storage.dart';
import 'package:centrow_sales/app/router.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDi({LocalStorage? storage}) async {
  // Storage
  final LocalStorage localStorage;
  if (storage != null) {
    localStorage = storage;
  } else {
    final prefs = await SharedPreferences.getInstance();
    localStorage = SharedPreferencesLocalStorage(prefs);
  }
  getIt.registerSingleton<LocalStorage>(localStorage);

  // Initialize AuthTokenHolder
  AuthTokenHolder.instance.initFromStorage(localStorage);
  AuthTokenHolder.instance.onSessionExpired = () {
    appRouter.go('/login');
  };

  // Network
  getIt.registerLazySingleton<Dio>(createDio);

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<RegionRepository>(
    () => RegionRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<SalesDashboardRepository>(
    () => SalesDashboardRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProposalRepository>(
    () => ProposalRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<PricingRepository>(
    () => PricingRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProductMappingRepository>(
    () => ProductMappingRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<TreatmentMethodRepository>(
    () => TreatmentMethodRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<UomRepository>(
    () => UomRepositoryImpl(getIt<Dio>()),
  );

  // Controllers
  getIt.registerFactory<LoginController>(
    () => LoginController(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SalesDashboardController>(
    () => SalesDashboardController(getIt<SalesDashboardRepository>()),
  );
  getIt.registerFactory<CustomerController>(
    () => CustomerController(getIt<CustomerRepository>()),
  );
  getIt.registerFactory<CustomerFormController>(
    () => CustomerFormController(
      getIt<CustomerRepository>(),
      getIt<RegionRepository>(),
    ),
  );
  getIt.registerFactory<ProposalController>(
    () => ProposalController(getIt<ProposalRepository>()),
  );
  getIt.registerFactory<ProposalFormController>(
    () => ProposalFormController(
      getIt<ProposalRepository>(),
      getIt<CustomerRepository>(),
      getIt<ServiceRepository>(),
    ),
  );
  getIt.registerFactory<ProductController>(
    () => ProductController(getIt<ProductRepository>()),
  );
  getIt.registerFactory<PricingCalculatorController>(
    () => PricingCalculatorController(
      getIt<PricingRepository>(),
      getIt<UomRepository>(),
    ),
  );
  getIt.registerFactory<ProductMappingController>(
    () => ProductMappingController(getIt<ProductMappingRepository>()),
  );
  getIt.registerFactory<TreatmentMethodController>(
    () => TreatmentMethodController(getIt<TreatmentMethodRepository>()),
  );
}
