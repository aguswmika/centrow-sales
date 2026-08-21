import 'package:centrow_sales/modules/core/repositories/dtos/token_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:centrow_sales/modules/core/controllers/login_controller.dart';
import 'package:centrow_sales/modules/core/entities/tenant.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
import 'package:centrow_sales/modules/core/views/pages/login_page.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';

const List<Tenant> sampleTenants = [
  Tenant(id: 't-1', name: 'Main Branch', slug: 'main-branch'),
  Tenant(id: 't-2', name: 'Bandung Branch', slug: 'bandung-branch'),
];

class MockAuthRepository implements AuthRepository {
  @override
  Future<Result<TokenDto>> refreshToken(String refreshToken) async => throw UnimplementedError();
  @override
  Future<Result<void>> logout(String refreshToken) async => throw UnimplementedError();
  List<Tenant>? tenants;
  User? user;
  Failure? failure;
  bool loginCalled = false;

  @override
  Future<Result<List<Tenant>>> getPublicTenants() async {
    return Ok(tenants ?? sampleTenants);
  }

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
    required String tenantId,
  }) async {
    loginCalled = true;
    if (failure != null) return Err(failure!);
    if (user != null) return Ok(user!);
    return const Ok(
      User(
        id: '5d3611bb-d413-4d03-95dc-57f1d1de572a',
        name: 'Jane Doe',
        email: 'sales@example.com',
        role: 'sales',
        branch: 'Main Branch',
        token: 'token123',
      ),
    );
  }

  @override
  Future<Result<User>> getMe() async {
    if (failure != null) return Err(failure!);
    if (user != null) return Ok(user!);
    return const Ok(
      User(
        id: '5d3611bb-d413-4d03-95dc-57f1d1de572a',
        name: 'Jane Doe',
        email: 'sales@example.com',
        role: 'sales',
        branch: 'Main Branch',
        token: 'token123',
      ),
    );
  }
}

void main() {
  late MockAuthRepository mockRepository;
  late LoginController controller;

  setUp(() {
    mockRepository = MockAuthRepository();
    controller = LoginController(mockRepository);
  });

  tearDown(() {
    controller.dispose();
  });

  Widget wrap(Widget child) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const Scaffold(
            body: Text('Customers Screen'),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  testWidgets('LoginPage renders header, inputs, and login button', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(LoginPage(controller: controller)));
    await tester.pumpAndSettle();

    expect(find.text('Centrow Sales'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login button is disabled when inputs are invalid', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(LoginPage(controller: controller)));
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('Login button is enabled when valid credentials are typed', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(LoginPage(controller: controller)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'sales@example.com');
    await tester.enterText(find.byType(TextField).last, 'secretPassword123');
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('Tapping password toggle switches obscureText property', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(LoginPage(controller: controller)));
    await tester.pumpAndSettle();

    final passwordFieldFinder = find.byType(TextField).last;
    TextField passwordField = tester.widget<TextField>(passwordFieldFinder);
    expect(passwordField.obscureText, isTrue);

    // Tap the visibility icon
    final toggleButton = find.byIcon(Icons.visibility_off_outlined);
    expect(toggleButton, findsOneWidget);
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    passwordField = tester.widget<TextField>(passwordFieldFinder);
    expect(passwordField.obscureText, isFalse);
  });

  testWidgets(
    'Submitting login executes repository call, shows success toast, and navigates to customers',
    (tester) async {
      await tester.pumpWidget(wrap(LoginPage(controller: controller)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'sales@example.com');
      await tester.enterText(find.byType(TextField).last, 'secretPassword123');
      await tester.pumpAndSettle();

      final loginButton = find.byType(AppButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(mockRepository.loginCalled, isTrue);
      expect(find.text('Berhasil masuk ke sistem.'), findsOneWidget);
      expect(find.text('Customers Screen'), findsOneWidget);
    },
  );

  testWidgets('Submitting login with error displays error toast', (
    tester,
  ) async {
    mockRepository.failure = const ServerFailure(
      'Akun ini tidak memiliki akses ke aplikasi ini.',
      403,
    );

    await tester.pumpWidget(wrap(LoginPage(controller: controller)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'sales@example.com');
    await tester.enterText(find.byType(TextField).last, 'secretPassword123');
    await tester.pumpAndSettle();

    final loginButton = find.byType(AppButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(mockRepository.loginCalled, isTrue);
    expect(
      find.text('Akun ini tidak memiliki akses ke aplikasi ini.'),
      findsOneWidget,
    );
  });

  testWidgets('Tenant load failure triggers error toast', (tester) async {
    final failMockRepo = MockAuthRepository();
    // Simulate failing getPublicTenants
    final failController = LoginController(failMockRepo);
    failMockRepo.tenants = null;

    // We create custom repo that returns failure for tenants
    final customRepo = _FailingTenantsAuthRepository();
    final c = LoginController(customRepo);

    await tester.pumpWidget(wrap(LoginPage(controller: c)));
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat cabang: Server error'), findsOneWidget);
    c.dispose();
    failController.dispose();
  });
}

class _FailingTenantsAuthRepository implements AuthRepository {
  @override
  Future<Result<TokenDto>> refreshToken(String refreshToken) async => throw UnimplementedError();
  @override
  Future<Result<void>> logout(String refreshToken) async => throw UnimplementedError();
  @override
  Future<Result<List<Tenant>>> getPublicTenants() async {
    return const Err(ServerFailure('Server error'));
  }

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
    required String tenantId,
  }) async {
    return const Err(ServerFailure('Server error'));
  }

  @override
  Future<Result<User>> getMe() async {
    return const Err(ServerFailure('Server error'));
  }
}
