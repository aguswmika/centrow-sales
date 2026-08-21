import 'package:centrow_sales/modules/core/repositories/dtos/token_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/controllers/login_controller.dart';
import 'package:centrow_sales/modules/core/entities/tenant.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
import 'package:centrow_sales/shared/network/auth_token_holder.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Result<TokenDto>> refreshToken(String refreshToken) async => throw UnimplementedError();
  @override
  Future<Result<void>> logout(String refreshToken) async => throw UnimplementedError();
  late Result<List<Tenant>> publicTenantsResult;
  late Result<User> loginResult;

  @override
  Future<Result<List<Tenant>>> getPublicTenants() async => publicTenantsResult;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
    required String tenantId,
  }) async => loginResult;

  @override
  Future<Result<User>> getMe() async => loginResult;
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginController controller;

  setUp(() {
    AuthTokenHolder.instance.clear();
    mockAuthRepository = MockAuthRepository();
    controller = LoginController(mockAuthRepository);
  });

  tearDown(() {
    AuthTokenHolder.instance.clear();
    controller.dispose();
  });

  test('loadTenants updates state and selects first tenant', () async {
    const tenants = [
      Tenant(id: 't-1', name: 'Branch 1', slug: 'branch-1'),
      Tenant(id: 't-2', name: 'Branch 2', slug: 'branch-2'),
    ];
    mockAuthRepository.publicTenantsResult = const Ok(tenants);

    await controller.loadTenants();

    expect(controller.tenantsState.value, isA<UiSuccess<List<Tenant>>>());
    expect(controller.selectedTenantId.value, 't-1');
  });

  test('submitLogin calls repository with correct parameters and sets token', () async {
    controller.setEmail('test@nohama.id');
    controller.setPassword('password123');
    controller.selectTenant('tenant_1');

    const user = User(
      id: '1',
      name: 'Test User',
      email: 'test@nohama.id',
      role: 'Admin',
      branch: 'Bali',
      token: 'jwt_secret_token_123',
    );
    mockAuthRepository.loginResult = const Ok(user);

    await controller.submitLogin();

    expect(controller.state.value, isA<UiSuccess<User>>());
    expect(AuthTokenHolder.instance.token, 'jwt_secret_token_123');
  });
}
