import 'package:centrow_sales/modules/core/repositories/dtos/token_dto.dart';
import 'package:centrow_sales/app/app.dart';
import 'package:centrow_sales/modules/core/views/pages/login_page.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/app/router.dart';
import 'package:centrow_sales/modules/core/entities/tenant.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuthRepo implements AuthRepository {
  @override
  Future<Result<TokenDto>> refreshToken(String refreshToken) async =>
      throw UnimplementedError();
  @override
  Future<Result<void>> logout(String refreshToken) async =>
      throw UnimplementedError();
  @override
  Future<Result<List<Tenant>>> getPublicTenants() async {
    return const Ok([Tenant(id: 't1', name: 'Cabang Bali', slug: 'bali')]);
  }

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
    required String tenantId,
  }) async {
    return const Ok(
      User(
        id: 'u1',
        name: 'User Test',
        email: 'test@example.com',
        role: 'Sales',
        branch: 'Bali',
        token: 'mock_jwt_token',
      ),
    );
  }

  @override
  Future<Result<User>> getMe() async {
    return const Ok(
      User(
        id: 'u1',
        name: 'User Test',
        email: 'test@example.com',
        role: 'Sales',
        branch: 'Bali',
        token: 'mock_jwt_token',
      ),
    );
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await setupDi();
    getIt.unregister<AuthRepository>();
    getIt.registerLazySingleton<AuthRepository>(() => _MockAuthRepo());
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('CentrowSalesApp smoke test renders login page with logo', (
    tester,
  ) async {
    final router = createRouter(initialLocation: '/login');
    await tester.pumpWidget(CentrowSalesApp(routerConfig: router));
    await tester.pumpAndSettle();

    // Debug:
    // debugDumpApp();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Centrow Sales'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
  });
}
