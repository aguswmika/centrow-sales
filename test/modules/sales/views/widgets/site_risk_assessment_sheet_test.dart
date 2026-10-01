import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/site_risk_controller.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/site_risk.dart';
import 'package:centrow_sales/modules/sales/repositories/site_risk_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_locations_tab.dart';
import 'package:centrow_sales/modules/sales/views/widgets/site_risk_assessment_sheet.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class MockSiteRiskRepository implements SiteRiskRepository {
  List<SiteRiskMaster> masters = [
    const SiteRiskMaster(id: 'risk-1', name: 'Area kerja licin'),
    const SiteRiskMaster(id: 'risk-2', name: 'Bekerja di ketinggian'),
    const SiteRiskMaster(id: 'risk-3', name: 'Bahan kimia berbahaya'),
  ];

  List<CustomerAddressRisk> addressRisks = [
    const CustomerAddressRisk(
      id: 'addr-risk-1',
      siteRiskId: 'risk-1',
      name: 'Area kerja licin',
      isCustom: false,
    ),
    const CustomerAddressRisk(
      id: 'addr-risk-retained',
      siteRiskId: 'old-risk-99',
      name: 'Bahaya tegangan tinggi lama',
      isCustom: false,
    ),
    const CustomerAddressRisk(
      id: 'addr-risk-custom',
      siteRiskId: null,
      name: 'Anjing galak di halaman',
      isCustom: true,
    ),
  ];

  Result<List<SiteRiskMaster>>? mastersResultOverride;
  Result<List<CustomerAddressRisk>>? addressRisksResultOverride;
  Result<List<CustomerAddressRisk>>? updateResultOverride;

  int getMastersCalls = 0;
  int getAddressRisksCalls = 0;
  int updateCalls = 0;
  List<String> lastUpdatedSiteRiskIds = [];
  List<String> lastUpdatedCustomRisks = [];

  @override
  Future<Result<List<SiteRiskMaster>>> getSiteRiskMasters() async {
    getMastersCalls++;
    return mastersResultOverride ?? Ok(masters);
  }

  @override
  Future<Result<List<CustomerAddressRisk>>> getAddressRisks({
    required String customerId,
    required String addressId,
  }) async {
    getAddressRisksCalls++;
    return addressRisksResultOverride ?? Ok(addressRisks);
  }

  @override
  Future<Result<List<CustomerAddressRisk>>> updateAddressRisks({
    required String customerId,
    required String addressId,
    required List<String> siteRiskIds,
    required List<String> customRisks,
  }) async {
    updateCalls++;
    lastUpdatedSiteRiskIds = siteRiskIds;
    lastUpdatedCustomRisks = customRisks;
    return updateResultOverride ?? Ok(addressRisks);
  }
}

