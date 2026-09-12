import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class MockPricingRepository implements PricingRepository {
  CreatePricingRequestDto? lastRequest;
  CreatePricingRequestDto? lastPreviewRequest;
  Result<void> response = const Ok(null);
  Result<PricingPreview>? previewResponse;
  Result<PricingDetail>? detailResponse;

  @override
  Future<Result<void>> savePricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async {
    lastRequest = data;
    return response;
  }

  @override
  Future<Result<PricingDetail>> getPricingDetail(String proposalId) async {
    return detailResponse ?? const Err(UnknownFailure('Not implemented'));
  }

  @override
  Future<Result<PricingPreview>> previewPricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async {
    lastPreviewRequest = data;
    return previewResponse ??
        const Ok(
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

  setUp(() {
    repository = MockPricingRepository();
    controller = PricingCalculatorController(repository);
  });

  tearDown(() {
    controller.dispose();
  });

  group('Pricing Rows', () {
    test('PricingSupplyRow calculates qty correctly', () {
      final row = PricingSupplyRow(
        id: '1',
        title: 'Chemical',
        code: 'CHM-1',
        uomCode: 'BTL',
        kind: 1,
        initialProductMappingId: 'pm-1',
        initialDoseUsage: 2.0,
        initialDoseUnitId: 'uom-ml',
        initialApplicationVolume: 5.0,
        initialApplicationVolumeUnitId: 'uom-l',
        initialFreq: 3.0,
      );

      // qty = 2.0 * 5.0 = 10.0
      expect(row.qty.value, 10.0);

      row.doseUsage.value = 4.0;
      expect(row.qty.value, 20.0);

      row.dispose();
    });

    test('PricingWorkerRow initializes and disposes correctly', () {
      final row = PricingWorkerRow(
        id: '2',
        title: 'Technician',
        code: 'LBR-1',
        kind: 4,
        initialVisitFreq: 4.0,
        initialFirstVisitMinutes: 180.0,
        initialRoutineMinutes: 120.0,
        initialHourlyRate: 100000.0,
      );

      expect(row.visitFreq.value, 4.0);
      expect(row.firstVisitMinutes.value, 180.0);
      expect(row.routineMinutes.value, 120.0);
      expect(row.hourlyRate.value, 100000.0);

      row.dispose();
    });

    test('PricingItemRow initializes and disposes correctly', () {
      final transportItem = PricingItemRow(
        id: '3',
        title: 'Transport',
        code: 'TR-1',
        kind: 3,
        initialQty: 2.0,
        initialFreq: 2.0,
        initialUnitPrice: 50000.0,
      );

      expect(transportItem.qty.value, 2.0);
      expect(transportItem.freq.value, 2.0);
      expect(transportItem.unitPrice.value, 50000.0);
      transportItem.dispose();

      final addonItem = PricingItemRow(
        id: '4',
        title: 'Addon',
        code: 'ADD-1',
        kind: 5,
        initialQty: 2.0,
        initialFreq: 2.0,
        initialUnitPrice: 50000.0,
      );

      expect(addonItem.qty.value, 2.0);
      expect(addonItem.freq.value, 2.0);
      expect(addonItem.unitPrice.value, 50000.0);
      addonItem.dispose();
    });
  });

  group('PricingCalculatorController - addRow', () {
    test(
      'addRow routes products to correct list signals based on expectedKind',
      () {
        const chemProduct = Product(
          id: 'p1',
          code: 'CHM-1',
          name: 'Chemical 1',
          uomId: 'u1',
          uomCode: 'BTL',
          cogs: 50000.0,
          isActive: true,
          kind: 1,
        );

        const toolProduct = Product(
          id: 'p2',
          code: 'TLS-1',
          name: 'Tool 1',
          uomId: 'u2',
          uomCode: 'UNIT',
          cogs: 75000.0,
          isActive: true,
          kind: 2,
        );

        const transportProduct = Product(
          id: 'p3',
          code: 'TR-1',
          name: 'Transport 1',
          uomId: 'u3',
          uomCode: 'KM',
          cogs: 20000.0,
          isActive: true,
          kind: 3,
        );

        const workerProduct = Product(
          id: 'p4',
          code: 'LBR-1',
          name: 'Technician 1',
          uomId: 'u4',
          uomCode: 'JAM',
          cogs: 100000.0,
          isActive: true,
          kind: 4,
        );

        const addonProduct = Product(
          id: 'p5',
          code: 'ADD-1',
          name: 'Addon 1',
          uomId: 'u5',
          uomCode: 'UNIT',
          cogs: 30000.0,
          isActive: true,
          kind: 5,
        );

        controller.addRow(chemProduct, 1);
        controller.addRow(toolProduct, 2);
        controller.addRow(workerProduct, 4);
        controller.addRow(transportProduct, 3);
        controller.addRow(addonProduct, 5);

        expect(controller.supplies.length, 2);
        expect(controller.workers.length, 1);
        expect(controller.items.length, 2);
      },
    );

    test(
      'addSupplyRow creates PricingSupplyRow correctly from ProductMapping',
      () {
        const mappingWithDefaultDose = ProductMapping(
          id: 'pm-101',
          productId: 'prod-1',
          productCode: 'CHM-101',
          productName: 'Termiticide Alpha',
          pestId: 'pest-1',
          pestName: 'Rayap',
          treatmentMethodId: 'tm-1',
          treatmentMethodCode: 'SPRAY',
          treatmentMethodName: 'Spraying Method',
          doseMinLimit: 1.5,
          doseMaxLimit: 3.5,
          doseUnitId: 'uom-ml',
          doseUnitCode: 'ML',
          defaultDose: 2.5,
        );

        controller.addSupplyRow(mappingWithDefaultDose);

        expect(controller.supplies.length, 1);
        final row1 = controller.supplies[0];
        expect(row1.id, 'prod-1');
        expect(row1.title, 'Termiticide Alpha');
        expect(row1.code, 'CHM-101');
        expect(row1.uomCode, 'ML');
        expect(row1.kind, 1);
        expect(row1.productMappingId.value, 'pm-101');
        expect(row1.doseUsage.value, 2.5);
        expect(row1.doseUnitId.value, 'uom-ml');

        const mappingWithoutDefaultDose = ProductMapping(
          id: 'pm-102',
          productId: 'prod-2',
          productCode: null,
          productName: 'Rodenticide Beta',
          pestId: 'pest-2',
          pestName: 'Tikus',
          treatmentMethodId: 'tm-2',
          treatmentMethodCode: 'BAIT',
          doseMinLimit: 5.0,
          doseMaxLimit: 10.0,
          doseUnitId: 'uom-gr',
          doseUnitCode: 'GR',
          defaultDose: null,
        );

        controller.addSupplyRow(mappingWithoutDefaultDose);

        expect(controller.supplies.length, 2);
        final row2 = controller.supplies[1];
        expect(row2.id, 'prod-2');
        expect(row2.title, 'Rodenticide Beta');
        expect(row2.code, '');
        expect(row2.uomCode, 'GR');
        expect(row2.kind, 1);
        expect(row2.productMappingId.value, 'pm-102');
        expect(row2.doseUsage.value, 5.0);
        expect(row2.doseUnitId.value, 'uom-gr');
      },
    );

    test('addRow throws StateError on cross-section attempt', () {
      const chemProduct = Product(
        id: 'p1',
        code: 'CHM-1',
        name: 'Chemical 1',
        uomId: 'u1',
        uomCode: 'BTL',
        cogs: 50000.0,
        isActive: true,
        kind: 1,
      );

      expect(
        () => controller.addRow(chemProduct, 4),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Cross section attempt',
          ),
        ),
      );
    });

    test('addSupplyRow prevents duplicate productId', () {
      const mapping1 = ProductMapping(
        id: 'pm-1',
        productId: 'prod-1',
        productName: 'Chemical A',
        pestId: 'pest-1',
        pestName: 'Pest 1',
        treatmentMethodId: 'tm-1',
        treatmentMethodCode: 'SPRAY',
        doseMinLimit: 1.0,
        doseMaxLimit: 2.0,
        doseUnitId: 'uom-1',
        doseUnitCode: 'ML',
      );
      const mappingDuplicate = ProductMapping(
        id: 'pm-2',
        productId: 'prod-1',
        productName: 'Chemical A (Alternate)',
        pestId: 'pest-1',
        pestName: 'Pest 1',
        treatmentMethodId: 'tm-1',
        treatmentMethodCode: 'SPRAY',
        doseMinLimit: 1.0,
        doseMaxLimit: 2.0,
        doseUnitId: 'uom-1',
        doseUnitCode: 'ML',
      );

      controller.addSupplyRow(mapping1);
      expect(controller.supplies.length, 1);

      controller.addSupplyRow(mappingDuplicate);
      expect(controller.supplies.length, 1);
    });

    test('addRow prevents duplicate supplies for kind 1 and 2', () {
      const chemProduct = Product(
        id: 'p1',
        code: 'CHM-1',
        name: 'Chemical 1',
        uomId: 'u1',
        uomCode: 'BTL',
        cogs: 50000.0,
        isActive: true,
        kind: 1,
      );
      const toolProduct = Product(
        id: 'p2',
        code: 'TLS-1',
        name: 'Tool 1',
        uomId: 'u2',
        uomCode: 'UNIT',
        cogs: 75000.0,
        isActive: true,
        kind: 2,
      );

      controller.addRow(chemProduct, 1);
      controller.addRow(chemProduct, 1);
      expect(controller.supplies.length, 1);

      controller.addRow(toolProduct, 2);
      controller.addRow(toolProduct, 2);
      expect(controller.supplies.length, 2);
    });

    test('addRow prevents duplicate items for kind 3 and 5', () {
      const transportProduct = Product(
        id: 'p3',
        code: 'TR-1',
        name: 'Transport 1',
        uomId: 'u3',
        uomCode: 'KM',
        cogs: 20000.0,
        isActive: true,
        kind: 3,
      );
      const addonProduct = Product(
        id: 'p5',
        code: 'ADD-1',
        name: 'Addon 1',
        uomId: 'u5',
        uomCode: 'UNIT',
        cogs: 30000.0,
        isActive: true,
        kind: 5,
      );

      controller.addRow(transportProduct, 3);
      controller.addRow(transportProduct, 3);
      expect(controller.items.length, 1);

      controller.addRow(addonProduct, 5);
      controller.addRow(addonProduct, 5);
      expect(controller.items.length, 2);
    });

    test('addRow allows duplicate workers for kind 4', () {
      const workerProduct = Product(
        id: 'p4',
        code: 'LBR-1',
        name: 'Technician 1',
        uomId: 'u4',
        uomCode: 'JAM',
        cogs: 100000.0,
        isActive: true,
        kind: 4,
      );

      controller.addRow(workerProduct, 4);
      controller.addRow(workerProduct, 4);
      expect(controller.workers.length, 2);
    });
  });

  group('PricingCalculatorController - submitPricing', () {
    test('submits pricing and updates submitState to UiSuccess', () async {
      controller.supplies.add(
        PricingSupplyRow(
          id: 'm1',
          title: 'Chemical',
          code: 'CHM',
          uomCode: 'BTL',
          kind: 1,
          initialProductMappingId: 'pm-1',
          initialDoseUsage: 2.0,
          initialDoseUnitId: 'uom-ml',
          initialApplicationVolume: 1.0,
          initialApplicationVolumeUnitId: 'uom-l',
          initialFreq: 1.0,
        ),
      );

      controller.contractMonths.value = 6;
      controller.markupPercent.value = 15.0;
      controller.taxPercentage.value = 5.0;

      await controller.submitPricing('prop-1');

      expect(controller.submitState.value, isA<UiSuccess<void>>());
      expect(repository.lastRequest, isNotNull);
      expect(repository.lastRequest!.contractMonths, 6);
      expect(repository.lastRequest!.markupType, 1);
      expect(repository.lastRequest!.markupValue, 15.0);
      expect(repository.lastRequest!.taxPercentage, 5.0);
      expect(repository.lastRequest!.supplies.length, 1);
      expect(repository.lastRequest!.supplies[0].supplyType, 1);
      expect(repository.lastRequest!.supplies[0].productMappingId, 'pm-1');
      expect(repository.lastRequest!.supplies[0].doseUsage, 2.0);
      expect(repository.lastRequest!.supplies[0].doseUnitId, 'uom-ml');
      expect(repository.lastRequest!.supplies[0].applicationVolume, 1.0);
      expect(
        repository.lastRequest!.supplies[0].applicationVolumeUnitId,
        'uom-l',
      );
    });

    test('updates submitState to UiFailure when repository fails', () async {
      repository.response = const Err(ServerFailure('Server Error'));

      await controller.submitPricing('prop-1');

      expect(controller.submitState.value, isA<UiFailure<void>>());
    });

    test(
      'validates worker minutes are non-negative on preview and submit',
      () async {
        controller.workers.add(
          PricingWorkerRow(
            id: 'w-1',
            title: 'Teknisi',
            code: 'LBR-1',
            kind: 4,
            initialVisitFreq: 2.0,
            initialFirstVisitMinutes: -10.0,
            initialRoutineMinutes: 60.0,
            initialHourlyRate: 50000.0,
          ),
        );

        await controller.previewPricing('prop-1');
        expect(controller.previewState.value, isA<UiFailure<PricingPreview>>());
        final previewFailure =
            (controller.previewState.value as UiFailure<PricingPreview>)
                .failure;
        expect(previewFailure.message, 'Menit kerja tidak boleh negatif.');

        await controller.submitPricing('prop-1');
        expect(controller.submitState.value, isA<UiFailure<void>>());
        final submitFailure =
            (controller.submitState.value as UiFailure<void>).failure;
        expect(submitFailure.message, 'Menit kerja tidak boleh negatif.');
      },
    );

    test('builds request with worker minutes on submit and preview', () async {
      controller.workers.add(
        PricingWorkerRow(
          id: 'w-1',
          title: 'Teknisi',
          code: 'LBR-1',
          kind: 4,
          initialVisitFreq: 4.0,
          initialFirstVisitMinutes: 180.0,
          initialRoutineMinutes: 90.0,
          initialHourlyRate: 50000.0,
        ),
      );

      await controller.previewPricing('prop-1');
      expect(repository.lastPreviewRequest, isNotNull);
      expect(repository.lastPreviewRequest!.workers.length, 1);
      expect(
        repository.lastPreviewRequest!.workers[0].firstVisitMinutes,
        180.0,
      );
      expect(repository.lastPreviewRequest!.workers[0].routineMinutes, 90.0);

      await controller.submitPricing('prop-1');
      expect(repository.lastRequest, isNotNull);
      expect(repository.lastRequest!.workers.length, 1);
      expect(repository.lastRequest!.workers[0].firstVisitMinutes, 180.0);
      expect(repository.lastRequest!.workers[0].routineMinutes, 90.0);
    });
  });

  group('PricingCalculatorController - loadExistingPricing', () {
    test(
      'loads existing pricing worker minutes into PricingWorkerRow',
      () async {
        repository.detailResponse = const Ok(
          PricingDetail(
            id: 'price-1',
            customerId: 'cust-1',
            serviceId: 'srv-1',
            contractMonths: 12,
            visitFrequency: 4,
            markupType: 1,
            markupValue: 20.0,
            discountAmount: 0.0,
            taxPercentage: 11.0,
            supplies: [],
            workers: [
              PricingDetailWorker(
                id: 'pw-1',
                productId: 'prod-tech',
                positionName: 'Senior Technician',
                visitFrequency: 4,
                firstVisitMinutes: 240.0,
                routineMinutes: 120.0,
                hourlyRate: 100000.0,
                lineTotal: 1200000.0,
              ),
            ],
            items: [],
          ),
        );

        await controller.loadExistingPricing('prop-1');

        expect(
          controller.existingPricingState.value,
          isA<UiSuccess<PricingDetail>>(),
        );
        expect(controller.workers.length, 1);
        final workerRow = controller.workers[0];
        expect(workerRow.id, 'prod-tech');
        expect(workerRow.title, 'Senior Technician');
        expect(workerRow.visitFreq.value, 4.0);
        expect(workerRow.firstVisitMinutes.value, 240.0);
        expect(workerRow.routineMinutes.value, 120.0);
        expect(workerRow.hourlyRate.value, 100000.0);
      },
    );
  });
}
