import 'package:centrow_sales/modules/core/repositories/dtos/token_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/controllers/login_controller.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
import 'package:centrow_sales/shared/network/auth_token_holder.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Result<TokenDto>> refreshToken(String refreshToken) async =>
      throw UnimplementedError();
  @override
  Future<Result<void>> logout(String refreshToken) async =>
      throw UnimplementedError();
  late Result<User> loginResult;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
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

  test('isValid requires valid email and non-empty password', () {
    expect(controller.isValid.value, isFalse);
    controller.setEmail('test@nohama.id');
    expect(controller.isValid.value, isFalse);
    controller.setPassword('password123');
    expect(controller.isValid.value, isTrue);
    controller.setEmail('not-an-email');
    expect(controller.isValid.value, isFalse);
  });

  test(
    'submitLogin calls repository with correct parameters and sets token',
    () async {
      controller.setEmail('test@nohama.id');
      controller.setPassword('password123');

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
    },
  );
}
