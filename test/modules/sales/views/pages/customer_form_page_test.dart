import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/core/entities/region.dart';
import 'package:centrow_sales/modules/core/repositories/region_repository.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/modules/sales/views/pages/customer_form_page.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class FakeRegionRepository implements RegionRepository {
  @override
  Future<Result<List<Province>>> getProvinces() async => const Ok([]);

  @override
  Future<Result<List<Regency>>> getRegencies(int provinceId) async =>
      const Ok([]);

  @override
  Future<Result<List<District>>> getDistricts(
    int provinceId,
    int regencyId,
  ) async => const Ok([]);

  @override
  Future<Result<List<Village>>> getVillages(
    int provinceId,
    int regencyId,
    int districtId,
  ) async => const Ok([]);
}

class FakeCustomerRepository implements CustomerRepository {
  List<Customer> customers = [];
  List<Segment> segments = [];
  bool shouldFail = false;

  @override
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  }) async {
    return Ok(customers);
  }

  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    try {
      final found = customers.firstWhere((c) => c.id == id);
      return Ok(found);
    } catch (_) {
      return const Err(ServerFailure('Data tidak ditemukan', 404));
    }
  }

  @override
  Future<Result<Customer>> createCustomer(CreateCustomerInput input) async {
    if (shouldFail) {
      return const Err(ServerFailure('Gagal menyimpan pelanggan', 400));
    }
    final created = Customer(
      id: 'c${customers.length + 1}',
      code: input.code.isNotEmpty ? input.code : 'CUST-003',
      name: input.name,
      initials: input.name.isNotEmpty
          ? input.name
                .substring(0, input.name.length >= 2 ? 2 : 1)
                .toUpperCase()
          : 'CP',
      segmentId: input.segmentId,
      segment: input.segment.isNotEmpty ? input.segment : 'Villa',
      status: 'active',
      phone: input.phone,
      email: input.email,
    );
    customers.add(created);
    return Ok(created);
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
    return Ok(segments);
  }
}

