import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/core/controllers/login_controller.dart';
import '../modules/core/repositories/auth_repository.dart';
import '../modules/sales/controllers/sales_dashboard_controller.dart';
import '../modules/sales/repositories/sales_dashboard_repository.dart';
import '../modules/sales/controllers/customer_controller.dart';
import '../modules/sales/controllers/add_customer_controller.dart';
import '../modules/sales/repositories/customer_repository.dart';
import '../shared/network/auth_token_holder.dart';
import '../shared/network/dio_client.dart';
import '../shared/storage/local_storage.dart';
import 'router.dart';

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
  getIt.registerLazySingleton<SalesDashboardRepository>(
    () => SalesDashboardRepositoryImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(getIt<Dio>()),
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
  getIt.registerFactory<AddCustomerController>(
    () => AddCustomerController(getIt<CustomerRepository>()),
  );
}
