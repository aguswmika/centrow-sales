import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/app.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/app/router.dart';
import 'package:centrow_sales/modules/core/entities/tenant.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/widgets/nav_rail_shell.dart';

import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';

class _MockAuthRepo implements AuthRepository {
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
}

void main() {
  setUp(() {
    setupDi();
    getIt.unregister<AuthRepository>();
    getIt.registerLazySingleton<AuthRepository>(() => _MockAuthRepo());
    getIt.unregister<CustomerRepository>();
    getIt.registerLazySingleton<CustomerRepository>(() => _MockCustomerRepo());
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('NavRailShell switches tabs on tablet navigation rail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createRouter(initialLocation: '/dashboard');
    await tester.pumpWidget(CentrowSalesApp(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(NavRailShell), findsOneWidget);
    expect(find.text('Proposal Aktif'), findsOneWidget);

    // Tap Pelanggan tab on rail
    final railPelanggan = find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Pelanggan'),
    );
    await tester.tap(railPelanggan);
    await tester.pumpAndSettle();

    expect(find.text('Daftar Pelanggan'), findsOneWidget);

    // Tap Proposal tab on rail
    final railProposal = find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Proposal'),
    );
    await tester.tap(railProposal);
    await tester.pumpAndSettle();

    expect(find.text('Proposal'), findsWidgets);
  });

  testWidgets('NavRailShell switches tabs on mobile bottom navigation bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createRouter(initialLocation: '/dashboard');
    await tester.pumpWidget(CentrowSalesApp(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Tap Pelanggan tab on bottom bar
    final bottomPelanggan = find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text('Pelanggan'),
    );
    await tester.tap(bottomPelanggan);
    await tester.pumpAndSettle();

    expect(find.text('Daftar Pelanggan'), findsOneWidget);
  });
}