void main() {
  group('CustomerFormPage', () {
    late FakeCustomerRepository repository;
    late CustomerFormController controller;

    setUp(() {
      repository = FakeCustomerRepository();
      controller = CustomerFormController(repository);
      if (getIt.isRegistered<RegionRepository>()) {
        getIt.unregister<RegionRepository>();
      }
      getIt.registerSingleton<RegionRepository>(FakeRegionRepository());
    });

    tearDown(() {
      if (getIt.isRegistered<RegionRepository>()) {
        getIt.unregister<RegionRepository>();
      }
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(body: CustomerFormPage(controller: controller)),
      );
    }

    testWidgets(
      'renders step 1 and validates required fields before navigating',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Tambah Pelanggan Baru'), findsOneWidget);
        expect(find.text('Identitas Pelanggan'), findsOneWidget);
        expect(find.text('Legalitas & Kontak Bisnis'), findsOneWidget);
        expect(find.text('Ringkasan Data'), findsOneWidget);

        // Attempting to advance while invalid stays on Step 1
        await tester.tap(find.byIcon(Icons.chevron_right).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.currentStep.value, 1);

        // Populate Step 1 fields
        controller.name.value = 'Villa Bali Resort';
        controller.segmentId.value = '660e8400-e29b-41d4-a716-446655440001';
        controller.segment.value = 'Villa';
        controller.phone.value = '+62 812-3456-7890';
        await tester.pump();

        // Tap Selanjutnya to move to Step 2
        await tester.tap(find.byIcon(Icons.chevron_right).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(controller.currentStep.value, 2);
        expect(find.text('Tambah Alamat / Titik Servis Lain'), findsOneWidget);

        // Attempting to advance while Step 2 is invalid stays on Step 2
        await tester.tap(find.byIcon(Icons.chevron_right).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(controller.currentStep.value, 2);

        // Populate Step 2 location address
        controller.updateLocation(
          0,
          controller.locations.value.first.copyWith(
            label: 'Main Resort',
            address: 'Jalan Pantai Kuta',
          ),
        );
        await tester.pump();

        // Tap Selanjutnya to move to Step 3
        await tester.tap(find.byIcon(Icons.chevron_right).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(controller.currentStep.value, 3);
        expect(find.text('Tambah Kontak Person Lain'), findsOneWidget);
        expect(find.text('Simpan'), findsWidgets);

        // Populate Step 3 contact
        controller.updateContact(
          0,
          controller.contacts.value.first.copyWith(
            name: 'Budi Santoso',
            phone: '+62 812-3456-7890',
          ),
        );
        await tester.pump();

        // Tap Simpan
        await tester.tap(find.text('Simpan').first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(repository.customers.length, 1);
        expect(repository.customers.first.name, 'Villa Bali Resort');
      },
    );

    testWidgets('mobile layout renders without summary sidebar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Tambah Pelanggan Baru'), findsOneWidget);
      expect(find.text('Identitas Pelanggan'), findsOneWidget);
      expect(find.text('Ringkasan Data'), findsNothing);
    });

    testWidgets('step 2 allows adding and removing location cards', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      controller.name.value = 'Villa Bali Resort';
      controller.segmentId.value = '660e8400-e29b-41d4-a716-446655440001';
      controller.phone.value = '+62 812-3456-7890';
      controller.setStep(2);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(controller.locations.value.length, 1);
      await tester.tap(find.text('Tambah Alamat / Titik Servis Lain'));
      await tester.pump();
      expect(controller.locations.value.length, 2);

      // Previous step navigation
      await tester.tap(find.byIcon(Icons.chevron_left).first);
      await tester.pump();
      expect(controller.currentStep.value, 1);
    });

    testWidgets(
      'step 1 renders segments from repository and allows selecting a segment',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final repoWithSegments = FakeCustomerRepository()
          ..segments = [
            const Segment(id: 'seg-villa', name: 'Villa'),
            const Segment(id: 'seg-hotel', name: 'Hotel'),
          ];
        final ctrl = CustomerFormController(repoWithSegments);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CustomerFormPage(controller: ctrl)),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Villa'), findsNothing);
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();

        expect(find.text('Villa').last, findsOneWidget);
        await tester.tap(find.text('Villa').last);
        await tester.pumpAndSettle();

        expect(ctrl.segmentId.value, 'seg-villa');
        expect(ctrl.segment.value, 'Villa');
      },
    );

    testWidgets(
      'edit mode loads customer initial data and updates topbar title',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final repo = FakeCustomerRepository()
          ..customers = [
            const Customer(
              id: 'c123',
              code: 'CUST-123',
              name: 'Hotel Mulia Bali',
              initials: 'HM',
              segmentId: 'seg-hotel',
              segment: 'Hotel',
              status: 'active',
              phone: '+62 811-222-333',
              locations: [
                CustomerLocation(
                  label: 'Main Building',
                  addressLine: 'Jl. Raya Nusa Dua',
                  isPrimary: true,
                ),
              ],
              contacts: [
                CustomerContact(
                  name: 'Dewi Lestari',
                  phone: '+62 811-222-333',
                  role: 'pic',
                  isPrimary: true,
                ),
              ],
            ),
          ];

        final ctrl = CustomerFormController(repo);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomerFormPage(controller: ctrl, customerId: 'c123'),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Edit Data Pelanggan'), findsOneWidget);
        expect(ctrl.name.value, 'Hotel Mulia Bali');
        expect(ctrl.phone.value, '+62 811-222-333');

        // Tap Selanjutnya to step 2
        await tester.tap(find.byIcon(Icons.chevron_right).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(ctrl.currentStep.value, 2);

        // Tap Selanjutnya to step 3
        await tester.tap(find.byIcon(Icons.chevron_right).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(ctrl.currentStep.value, 3);

        // Tap Simpan to trigger update
        await tester.tap(find.text('Simpan').first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text('Pelanggan "Hotel Mulia Bali" berhasil diperbarui'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'edit mode allows saving directly from step 1 via topbar Simpan button',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final repo = FakeCustomerRepository()
          ..customers = [
            const Customer(
              id: 'c123',
              code: 'CUST-123',
              name: 'Hotel Mulia Bali',
              initials: 'HM',
              segmentId: 'seg-hotel',
              segment: 'Hotel',
              status: 'active',
              phone: '+62 811-222-333',
              locations: [
                CustomerLocation(
                  label: 'Main Building',
                  addressLine: 'Jl. Raya Nusa Dua',
                  isPrimary: true,
                ),
              ],
              contacts: [
                CustomerContact(
                  name: 'Dewi Lestari',
                  phone: '+62 811-222-333',
                  role: 'pic',
                  isPrimary: true,
                ),
              ],
            ),
          ];

        final ctrl = CustomerFormController(repo);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomerFormPage(controller: ctrl, customerId: 'c123'),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(ctrl.currentStep.value, 1);
        expect(find.text('Simpan'), findsOneWidget);

        ctrl.name.value = 'Hotel Mulia Bali Updated';
        await tester.pump();

        await tester.tap(find.text('Simpan'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text('Pelanggan "Hotel Mulia Bali Updated" berhasil diperbarui'),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows loading bar when isLoadingData is true', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsNothing);

      controller.isLoadingData.value = true;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
