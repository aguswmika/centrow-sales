import 'package:centrow_sales/modules/core/repositories/dtos/token_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:centrow_sales/app/app.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/app/router.dart';
import 'package:centrow_sales/modules/core/entities/tenant.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
import 'package:centrow_sales/shared/network/auth_token_holder.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/widgets/nav_rail_shell.dart';

import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';

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
        name: 'Agus',
        email: 'agus@centrow.id',
        role: 'sales',
        branch: 'Bali',
        token: 'token123',
      ),
    );
  }

  @override
  Future<Result<User>> getMe() async {
    return const Ok(
      User(
        id: 'u1',
        name: 'Agus',
        email: 'agus@centrow.id',
        role: 'sales',
        branch: 'Bali',
        token: 'token123',
      ),
    );
  }
}

class _MockCustomerRepo implements CustomerRepository {
  @override
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  }) async {
    return const Ok([
      Customer(
        id: 'c1',
        code: 'CRM-0012',
        name: 'Villa Sari Dewi',
        initials: 'VS',
        segment: 'Villa',
        status: 'Aktif',
      ),
    ]);
  }

  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    return const Ok(
      Customer(
        id: 'c1',
        code: 'CRM-0012',
        name: 'Villa Sari Dewi',
        initials: 'VS',
        segment: 'Villa',
        status: 'Aktif',
      ),
    );
  }

  @override
  Future<Result<Customer>> createCustomer(CreateCustomerInput input) async {
    return const Ok(
      Customer(
        id: 'c1',
        code: 'CRM-0012',
        name: 'Villa Sari Dewi',
        initials: 'VS',
        segment: 'Villa',
        status: 'Aktif',
      ),
    );
  }

  @override
  Future<Result<Customer>> updateCustomer(
    String id,
    CreateCustomerInput input,
  ) async {
    return createCustomer(input);
  }

  @override
  Future<Result<List<Segment>>> getSegments({
    int page = 1,
    int pageSize = 100,
    String? query,
  }) async {
    return const Ok(<Segment>[]);
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'auth_token': 'token123'});
    await setupDi();
    AuthTokenHolder.instance.token = 'token123';
    getIt.unregister<AuthRepository>();
    getIt.registerLazySingleton<AuthRepository>(() => _MockAuthRepo());
    getIt.unregister<CustomerRepository>();
    getIt.registerLazySingleton<CustomerRepository>(() => _MockCustomerRepo());
  });

  tearDown(() {
    AuthTokenHolder.instance.clear();
    getIt.reset();
  });

  testWidgets('NavRailShell switches tabs on tablet navigation rail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createRouter(initialLocation: '/customers');
    await tester.pumpWidget(CentrowSalesApp(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(NavRailShell), findsOneWidget);
    expect(find.text('Daftar Pelanggan'), findsOneWidget);

    // Tap Proposal tab on rail
    final railProposal = find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Proposal'),
    );
    await tester.tap(railProposal);
    await tester.pumpAndSettle();

    expect(find.text('Proposal'), findsWidgets);

    // Tap Kontrak tab on rail
    final railKontrak = find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Kontrak'),
    );
    await tester.tap(railKontrak);
    await tester.pumpAndSettle();

    expect(find.text('Kontrak'), findsWidgets);

    // Tap Pelanggan tab on rail
    final railPelanggan = find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Pelanggan'),
    );
    await tester.tap(railPelanggan);
    await tester.pumpAndSettle();

    expect(find.text('Daftar Pelanggan'), findsOneWidget);
  });

  testWidgets('NavRailShell switches tabs on mobile bottom navigation bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createRouter(initialLocation: '/customers');
    await tester.pumpWidget(CentrowSalesApp(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Daftar Pelanggan'), findsOneWidget);

    // Tap Proposal tab on bottom bar
    final bottomProposal = find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Proposal'),
    );
    await tester.tap(bottomProposal);
    await tester.pumpAndSettle();

    expect(find.text('Proposal'), findsWidgets);

    // Tap Kontrak tab on bottom bar
    final bottomKontrak = find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Kontrak'),
    );
    await tester.tap(bottomKontrak);
    await tester.pumpAndSettle();

    expect(find.text('Kontrak'), findsWidgets);

    // Tap Pelanggan tab on bottom bar
    final bottomPelanggan = find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Pelanggan'),
    );
    await tester.tap(bottomPelanggan);
    await tester.pumpAndSettle();

    expect(find.text('Daftar Pelanggan'), findsOneWidget);
  });

  testWidgets(
    'Tapping avatar opens profile menu and confirming logout clears session and navigates to login',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await AuthTokenHolder.instance.saveToken('valid_token_123');
      await AuthTokenHolder.instance.saveUser(
        const User(
          id: 'u1',
          name: 'Sales Executive',
          email: 'sales@centrow.id',
          role: 'Sales',
          branch: 'Main Branch',
          token: 'valid_token_123',
        ),
      );
      final router = createRouter(initialLocation: '/customers');
      await tester.pumpWidget(CentrowSalesApp(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Verify popup menu items are rendered
      expect(find.text('Sales Executive'), findsOneWidget);
      expect(find.text('sales@centrow.id'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);

      // Tap Keluar
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Konfirmasi Keluar'), findsOneWidget);
      expect(
        find.text('Apakah Anda yakin ingin keluar dari akun ini?'),
        findsOneWidget,
      );

      // Confirm logout
      await tester.tap(find.text('Ya, Keluar'));
      await tester.pumpAndSettle();

      // Verify token cleared and routed to login page
      expect(AuthTokenHolder.instance.hasToken, isFalse);
      expect(find.text('Centrow Sales'), findsOneWidget);
    },
  );
}
