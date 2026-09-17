import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:centrow_sales/modules/core/controllers/splash_controller.dart';
import 'package:centrow_sales/modules/core/entities/tenant.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
import 'package:centrow_sales/modules/core/repositories/dtos/token_dto.dart';
import 'package:centrow_sales/modules/core/views/pages/splash_page.dart';
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
  @override
  Future<Result<User>> getMe() async => const Ok(
        User(
          id: 'u-1',
          name: 'Jane Doe',
          email: 'jane@example.com',
          role: 'sales',
          branch: 'Main',
          token: 'token123',
        ),
      );

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
  late MockAuthRepository mockRepo;
  late SplashController controller;

  setUp(() {
    mockRepo = MockAuthRepository();
    final storage = InMemoryLocalStorage();
    AuthTokenHolder.instance.initFromStorage(storage);
    AuthTokenHolder.instance.token = null;
    controller = SplashController(mockRepo);
  });

  testWidgets('renders Centrow Sales branding and progress indicator', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => SplashPage(controller: controller),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login View')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Centrow Sales'), findsOneWidget);
    expect(find.text('Mobile ERP & POS'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Login View'), findsOneWidget);
  });
}
