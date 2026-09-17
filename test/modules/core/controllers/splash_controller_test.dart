import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/controllers/splash_controller.dart';
import 'package:centrow_sales/modules/core/entities/tenant.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/token_dto.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/network/auth_token_holder.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/storage/local_storage.dart';

class InMemoryLocalStorage implements LocalStorage {
  final Map<String, dynamic> _data = {};

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }
}

class MockAuthRepository implements AuthRepository {
  Result<User>? getMeResult;
  bool getMeCalled = false;

  @override
  Future<Result<User>> getMe() async {
    getMeCalled = true;
    return getMeResult ??
        const Ok(
          User(
            id: 'u-1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'sales',
            branch: 'HQ',
            token: 'valid-token',
          ),
        );
  }

  @override
  Future<Result<List<Tenant>>> getPublicTenants() => throw UnimplementedError();

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
    required String tenantId,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<TokenDto>> refreshToken(String refreshToken) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> logout(String refreshToken) => throw UnimplementedError();
}

void main() {
  late MockAuthRepository mockAuthRepo;
  late InMemoryLocalStorage storage;
  late AuthTokenHolder tokenHolder;
  late SplashController controller;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    storage = InMemoryLocalStorage();
    tokenHolder = AuthTokenHolder.instance;
    tokenHolder.initFromStorage(storage);
    tokenHolder.token = null;
    tokenHolder.currentUser = null;
    controller = SplashController(mockAuthRepo, tokenHolder);
  });

  tearDown(() {
    controller.dispose();
  });

  test('routes to /login when no token is present', () async {
    await controller.checkSession(
      minDuration: const Duration(milliseconds: 10),
    );

    expect(mockAuthRepo.getMeCalled, isFalse);
    expect(controller.targetRoute.value, '/login');
  });

  test('validates token and routes to /customers when valid', () async {
    tokenHolder.token = 'existing-token';
    const user = User(
      id: 'u-1',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'sales',
      branch: 'HQ',
      token: 'existing-token',
    );
    mockAuthRepo.getMeResult = const Ok(user);

    await controller.checkSession(
      minDuration: const Duration(milliseconds: 10),
    );

    expect(mockAuthRepo.getMeCalled, isTrue);
    expect(tokenHolder.currentUser, equals(user));
    expect(controller.targetRoute.value, '/customers');
  });

  test('clears token and routes to /login when token is 401 unauthorized', () async {
    tokenHolder.token = 'expired-token';
    mockAuthRepo.getMeResult = const Err(
      ServerFailure('Sesi telah berakhir.', 401),
    );

    await controller.checkSession(
      minDuration: const Duration(milliseconds: 10),
    );

    expect(mockAuthRepo.getMeCalled, isTrue);
    expect(tokenHolder.token, isNull);
    expect(controller.targetRoute.value, '/login');
  });

  test('gracefully routes to /customers when offline or network fails', () async {
    tokenHolder.token = 'cached-token';
    mockAuthRepo.getMeResult = const Err(NetworkFailure('No connection'));

    await controller.checkSession(
      minDuration: const Duration(milliseconds: 10),
    );

    expect(mockAuthRepo.getMeCalled, isTrue);
    expect(tokenHolder.token, 'cached-token');
    expect(controller.targetRoute.value, '/customers');
  });
}