void main() {
  late MockSiteRiskRepository mockRepository;

  const testLocation = CustomerLocation(
    id: 'loc-1',
    customerId: 'cust-1',
    label: 'Gudang Utama',
    addressLine: 'Jl. Sunset Road No. 88, Kuta',
    isPrimary: true,
  );

  setUp(() {
    mockRepository = MockSiteRiskRepository();
    if (getIt.isRegistered<SiteRiskRepository>()) {
      getIt.unregister<SiteRiskRepository>();
    }
    if (getIt.isRegistered<SiteRiskController>()) {
      getIt.unregister<SiteRiskController>();
    }
    getIt.registerSingleton<SiteRiskRepository>(mockRepository);
    getIt.registerFactory<SiteRiskController>(
      () => SiteRiskController(getIt<SiteRiskRepository>()),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<SiteRiskRepository>()) {
      getIt.unregister<SiteRiskRepository>();
    }
    if (getIt.isRegistered<SiteRiskController>()) {
      getIt.unregister<SiteRiskController>();
    }
  });

  Widget buildTestWidget({VoidCallback? onSaved}) {
    return MaterialApp(
      home: Scaffold(
        body: SiteRiskAssessmentSheet(
          customerId: 'cust-1',
          location: testLocation,
          onSaved: onSaved,
        ),
      ),
    );
  }

  group('SiteRiskAssessmentSheet', () {
    testWidgets(
      'renders header, master risks, retained risks, and custom risks',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Header verification
        expect(find.text('Site Risk Assessment'), findsOneWidget);
        expect(
          find.textContaining('Gudang Utama • Jl. Sunset Road No. 88, Kuta'),
          findsOneWidget,
        );

        // Section titles
        expect(find.text('Daftar Risiko Standar (Master)'), findsOneWidget);
        expect(
          find.text('Risiko Tersimpan Sebelumnya (Non-Master)'),
          findsOneWidget,
        );
        expect(find.text('Risiko Kustom Tambahan'), findsOneWidget);

        // Master items rendered
        expect(find.text('Area kerja licin'), findsOneWidget);
        expect(find.text('Bekerja di ketinggian'), findsOneWidget);
        expect(find.text('Bahan kimia berbahaya'), findsOneWidget);

        // Retained item rendered
        expect(find.text('Bahaya tegangan tinggi lama'), findsOneWidget);

        // Custom risk rendered
        expect(find.text('Anjing galak di halaman'), findsOneWidget);

        // Save button
        expect(find.text('Simpan Penilaian'), findsOneWidget);
      },
    );

    testWidgets('toggles master risk checklist selection', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Initially 'Area kerja licin' is checked from addressRisks
      // 'Bekerja di ketinggian' is unchecked.
      final ketinggianFinder = find.text('Bekerja di ketinggian');
      expect(ketinggianFinder, findsOneWidget);

      // Tap 'Bekerja di ketinggian' to toggle it ON
      await tester.tap(ketinggianFinder);
      await tester.pumpAndSettle();

      // Tap 'Area kerja licin' to toggle it OFF
      await tester.tap(find.text('Area kerja licin'));
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Simpan Penilaian'));
      await tester.pumpAndSettle();

      expect(mockRepository.updateCalls, 1);
      // 'risk-2' should be in the saved payload, and 'old-risk-99' (retained) remains selected
      expect(mockRepository.lastUpdatedSiteRiskIds, contains('risk-2'));
      expect(mockRepository.lastUpdatedSiteRiskIds, contains('old-risk-99'));
      expect(mockRepository.lastUpdatedSiteRiskIds, isNot(contains('risk-1')));
    });

    testWidgets('adds and removes custom risks', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Existing custom risk
      expect(find.text('Anjing galak di halaman'), findsOneWidget);

      // Enter new custom risk
      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'Akses jalan terjal');
      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      expect(find.text('Akses jalan terjal'), findsOneWidget);

      // Delete the first custom risk ('Anjing galak di halaman')
      final deleteButtons = find.byTooltip('Hapus Risiko Kustom');
      expect(deleteButtons, findsNWidgets(2));
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Anjing galak di halaman'), findsNothing);
      expect(find.text('Akses jalan terjal'), findsOneWidget);

      // Save and verify custom risks payload
      await tester.tap(find.text('Simpan Penilaian'));
      await tester.pumpAndSettle();

      expect(mockRepository.updateCalls, 1);
      expect(mockRepository.lastUpdatedCustomRisks, ['Akses jalan terjal']);
    });

    testWidgets(
      'handles successful save: calls onSaved and pops bottom sheet',
      (tester) async {
        bool onSavedCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => SiteRiskAssessmentSheet(
                          customerId: 'cust-1',
                          location: testLocation,
                          onSaved: () => onSavedCalled = true,
                        ),
                      );
                    },
                    child: const Text('Open SRA'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open SRA'));
        await tester.pumpAndSettle();

        expect(find.text('Site Risk Assessment'), findsOneWidget);

        await tester.tap(find.text('Simpan Penilaian'));
        await tester.pumpAndSettle();

        expect(onSavedCalled, isTrue);
        // Bottom sheet should be popped
        expect(find.text('Site Risk Assessment'), findsNothing);
        expect(find.text('Penilaian risiko berhasil disimpan'), findsOneWidget);
      },
    );

    testWidgets('displays error feedback when save fails', (tester) async {
      mockRepository.updateResultOverride = const Err(
        ServerFailure('Gagal menyimpan penilaian risiko (400)'),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Penilaian'));
      await tester.pumpAndSettle();

      // Check inline banner / SnackBar
      expect(
        find.text('Gagal menyimpan penilaian risiko (400)'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets(
      'displays error view with retry button on initial load failure',
      (tester) async {
        mockRepository.mastersResultOverride = const Err(
          NetworkFailure('Gagal menghubungkan ke server'),
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Gagal menghubungkan ke server'), findsOneWidget);
        expect(find.text('Coba Lagi'), findsOneWidget);

        // Now set to success and tap retry
        mockRepository.mastersResultOverride = null;
        await tester.tap(find.text('Coba Lagi'));
        await tester.pumpAndSettle();

        expect(find.text('Daftar Risiko Standar (Master)'), findsOneWidget);
      },
    );
  });

  group('CustomerLocationsTab integration', () {
    testWidgets(
      'renders Penilaian Risiko (SRA) button on location card and opens sheet',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomerLocationsTab(
                locations: [testLocation],
                customerId: 'cust-1',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Penilaian Risiko (SRA)'), findsOneWidget);

        await tester.tap(find.text('Penilaian Risiko (SRA)'));
        await tester.pumpAndSettle();

        expect(find.text('Site Risk Assessment'), findsOneWidget);
      },
    );
  });
}
