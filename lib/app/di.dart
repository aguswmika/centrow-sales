import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../modules/core/controllers/login_controller.dart';
import '../modules/core/repositories/auth_repository.dart';
import '../modules/sales/controllers/sales_dashboard_controller.dart';
import '../modules/sales/repositories/sales_dashboard_repository.dart';
import '../modules/sales/controllers/customer_controller.dart';
import '../modules/sales/repositories/customer_repository.dart';
import '../shared/network/dio_client.dart';

final GetIt getIt = GetIt.instance;

void setupDi() {
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
}
