import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/core/entities/region.dart';
import 'package:centrow_sales/modules/core/repositories/region_repository.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/entities/site_risk.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/site_risk_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/customer_form_site_risk_sheet.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/region_picker.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/step2_locations_form.dart';
import 'package:centrow_sales/shared/result/result.dart';

class FakeCustomerRepository implements CustomerRepository {
  @override
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  }) async => const Ok([]);

  @override
  Future<Result<Customer>> getCustomerById(String id) async => const Ok(
    Customer(
      id: '1',
      code: 'CUST-001',
      name: 'Test',
      initials: 'T',
      segmentId: '1',
      segment: 'Villa',
      status: 'active',
    ),
  );

  @override
  Future<Result<Customer>> createCustomer(CreateCustomerInput input) async =>
      const Ok(
        Customer(
          id: '1',
          code: 'CUST-001',
          name: 'Test',
          initials: 'T',
          segmentId: '1',
          segment: 'Villa',
          status: 'active',
        ),
      );

  @override
  Future<Result<Customer>> updateCustomer(
    String id,
    CreateCustomerInput input,
  ) async => const Ok(
    Customer(
      id: '1',
      code: 'CUST-001',
      name: 'Test',
      initials: 'T',
      segmentId: '1',
      segment: 'Villa',
      status: 'active',
    ),
  );

  @override
  Future<Result<List<Segment>>> getSegments({
    int page = 1,
    int pageSize = 100,
    String? query,
  }) async => const Ok([]);
}

class FakeRegionRepository implements RegionRepository {
  @override
  Future<Result<List<Province>>> getProvinces() async =>
      const Ok([Province(id: 51, name: 'Bali')]);

  @override
  Future<Result<List<Regency>>> getRegencies(int provinceId) async =>
      const Ok([Regency(id: 5103, name: 'Kab. Badung')]);

  @override
  Future<Result<List<District>>> getDistricts(
    int provinceId,
    int regencyId,
  ) async => const Ok([District(id: 5103020, name: 'Kuta')]);

  @override
  Future<Result<List<Village>>> getVillages(
    int provinceId,
    int regencyId,
    int districtId,
  ) async => const Ok([Village(id: 5103020003, name: 'Seminyak')]);
}

class FakeSiteRiskRepository implements SiteRiskRepository {
  List<SiteRiskMaster> masters = const [
    SiteRiskMaster(id: 'risk-1', name: 'Area kerja licin'),
    SiteRiskMaster(id: 'risk-2', name: 'Bekerja di ketinggian'),
  ];

  @override
  Future<Result<List<SiteRiskMaster>>> getSiteRiskMasters() async =>
      Ok(masters);

  @override
  Future<Result<List<CustomerAddressRisk>>> getAddressRisks({
    required String customerId,
    required String addressId,
  }) async => const Ok([]);

  @override
  Future<Result<List<CustomerAddressRisk>>> updateAddressRisks({
    required String customerId,
    required String addressId,
    required List<String> siteRiskIds,
    required List<String> customRisks,
  }) async => const Ok([]);
}

void main() {
  group('Step2LocationsForm', () {
    late CustomerFormController controller;

    setUp(() {
      controller = CustomerFormController(FakeCustomerRepository());
      if (getIt.isRegistered<RegionRepository>()) {
        getIt.unregister<RegionRepository>();
      }
      getIt.registerSingleton<RegionRepository>(FakeRegionRepository());

      if (getIt.isRegistered<SiteRiskRepository>()) {
        getIt.unregister<SiteRiskRepository>();
      }
      getIt.registerSingleton<SiteRiskRepository>(FakeSiteRiskRepository());
    });

    tearDown(() {
      if (getIt.isRegistered<RegionRepository>()) {
        getIt.unregister<RegionRepository>();
      }
      if (getIt.isRegistered<SiteRiskRepository>()) {
        getIt.unregister<SiteRiskRepository>();
      }
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Step2LocationsForm(controller: controller),
          ),
        ),
      );
    }

    testWidgets('renders location card with RegionPicker widget', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RegionPicker), findsOneWidget);
      expect(find.text('Label Nama Lokasi'), findsOneWidget);
      expect(find.text('Alamat Lengkap'), findsOneWidget);
      expect(find.text('Luas Area Properti'), findsOneWidget);
      expect(find.text('Provinsi'), findsOneWidget);
      expect(find.text('Kabupaten / Kota'), findsOneWidget);
      expect(find.text('Kecamatan'), findsOneWidget);
      expect(find.text('Kelurahan / Desa'), findsOneWidget);
    });

    testWidgets('adding and removing locations updates RegionPicker count', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RegionPicker), findsOneWidget);

      final addBtn = find.text('Tambah Alamat / Titik Servis Lain');
      await tester.ensureVisible(addBtn);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.byType(RegionPicker), findsNWidgets(2));
      expect(controller.locations.value.length, 2);

      // Remove the second location
      final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteButtons, findsNWidgets(2));
      await tester.ensureVisible(deleteButtons.at(1));
      await tester.tap(deleteButtons.at(1));
      await tester.pumpAndSettle();

      expect(find.byType(RegionPicker), findsOneWidget);
      expect(controller.locations.value.length, 1);
    });

    testWidgets('updating RegionPicker triggers controller.updateLocation', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open province dropdown and select Bali
      await tester.tap(find.byType(DropdownButtonFormField<int>).at(0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bali').last);
      await tester.pumpAndSettle();

      expect(controller.locations.value.first.provinceId, 51);
      expect(controller.locations.value.first.province, 'Bali');
    });

    testWidgets('primary location displays SRA section and badge', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Site Risk Assessment (SRA)'), findsOneWidget);
      expect(find.text('Wajib diisi'), findsOneWidget);
      expect(find.text('Atur Penilaian Risiko'), findsOneWidget);

      controller.updatePrimaryLocationSra(
        siteRiskIds: ['risk-1'],
        customRisks: ['Anjing galak'],
      );
      await tester.pumpAndSettle();

      expect(find.text('2 Risiko Teridentifikasi'), findsOneWidget);
      expect(find.text('Wajib diisi'), findsNothing);
    });

    testWidgets(
      'tapping SRA launcher opens CustomerFormSiteRiskSheet and applying updates SRA on controller',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final launcherBtn = find.byKey(const Key('sra_launcher_button'));
        await tester.ensureVisible(launcherBtn);
        await tester.tap(launcherBtn);
        await tester.pumpAndSettle();

        expect(find.byType(CustomerFormSiteRiskSheet), findsOneWidget);
        expect(find.text('Daftar Risiko Standar (Master)'), findsOneWidget);

        // Select a master risk
        await tester.tap(find.text('Area kerja licin'));
        await tester.pumpAndSettle();

        // Add a custom risk
        await tester.enterText(
          find.widgetWithText(TextField, 'Tambah risiko kustom...'),
          'Kabel tegangan tinggi',
        );
        await tester.tap(find.text('Tambah'));
        await tester.pumpAndSettle();

        expect(find.text('Kabel tegangan tinggi'), findsOneWidget);

        // Apply
        final applyBtn = find.byKey(const Key('sra_apply_button'));
        await tester.tap(applyBtn);
        await tester.pumpAndSettle();

        // Sheet closed
        expect(find.byType(CustomerFormSiteRiskSheet), findsNothing);

        // Controller updated
        expect(
          controller.locations.value.first.siteRiskIds,
          contains('risk-1'),
        );
        expect(
          controller.locations.value.first.customRisks,
          contains('Kabel tegangan tinggi'),
        );
        expect(find.text('2 Risiko Teridentifikasi'), findsOneWidget);
      },
    );
  });
}
