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

      expect(transportItem.title.value, 'Transport');
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

      expect(addonItem.title.value, 'Addon');
      expect(addonItem.qty.value, 2.0);
      expect(addonItem.freq.value, 2.0);
      expect(addonItem.unitPrice.value, 50000.0);
      addonItem.dispose();

      final customItem = PricingItemRow(
        id: 'custom-1',
        title: 'Sewa Alat Khusus',
        code: '',
        kind: 0,
        initialQty: 1.0,
        initialFreq: 1.0,
        initialUnitPrice: 75000.0,
      );

      expect(customItem.kind, 0);
      expect(customItem.title.value, 'Sewa Alat Khusus');
      customItem.title.value = 'Sewa Truk';
      expect(customItem.title.value, 'Sewa Truk');
      expect(customItem.unitPrice.value, 75000.0);
      customItem.dispose();
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
        expect(row1.treatmentMethodId.value, 'tm-1');
        expect(row1.treatmentMethodName.value, 'Spraying Method');
        expect(row1.treatmentMethodCode.value, 'SPRAY');

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
        expect(row2.treatmentMethodId.value, 'tm-2');
        expect(row2.treatmentMethodCode.value, 'BAIT');
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

    test('addCustomItem creates row with kind == 0 and unique id', () {
      controller.addCustomItem(
        defaultTitle: 'Biaya Perizinan',
        initialPrice: 150000.0,
      );

      expect(controller.items.length, 1);
      final item = controller.items.first;
      expect(item.kind, 0);
      expect(item.title.value, 'Biaya Perizinan');
      expect(item.unitPrice.value, 150000.0);
      expect(item.id.startsWith('custom_'), isTrue);
      expect(item.code, '');
    });

    test('validateInputs rejects custom items with empty title', () {
      controller.totalVisits.value = 10;
      controller.addCustomItem(defaultTitle: '   ', initialPrice: 10000.0);

      expect(
        controller.validateInputs(),
        'Nama item kustom tidak boleh kosong.',
      );

      controller.items.first.title.value = 'Valid Title';
      expect(controller.validateInputs(), isNull);
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
          initialTreatmentMethodId: 'tm-1',
          initialDoseUsage: 2.0,
          initialDoseUnitId: 'uom-ml',
          initialApplicationVolume: 1.0,
          initialApplicationVolumeUnitId: 'uom-l',
          initialFreq: 1.0,
        ),
      );

      controller.contractMonths.value = 6;
      controller.totalVisits.value = 12;
      controller.markupPercent.value = 15.0;
      controller.taxPercentage.value = 5.0;

      await controller.submitPricing('prop-1');

      expect(controller.submitState.value, isA<UiSuccess<void>>());
      expect(repository.lastRequest, isNotNull);
      expect(repository.lastRequest!.contractMonths, 6);
      expect(repository.lastRequest!.totalVisits, 12);
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
      controller.totalVisits.value = 12;
      repository.response = const Err(ServerFailure('Server Error'));

      await controller.submitPricing('prop-1');

      expect(controller.submitState.value, isA<UiFailure<void>>());
    });

    test(
      'validates worker minutes are non-negative on preview and submit',
      () async {
        controller.totalVisits.value = 12;
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
      controller.totalVisits.value = 12;
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
            totalVisits: 48,
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

    test(
      'loads existing pricing totalVisits and supply row metadata into signals',
      () async {
        repository.detailResponse = const Ok(
          PricingDetail(
            id: 'price-1',
            customerId: 'cust-1',
            serviceId: 'srv-1',
            contractMonths: 12,
            visitFrequency: 4,
            totalVisits: 48,
            markupType: 1,
            markupValue: 20.0,
            discountAmount: 0.0,
            taxPercentage: 11.0,
            supplies: [
              PricingDetailSupply(
                id: 'sup-1',
                supplyType: 1,
                name: 'Chemical A',
                uomCode: 'LTR',
                qty: 5.0,
                doseUsage: 2.0,
                doseUnitId: 'uom-1',
                applicationVolume: 1.0,
                applicationVolumeUnitId: 'uom-2',
                frequency: 4,
                unitCost: 10000.0,
                lineTotal: 40000.0,
                treatmentMethodId: 'tm-spray',
                areaKerja: 'Kitchen',
                note: 'Handle with care',
              ),
              PricingDetailSupply(
                id: 'sup-2',
                supplyType: 2,
                productId: 'prod-trap',
                name: 'Rodent Box',
                uomCode: 'PCS',
                qty: 10.0,
                doseUnitId: '',
                applicationVolumeUnitId: '',
                frequency: 1,
                unitCost: 25000.0,
                lineTotal: 250000.0,
                treatmentMethodId: 'tm-bait',
                areaKerja: 'Perimeter',
                note: 'Outdoor setup',
                installedUnits: 8,
              ),
            ],
            workers: [],
            items: [],
          ),
        );

        await controller.loadExistingPricing('prop-1');

        expect(controller.totalVisits.value, 48);
        expect(controller.contractMonths.value, 12);
        expect(controller.visitFrequency.value, 4);
        expect(controller.supplies.length, 2);

        final chemical = controller.supplies[0];
        expect(chemical.treatmentMethodId.value, 'tm-spray');
        expect(chemical.areaKerja.value, 'Kitchen');
        expect(chemical.note.value, 'Handle with care');

        final tool = controller.supplies[1];
        expect(tool.treatmentMethodId.value, 'tm-bait');
        expect(tool.areaKerja.value, 'Perimeter');
        expect(tool.note.value, 'Outdoor setup');
        expect(tool.installedUnits.value, 8);
      },
    );
  });

  group('PricingCalculatorController - Total Visits & Supply Metadata', () {
    test('validation fails when totalVisits is null or non-positive', () async {
      controller.contractMonths.value = 12;
      controller.visitFrequency.value = 4;
      controller.totalVisits.value = 0;

      await controller.submitPricing('prop-1');
      expect(controller.submitState.value, isA<UiFailure<void>>());

      final failure = controller.submitState.value as UiFailure<void>;
      expect(failure.failure.message, contains('Total kunjungan'));
    });

    test(
      'validation fails when tool has missing or non-positive installedUnits',
      () async {
        controller.contractMonths.value = 12;
        controller.visitFrequency.value = 4;
        controller.totalVisits.value = 48;

        controller.supplies.add(
          PricingSupplyRow(
            id: 'tool-1',
            title: 'Insect Light Trap',
            code: 'T-01',
            uomCode: 'UNIT',
            kind: 2,
            initialTreatmentMethodId: 'tm-1',
            initialDoseUsage: 1.0,
          ),
        );

        // Set installedUnits to 0
        controller.supplies.first.installedUnits.value = 0;
        await controller.submitPricing('prop-1');
        expect(controller.submitState.value, isA<UiFailure<void>>());

        final failure = controller.submitState.value as UiFailure<void>;
        expect(failure.failure.message, contains('unit terpasang'));

        // Set installedUnits > 0
        controller.supplies.first.installedUnits.value = 5;
        await controller.submitPricing('prop-1');
        expect(controller.submitState.value, isA<UiSuccess<void>>());
      },
    );

    test(
      'submitPricing and previewPricing include total_visits and supply fields',
      () async {
        controller.contractMonths.value = 12;
        controller.visitFrequency.value = 4;
        controller.totalVisits.value = 48;

        controller.supplies.add(
          PricingSupplyRow(
            id: 'tool-1',
            title: 'Insect Light Trap',
            code: 'T-01',
            uomCode: 'UNIT',
            kind: 2,
            initialTreatmentMethodId: 'tm-1',
            initialDoseUsage: 1.0,
          ),
        );
        controller.supplies.first.installedUnits.value = 3;
        controller.supplies.first.areaKerja.value = 'Dining Hall';
        controller.supplies.first.note.value = 'Clean monthly';

        await controller.previewPricing('prop-1');
        expect(repository.lastPreviewRequest, isNotNull);
        expect(repository.lastPreviewRequest!.totalVisits, 48);
        expect(repository.lastPreviewRequest!.supplies.first.installedUnits, 3);
        expect(
          repository.lastPreviewRequest!.supplies.first.areaKerja,
          'Dining Hall',
        );
        expect(
          repository.lastPreviewRequest!.supplies.first.note,
          'Clean monthly',
        );

        await controller.submitPricing('prop-1');
        expect(repository.lastRequest, isNotNull);
        expect(repository.lastRequest!.totalVisits, 48);
        expect(repository.lastRequest!.supplies.first.installedUnits, 3);
        expect(repository.lastRequest!.supplies.first.areaKerja, 'Dining Hall');
        expect(repository.lastRequest!.supplies.first.note, 'Clean monthly');
      },
    );

    test('auto-calculates totalVisits and allows direct manual override', () {
      // 1. Setting contractMonths and visitFrequency auto-calculates totalVisits
      controller.setContractMonths(3);
      controller.setVisitFrequency(4);
      expect(controller.totalVisits.value, 12);

      controller.setContractMonths(12);
      controller.setVisitFrequency(2);
      expect(controller.totalVisits.value, 24);

      // 2. User can directly override totalVisits
      controller.setTotalVisits(15);
      expect(controller.totalVisits.value, 15);

      // 3. Changing contract parameters again recalculates totalVisits
      controller.setContractMonths(6);
      expect(controller.totalVisits.value, 12); // 6 * 2

      // 4. If either is null, totalVisits is null
      controller.setVisitFrequency(null);
      expect(controller.totalVisits.value, isNull);
    });
  });

  group('PricingCalculatorController - scheduleWorkOrderType', () {
    test('defaults to 1 on fresh controller', () {
      expect(controller.scheduleWorkOrderType.value, 1);
    });

    test('setScheduleWorkOrderType updates the signal', () {
      controller.setScheduleWorkOrderType(2);
      expect(controller.scheduleWorkOrderType.value, 2);
    });

    test('buildRequest() includes the updated scheduleWorkOrderType', () {
      controller.totalVisits.value = 12;
      controller.setScheduleWorkOrderType(2);

      final request = controller.buildRequest();
      expect(request.scheduleWorkOrderType, 2);
      expect(request.toJson()['schedule_work_order_type'], 2);
    });

    test(
      'loadExistingPricing restores scheduleWorkOrderType from PricingDetail',
      () async {
        repository.detailResponse = const Ok(
          PricingDetail(
            id: 'price-x',
            customerId: 'cust-x',
            serviceId: 'srv-x',
            contractMonths: 12,
            visitFrequency: 2,
            totalVisits: 24,
            markupType: 1,
            markupValue: 0.0,
            discountAmount: 0.0,
            taxPercentage: 0.0,
            scheduleWorkOrderType: 2,
            supplies: [],
            workers: [],
            items: [],
          ),
        );

        await controller.loadExistingPricing('prop-x');

        expect(controller.scheduleWorkOrderType.value, 2);
      },
    );

    test(
      'buildRequest() serializes custom item as item_type 2 with product_id null',
      () {
        controller.totalVisits.value = 10;
        controller.addCustomItem(
          defaultTitle: 'Sewa Generator',
          initialPrice: 250000.0,
        );
        final request = controller.buildRequest();

        expect(request.items.length, 1);
        final itemDto = request.items.first;
        expect(itemDto.itemType, 2);
        expect(itemDto.productId, isNull);
        expect(itemDto.name, 'Sewa Generator');
        expect(itemDto.unitPrice, 250000.0);
        expect(itemDto.toJson().containsKey('product_id'), isFalse);
        expect(itemDto.toJson()['item_type'], 2);
      },
    );

    test('loadExistingPricing restores custom item as kind 0', () async {
      repository.detailResponse = const Ok(
        PricingDetail(
          id: 'price-custom',
          customerId: 'cust-1',
          serviceId: 'srv-1',
          contractMonths: 12,
          visitFrequency: 1,
          totalVisits: 12,
          markupType: 1,
          markupValue: 0.0,
          discountAmount: 0.0,
          taxPercentage: 0.0,
          supplies: [],
          workers: [],
          items: [
            PricingDetailItem(
              id: 'custom-saved-1',
              itemType: 2,
              productId: null,
              code: '',
              name: 'Biaya Fogging Khusus',
              qty: 2.0,
              frequency: 1,
              unitCost: 0.0,
              unitPrice: 150000.0,
              lineTotal: 300000.0,
            ),
          ],
        ),
      );

      await controller.loadExistingPricing('prop-custom');

      expect(controller.items.length, 1);
      final restored = controller.items.first;
      expect(restored.kind, 0);
      expect(restored.title.value, 'Biaya Fogging Khusus');
      expect(restored.unitPrice.value, 150000.0);
      expect(restored.qty.value, 2.0);
    });

    test('validateInputs requires treatmentMethodId for all supply lines', () {
      controller.totalVisits.value = 10;
      final chemRow = PricingSupplyRow(
        id: 'chem-1',
        title: 'Chemical 1',
        code: 'CHM-1',
        uomCode: 'ML',
        kind: 1,
        initialTreatmentMethodId: null,
        initialDoseUsage: 5.0,
        initialSpkDoseUsage: 5.0,
      );
      controller.supplies.add(chemRow);

      expect(
        controller.validateInputs(),
        'Metode penanganan untuk Chemical 1 wajib dipilih.',
      );

      chemRow.treatmentMethodId.value = 'tm-1';
      expect(controller.validateInputs(), isNull);

      final toolRow = PricingSupplyRow(
        id: 'tool-1',
        title: 'Tool 1',
        code: 'TL-1',
        uomCode: 'UNIT',
        kind: 2,
        initialTreatmentMethodId: '',
        initialDoseUsage: 1.0,
        initialInstalledUnits: 1,
      );
      controller.supplies.add(toolRow);

      expect(
        controller.validateInputs(),
        'Metode penanganan untuk Tool 1 wajib dipilih.',
      );

      toolRow.treatmentMethodId.value = 'tm-2';
      expect(controller.validateInputs(), isNull);
    });

    test(
      'validateInputs requires positive spkDoseUsage for chemical lines',
      () {
        controller.totalVisits.value = 10;
        final chemRow = PricingSupplyRow(
          id: 'chem-1',
          title: 'Chemical 1',
          code: 'CHM-1',
          uomCode: 'ML',
          kind: 1,
          initialTreatmentMethodId: 'tm-1',
          initialDoseUsage: 5.0,
          initialSpkDoseUsage: 0.0,
        );
        controller.supplies.add(chemRow);

        expect(
          controller.validateInputs(),
          'Dosis SPK untuk Chemical 1 harus lebih dari 0.',
        );

        chemRow.spkDoseUsage.value = -1.0;
        expect(
          controller.validateInputs(),
          'Dosis SPK untuk Chemical 1 harus lebih dari 0.',
        );

        chemRow.spkDoseUsage.value = 60.0;
        expect(controller.validateInputs(), isNull);
      },
    );

    test(
      'buildRequest includes spk_dose_usage on chemicals and omits on tools',
      () {
        controller.totalVisits.value = 10;
        controller.supplies.add(
          PricingSupplyRow(
            id: 'chem-1',
            title: 'Chemical 1',
            code: 'CHM-1',
            uomCode: 'ML',
            kind: 1,
            initialTreatmentMethodId: 'tm-1',
            initialDoseUsage: 5.0,
            initialSpkDoseUsage: 60.0,
          ),
        );
        controller.supplies.add(
          PricingSupplyRow(
            id: 'tool-1',
            title: 'Tool 1',
            code: 'TL-1',
            uomCode: 'UNIT',
            kind: 2,
            initialTreatmentMethodId: 'tm-2',
            initialDoseUsage: 1.0,
            initialInstalledUnits: 2,
          ),
        );

        final req = controller.buildRequest();
        expect(req.supplies.length, 2);

        expect(req.supplies[0].spkDoseUsage, 60.0);
        expect(req.supplies[0].toJson()['spk_dose_usage'], 60.0);

        expect(req.supplies[1].spkDoseUsage, isNull);
        expect(req.supplies[1].toJson().containsKey('spk_dose_usage'), isFalse);
      },
    );

    test(
      'loadExistingPricing initialises spkDoseUsage falling back to doseUsage',
      () async {
        repository.detailResponse = const Ok(
          PricingDetail(
            id: 'price-spk',
            customerId: 'c-1',
            serviceId: 's-1',
            contractMonths: 12,
            visitFrequency: 1,
            totalVisits: 12,
            markupType: 1,
            markupValue: 0.0,
            discountAmount: 0.0,
            taxPercentage: 0.0,
            supplies: [
              PricingDetailSupply(
                id: 's-1',
                supplyType: 1,
                name: 'Chem With SPK',
                uomCode: 'ML',
                qty: 10.0,
                doseUsage: 2.0,
                doseUnitId: 'u-1',
                applicationVolume: 5.0,
                applicationVolumeUnitId: 'u-2',
                frequency: 1,
                unitCost: 100.0,
                lineTotal: 1000.0,
                spkDoseUsage: 75.0,
                treatmentMethodId: 'tm-1',
              ),
              PricingDetailSupply(
                id: 's-2',
                supplyType: 1,
                name: 'Chem Fallback',
                uomCode: 'ML',
                qty: 10.0,
                doseUsage: 4.0,
                doseUnitId: 'u-1',
                applicationVolume: 5.0,
                applicationVolumeUnitId: 'u-2',
                frequency: 1,
                unitCost: 100.0,
                lineTotal: 1000.0,
                spkDoseUsage: null,
                treatmentMethodId: 'tm-1',
              ),
            ],
            workers: [],
            items: [],
          ),
        );

        await controller.loadExistingPricing('prop-spk');

        expect(controller.supplies.length, 2);
        expect(controller.supplies[0].spkDoseUsage.value, 75.0);
        expect(controller.supplies[1].spkDoseUsage.value, 4.0);
      },
    );
  });
}
