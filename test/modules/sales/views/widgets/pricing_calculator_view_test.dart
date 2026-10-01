import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pricing_calculator_view.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/counter_input.dart';

class MockPricingRepository implements PricingRepository {
  @override
  Future<Result<void>> savePricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async {
    return const Ok(null);
  }

  @override
  Future<Result<PricingDetail>> getPricingDetail(String proposalId) async {
    return const Err(UnknownFailure('Not implemented'));
  }

  @override
  Future<Result<PricingPreview>> previewPricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async {
    return const Ok(
      PricingPreview(
        suppliesCost: 0,
        workerCost: 0,
        fuelCost: 0,
        totalCogs: 0,
        servicePrice: 0,
        addonAmount: 0,
        discountAmount: 0,
        subtotal: 0,
        taxPercentage: 0,
        taxAmount: 0,
        totalAmount: 0,
        marginAmount: 0,
        marginPercent: 0,
        supplies: [],
        workers: [],
        items: [],
      ),
    );
  }
}

void main() {
  late MockPricingRepository repository;
  late PricingCalculatorController controller;

  const sampleProposal = Proposal(
    id: 'prop-1',
    code: 'PROP-2026-0001',
    clientName: 'Villa Sari Dewi',
    serviceName: 'Termite Protection',
    status: ProposalStatus.sent,
    date: '2026-09-01',
    validUntil: '2026-09-30',
    location: 'Seminyak',
    hasPricing: true,
  );

  setUp(() {
    repository = MockPricingRepository();
    controller = PricingCalculatorController(repository);
  });

  tearDown(() {
    controller.dispose();
  });

  Widget createWidget({required bool isReadOnly}) {
    return MaterialApp(
      home: Scaffold(
        body: PricingCalculatorView(
          proposal: sampleProposal,
          calculatorController: controller,
          isReadOnly: isReadOnly,
        ),
      ),
    );
  }

  void populateSampleRows() {
    controller.supplies.add(
      PricingSupplyRow(
        id: 'mat-1',
        title: 'Termidor 25EC',
        code: 'CHM-01',
        uomCode: 'BTL',
        kind: 1,
        initialProductMappingId: 'pm-1',
        initialDoseUsage: 2.0,
        initialDoseUnitId: 'u-1',
        initialApplicationVolume: 5.0,
        initialApplicationVolumeUnitId: 'u-2',
        initialFreq: 2.0,
      ),
    );

    controller.workers.add(
      PricingWorkerRow(
        id: 'w-1',
        title: 'Teknisi Senior',
        code: 'LBR-01',
        kind: 4,
        initialVisitFreq: 4.0,
        initialFirstVisitMinutes: 180.0,
        initialRoutineMinutes: 120.0,
        initialHourlyRate: 50000.0,
      ),
    );

    controller.items.add(
      PricingItemRow(
        id: 'item-1',
        title: 'BBM Operasional',
        code: 'TRP-01',
        kind: 3,
        initialQty: 4.0,
        initialFreq: 1.0,
        initialUnitPrice: 25000.0,
      ),
    );
  }

  testWidgets(
    'PricingCalculatorView with isReadOnly: true hides add/delete buttons and locks action button',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      populateSampleRows();

      await tester.pumpWidget(createWidget(isReadOnly: true));
      await tester.pumpAndSettle();

      // Tab 0: Persiapan Bahan & Alat
      // Verify 'Tambah Bahan Kimia' and 'Tambah Alat' are NOT present
      expect(find.text('Tambah Bahan Kimia'), findsNothing);
      expect(find.text('Tambah Alat'), findsNothing);
      // Verify delete button icon Icons.close_rounded is NOT present
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      // Switch to Tab 1: Tenaga Kerja
      await tester.tap(find.text('Tenaga Kerja'));
      await tester.pumpAndSettle();

      // Verify 'Tambah Teknisi' is NOT present
      expect(find.text('Tambah Teknisi'), findsNothing);
      // Verify delete button icon Icons.close_rounded is NOT present
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      // Switch to Tab 2: Transport & Add-on
      await tester.tap(find.text('Transport & Add-on'));
      await tester.pumpAndSettle();

      // Verify 'BBM' and 'Add-on' are NOT present
      expect(find.text('BBM'), findsNothing);
      expect(find.text('Add-on'), findsNothing);
      // Verify delete button icon Icons.close_rounded is NOT present
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      // Verify bottom action button displays 'Kalkulasi Terkunci' and is disabled
      expect(find.text('Kalkulasi Terkunci'), findsOneWidget);
      final lockButton = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Kalkulasi Terkunci'),
      );
      expect(lockButton.onPressed, isNull);
    },
  );

  testWidgets(
    'PricingCalculatorView with isReadOnly: false shows add/delete buttons and enabled action button',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      populateSampleRows();

      await tester.pumpWidget(createWidget(isReadOnly: false));
      await tester.pumpAndSettle();

      // Tab 0: Persiapan Bahan & Alat
      expect(find.text('Tambah Bahan Kimia'), findsOneWidget);
      expect(find.text('Tambah Alat'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Switch to Tab 1: Tenaga Kerja
      await tester.tap(find.text('Tenaga Kerja'));
      await tester.pumpAndSettle();

      expect(find.text('MENIT AWAL'), findsOneWidget);
      expect(find.text('MENIT ROUTINE'), findsOneWidget);
      expect(find.text('Tambah Teknisi'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Switch to Tab 2: Transport & Add-on
      await tester.tap(find.text('Transport & Add-on'));
      await tester.pumpAndSettle();

      expect(find.text('BBM'), findsOneWidget);
      expect(find.text('Add-on'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Bottom action button displays 'Lihat Ringkasan' and is enabled
      expect(find.text('Lihat Ringkasan'), findsOneWidget);
      final previewButton = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Lihat Ringkasan'),
      );
      expect(previewButton.onPressed, isNotNull);
    },
  );

  testWidgets(
    'CounterInput is used for supply freq, worker visits/minutes, and pricing item qty/freq',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      populateSampleRows();

      await tester.pumpWidget(createWidget(isReadOnly: false));
      await tester.pumpAndSettle();

      // Tab 0: Persiapan Bahan & Alat
      // 4 CounterInputs in chemical row: spkDoseUsage, doseUsage, applicationVolume, freq
      expect(find.byType(CounterInput), findsNWidgets(4));
      final supplyRow = controller.supplies.first;
      expect(supplyRow.freq.value, 2.0);

      // Switch to Tab 1: Tenaga Kerja
      await tester.tap(find.text('Tenaga Kerja'));
      await tester.pumpAndSettle();

      // 3 CounterInputs in worker row: visitFreq, firstVisitMinutes, routineMinutes
      expect(find.byType(CounterInput), findsNWidgets(3));
      final workerRow = controller.workers.first;
      expect(workerRow.visitFreq.value, 4.0);
      expect(workerRow.firstVisitMinutes.value, 180.0);
      expect(workerRow.routineMinutes.value, 120.0);

      // Switch to Tab 2: Transport & Add-on
      await tester.tap(find.text('Transport & Add-on'));
      await tester.pumpAndSettle();

      // 2 CounterInputs in item row: qty, freq
      expect(find.byType(CounterInput), findsNWidgets(2));
      final itemRow = controller.items.first;
      expect(itemRow.qty.value, 4.0);
      expect(itemRow.freq.value, 1.0);
    },
  );

  testWidgets(
    'PricingItemTab renders formatted price for BBM and editable input for Add-on',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      populateSampleRows();
      controller.items.add(
        PricingItemRow(
          id: 'item-addon',
          title: 'Extra Disinfection',
          code: 'ADD-01',
          kind: 5,
          initialQty: 1.0,
          initialFreq: 1.0,
          initialUnitPrice: 50000.0,
        ),
      );

      await tester.pumpWidget(createWidget(isReadOnly: false));
      await tester.pumpAndSettle();

      // Switch to Tab 2: Transport & Add-on
      await tester.tap(find.text('Transport & Add-on'));
      await tester.pumpAndSettle();

      // BBM (kind 3) renders formatted currency 'Rp 25.000'
      expect(find.text('Rp 25.000'), findsOneWidget);

      // Add-on (kind 5) renders editable TextFormField with initial price
      expect(find.widgetWithText(TextFormField, '50000'), findsOneWidget);
    },
  );

  testWidgets(
    'PricingItemTab adds custom item via "+ Item Kustom" and allows inline title and price editing',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      populateSampleRows();

      await tester.pumpWidget(createWidget(isReadOnly: false));
      await tester.pumpAndSettle();

      // Switch to Tab 2: Transport & Add-on
      await tester.tap(find.text('Transport & Add-on'));
      await tester.pumpAndSettle();

      // Verify button "+ Item Kustom" exists
      expect(find.text('Item Kustom'), findsOneWidget);

      // Tap "+ Item Kustom"
      await tester.tap(find.text('Item Kustom'));
      await tester.pumpAndSettle();

      expect(controller.items.length, 2);
      final customRow = controller.items.last;
      expect(customRow.kind, 0);

      // Verify TextFormField with default title exists
      final titleFieldFinder = find.widgetWithText(
        TextFormField,
        'Item Kustom',
      );
      expect(titleFieldFinder, findsOneWidget);

      // Edit title
      await tester.enterText(titleFieldFinder, 'Sewa Mobil Box');
      await tester.pumpAndSettle();
      expect(customRow.title.value, 'Sewa Mobil Box');

      // Edit price
      final priceFieldFinder = find.widgetWithText(TextFormField, '0');
      expect(priceFieldFinder, findsOneWidget);
      await tester.enterText(priceFieldFinder, '350000');
      await tester.pumpAndSettle();
      expect(customRow.unitPrice.value, 350000.0);

      // Delete custom item
      final closeIcons = find.byIcon(Icons.close_rounded);
      expect(closeIcons, findsNWidgets(2));
      await tester.tap(closeIcons.last);
      await tester.pumpAndSettle();

      expect(controller.items.length, 1);
    },
  );
}
