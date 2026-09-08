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
    controller.materials.add(
      PricingMaterialRow(
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
        initialFirstVisitHours: 3.0,
        initialRoutineHours: 2.0,
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
}
