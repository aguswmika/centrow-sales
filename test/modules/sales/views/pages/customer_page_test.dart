import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/modules/sales/views/pages/customer_page.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_detail_pane.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_master_list.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class FakeCustomerRepository implements CustomerRepository {
  List<Customer> customers;
  bool shouldFailGet = false;
  bool shouldFailDetail = false;

  FakeCustomerRepository({List<Customer>? initialCustomers})
      : customers = initialCustomers ??
            [
              const Customer(
                id: 'c1',
                code: 'CUST-001',
                name: 'Villa Bali Resort',
                initials: 'VB',
                segmentId: '660e8400-e29b-41d4-a716-446655440001',
                segment: 'Hospitality',
                status: 'active',
                regency: 'Badung',
                npwp: '12.345.678.0-123.456',
                phone: '+62-361-123-4567',
                phoneAlt: '+62-361-123-4568',
                email: 'info@villabali.example.com',
                scanCode: 'VC-550e8400',
                riskNotes: 'Monitor payment patterns closely',
                notes: 'Preferred vendor for group bookings',
                activeProposalsCount: 2,
                activeContractsCount: 0,
                locations: [
                  CustomerLocation(
                    id: 'l1',
                    isPrimary: true,
                    label: 'Main Resort',
                    addressLine: 'Jalan Pantai Kuta, Badung',
                    village: 'Kuta',
                    district: 'Kuta',
                    regency: 'Badung',
                    province: 'Bali',
                    areaSize: 25000.5,
                    latitude: -8.6500,
                    longitude: 115.1700,
                  ),
                ],
                contacts: [
                  CustomerContact(
                    id: 'ct1',
                    name: 'Budi Santoso',
                    position: 'General Manager',
                    email: 'budi@villabali.example.com',
                    phone: '+62-361-123-4567',
                    role: 'pic',
                    isPrimary: true,
                  ),
                ],
                proposals: [
                  CustomerProposalSummary(
                    id: 'p1',
                    code: 'PROP-2025-001',
                    serviceName: 'Pest Control Monthly',
                    proposalDate: '2025-08-10',
                    totalAmount: 5000000.0,
                    status: 'sent',
                  ),
                ],
              ),
              const Customer(
                id: 'c2',
                code: 'CUST-002',
                name: 'Hotel Surabaya',
                initials: 'HS',
                segmentId: '660e8400-e29b-41d4-a716-446655440001',
                segment: 'Hospitality',
                status: 'inactive',
                regency: 'Surabaya',
                phone: '+62-31-555-1234',
                email: 'contact@hotelsby.example.com',
                activeProposalsCount: 0,
                activeContractsCount: 0,
              ),
            ];

  @override
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  }) async {
    if (shouldFailGet) {
      return const Err(ServerFailure('Gagal memuat pelanggan', 500));
    }
    var list = customers;
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q) ||
              c.regency.toLowerCase().contains(q))
          .toList();
    }
    if (segmentId != null && segmentId != 'all') {
      list = list
          .where((c) => c.segmentId == segmentId || c.segment == segmentId)
          .toList();
    }
    return Ok(list);
  }

  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    if (shouldFailDetail) {
      return const Err(ServerFailure('Gagal memuat detail pelanggan', 500));
    }
    try {
      final found = customers.firstWhere((c) => c.id == id);
      return Ok(found);
    } catch (_) {
      return const Err(ServerFailure('Data tidak ditemukan', 404));
    }
  }

  @override
  Future<Result<Customer>> createCustomer(CreateCustomerInput input) async {
    final created = Customer(
      id: 'c${customers.length + 1}',
      code: input.code.isNotEmpty ? input.code : 'CUST-003',
      name: input.name,
      initials: input.name.isNotEmpty
          ? input.name.substring(0, 2).toUpperCase()
          : 'CP',
      segment: input.segment.isNotEmpty ? input.segment : 'Hospitality',
      status: input.status.isNotEmpty ? input.status : 'active',
      regency: input.regency,
      phone: input.phone,
      email: input.email,
    );
    customers.add(created);
    return Ok(created);
  }
}

void main() {
  group('CustomerPage', () {
    late FakeCustomerRepository repository;
    late CustomerController controller;

    setUp(() {
      repository = FakeCustomerRepository();
      controller = CustomerController(repository);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: CustomerPage(controller: controller),
        ),
      );
    }

    testWidgets('renders master-detail view on tablet size with detail pane populated', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Daftar Pelanggan'), findsOneWidget);
      expect(find.text('Villa Bali Resort'), findsWidgets);
      expect(find.text('Informasi Utama'), findsOneWidget);
      expect(find.text('Lokasi & Titik Servis'), findsOneWidget);
      expect(find.text('Kontak Person & PIC'), findsOneWidget);
      expect(find.text('Riwayat Proposal'), findsOneWidget);
      expect(find.text('Nomor NPWP'), findsOneWidget);
      expect(find.text('12.345.678.0-123.456'), findsOneWidget);
      expect(find.text('Buat Proposal'), findsOneWidget);
      expect(find.text('Edit Data'), findsOneWidget);
    });

    testWidgets('mobile size renders master list without detail pane', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Daftar Pelanggan'), findsOneWidget);
      expect(find.text('Villa Bali Resort'), findsOneWidget);
      expect(find.text('Informasi Utama'), findsNothing);
    });

    testWidgets('tapping a customer updates selectedCustomer and loads detail', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Hotel Surabaya').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.selectedCustomerId.value, 'c2');
      expect(find.text('Non-Aktif'), findsWidgets);
    });

    testWidgets('switching detail tabs updates tab contents', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Locations Tab
      await tester.tap(find.text('Lokasi & Titik Servis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.activeDetailTab.value, 1);
      expect(find.text('Main Resort'), findsOneWidget);
      expect(find.text('Jalan Pantai Kuta, Badung'), findsOneWidget);

      // 2. Contacts Tab
      await tester.tap(find.text('Kontak Person & PIC'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.activeDetailTab.value, 2);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('General Manager'), findsOneWidget);

      // 3. Proposals Tab
      final proposalTabFinder = find.text('Riwayat Proposal');
      await tester.ensureVisible(proposalTabFinder);
      await tester.tap(proposalTabFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.activeDetailTab.value, 3);
      expect(find.text('Pest Control Monthly'), findsOneWidget);
      expect(find.text('Rp 5.000.000'), findsOneWidget);
    });

    testWidgets('CustomerDetailPane renders loading, error, and empty state', (tester) async {
      // Test Loading State
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerDetailPane(
              customer: null,
              detailState: const UiLoading(),
              activeTab: 0,
              onTabChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Test Failure State
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerDetailPane(
              customer: null,
              detailState: const UiFailure(ServerFailure('Gagal koneksi', 500)),
              activeTab: 0,
              onTabChanged: (_) {},
              onRetry: () => retried = true,
            ),
          ),
        ),
      );
      expect(find.text('Gagal koneksi'), findsOneWidget);
      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);

      // Test Empty Initial State
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerDetailPane(
              customer: null,
              detailState: const UiInitial(),
              activeTab: 0,
              onTabChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Pilih pelanggan dari daftar di sebelah kiri'), findsOneWidget);
    });

    testWidgets('tapping add button triggers callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerMasterList(
              customers: const [],
              selectedCustomerId: '',
              selectedSegment: 'all',
              searchQuery: '',
              onSelectCustomer: (_) {},
              onSelectSegment: (_) {},
              onSearchChanged: (_) {},
              onAddCustomer: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(called, isTrue);
    });
  });
}
