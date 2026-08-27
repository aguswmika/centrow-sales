import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class MockPricingRepository implements PricingRepository {
  CreatePricingRequestDto? lastRequest;
  Result<void> response = const Ok(null);

  @override
  Future<Result<void>> savePricing(CreatePricingRequestDto data) async {
    lastRequest = data;
    return response;
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
    test('PricingMaterialRow calculates total correctly', () {
      final row = PricingMaterialRow(
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
        initialUnitCost: 50000.0,
      );

      // qty = 2.0 * 5.0 = 10.0
      expect(row.qty.value, 10.0);
      // total = 2.0 * 5.0 * 3.0 * 50000.0 = 1500000.0
      expect(row.total.value, 1500000.0);

      row.doseUsage.value = 4.0;
      expect(row.qty.value, 20.0);
      expect(row.total.value, 3000000.0);

      row.dispose();
    });

    test('PricingLaborRow calculates total correctly with math.max', () {
      final row = PricingLaborRow(
        id: '2',
        title: 'Technician',
        code: 'LBR-1',
        kind: 4,
        initialVisitFreq: 4.0,
        initialFirstVisitHours: 3.0,
        initialRoutineHours: 2.0,
        initialHourlyRate: 100000.0,
      );

      // total = 3.0 * 100000 + max(0, 4 - 1) * 2.0 * 100000
      // = 300000 + 3 * 200000 = 300000 + 600000 = 900000
      expect(row.total.value, 900000.0);

      row.visitFreq.value = 1.0;
      // total = 3.0 * 100000 + max(0, 1 - 1) * 2.0 * 100000 = 300000 + 0 = 300000
      expect(row.total.value, 300000.0);

      row.visitFreq.value = 0.0;
      // max(0, -1) = 0 => 300000
      expect(row.total.value, 300000.0);

      row.dispose();
    });

    test('PricingItemRow calculates total correctly based on kind', () {
      final transportItem = PricingItemRow(
        id: '3',
        title: 'Transport',
        code: 'TR-1',
        kind: 3,
        initialQty: 2.0,
        initialFreq: 2.0,
        initialUnitCost: 25000.0,
        initialUnitPrice: 50000.0,
      );

      // kind == 3 uses unitCost => 2 * 2 * 25000 = 100000
      expect(transportItem.total.value, 100000.0);
      transportItem.dispose();

      final addonItem = PricingItemRow(
        id: '4',
        title: 'Addon',
        code: 'ADD-1',
        kind: 5,
        initialQty: 2.0,
        initialFreq: 2.0,
        initialUnitCost: 25000.0,
        initialUnitPrice: 50000.0,
      );

      // kind == 5 uses unitPrice => 2 * 2 * 50000 = 200000
      expect(addonItem.total.value, 200000.0);
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

        const laborProduct = Product(
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
        controller.addRow(laborProduct, 4);
        controller.addRow(transportProduct, 3);
        controller.addRow(addonProduct, 5);

        expect(controller.materials.length, 2);
        expect(controller.labors.length, 1);
        expect(controller.items.length, 2);
      },
    );

    test(
      'addMaterialRow creates PricingMaterialRow correctly from ProductMapping',
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

        controller.addMaterialRow(mappingWithDefaultDose);

        expect(controller.materials.length, 1);
        final row1 = controller.materials[0];
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

        controller.addMaterialRow(mappingWithoutDefaultDose);

        expect(controller.materials.length, 2);
        final row2 = controller.materials[1];
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
  });

  group('PricingCalculatorController - Computed Calculations', () {
    test('calculates COGS, markup, discounts, taxes, and grand totals', () {
      controller.materials.add(
        PricingMaterialRow(
          id: 'm1',
          title: 'Chemical',
          code: 'CHM',
          uomCode: 'BTL',
          kind: 1,
          initialDoseUsage: 1.0,
          initialApplicationVolume: 1.0,
          initialFreq: 1.0,
          initialUnitCost: 100000.0,
        ),
      );

      controller.labors.add(
        PricingLaborRow(
          id: 'l1',
          title: 'Tech',
          code: 'LBR',
          kind: 4,
          initialVisitFreq: 1.0,
          initialFirstVisitHours: 2.0,
          initialRoutineHours: 0.0,
          initialHourlyRate: 50000.0,
        ),
      );

      controller.items.add(
        PricingItemRow(
          id: 'i1',
          title: 'Transport',
          code: 'TR',
          kind: 3,
          initialQty: 1.0,
          initialFreq: 1.0,
          initialUnitCost: 50000.0,
          initialUnitPrice: 50000.0,
        ),
      );

      controller.items.add(
        PricingItemRow(
          id: 'i2',
          title: 'Addon',
          code: 'ADD',
          kind: 5,
          initialQty: 1.0,
          initialFreq: 1.0,
          initialUnitCost: 20000.0,
          initialUnitPrice: 40000.0,
        ),
      );

      expect(controller.cogsMaterial.value, 100000.0);
      expect(controller.cogsLabor.value, 100000.0);
      expect(controller.cogsTransport.value, 50000.0);
      expect(controller.addonCost.value, 40000.0);

      // cogsTotal = 100000 + 100000 + 50000 = 250000
      expect(controller.cogsTotal.value, 250000.0);

      // Markup 20%
      controller.markupPercent.value = 20.0;
      // markupAmount = 250000 * 0.20 = 50000
      expect(controller.markupAmount.value, 50000.0);
      // servicePrice = 250000 + 50000 = 300000
      expect(controller.servicePrice.value, 300000.0);

      // Discount 10000
      controller.discountAmount.value = 10000.0;
      // subtotal = 300000 + 40000 - 10000 = 330000
      expect(controller.subtotal.value, 330000.0);

      // taxAmount = 330000 * 0.11 = 36300
      expect(controller.taxAmount.value, 36300.0);

      // grandTotal = 330000 + 36300 = 366300
      expect(controller.grandTotal.value, 366300.0);

      // marginAmount = subtotal - cogsTotal = 330000 - 250000 = 80000
      expect(controller.marginAmount.value, 80000.0);
    });
  });

  group('PricingCalculatorController - submitPricing', () {
    test('submits pricing and updates submitState to UiSuccess', () async {
      controller.materials.add(
        PricingMaterialRow(
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
          initialUnitCost: 50000.0,
        ),
      );

      controller.areaValue.value = 500.0;
      controller.areaUnitId.value = 'uom-m2';
      controller.contractMonths.value = 6;
      controller.visitFrequency.value = 4;
      controller.markupPercent.value = 15.0;

      await controller.submitPricing('cust-1', 'srv-1');

      expect(controller.submitState.value, isA<UiSuccess<void>>());
      expect(repository.lastRequest, isNotNull);
      expect(repository.lastRequest!.customerId, 'cust-1');
      expect(repository.lastRequest!.serviceId, 'srv-1');
      expect(repository.lastRequest!.areaValue, 500.0);
      expect(repository.lastRequest!.areaUnitId, 'uom-m2');
      expect(repository.lastRequest!.contractMonths, 6);
      expect(repository.lastRequest!.visitFrequency, 4);
      expect(repository.lastRequest!.markupType, 1);
      expect(repository.lastRequest!.markupValue, 15.0);
      expect(repository.lastRequest!.materials.length, 1);
      expect(repository.lastRequest!.materials[0].productMappingId, 'pm-1');
      expect(repository.lastRequest!.materials[0].doseUsage, 2.0);
      expect(repository.lastRequest!.materials[0].doseUnitId, 'uom-ml');
      expect(repository.lastRequest!.materials[0].applicationVolume, 1.0);
      expect(
        repository.lastRequest!.materials[0].applicationVolumeUnitId,
        'uom-l',
      );
    });

    test('updates submitState to UiFailure when repository fails', () async {
      repository.response = const Err(ServerFailure('Server Error'));

      await controller.submitPricing('cust-1', 'srv-1');

      expect(controller.submitState.value, isA<UiFailure<void>>());
    });
  });
}
