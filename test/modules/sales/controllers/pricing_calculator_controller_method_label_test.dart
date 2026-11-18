import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'package:centrow_sales/modules/pc/repositories/treatment_method_repository.dart';
import 'package:centrow_sales/modules/sales/controllers/pricing_calculator_controller.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';
import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class _FakePricingRepository implements PricingRepository {
  _FakePricingRepository(this.detail);
  final PricingDetail detail;

  @override
  Future<Result<PricingDetail>> getPricingDetail(String proposalId) async =>
      Ok(detail);

  @override
  Future<Result<void>> savePricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async => const Ok(null);

  @override
  Future<Result<PricingPreview>> previewPricing(
    String proposalId,
    CreatePricingRequestDto data,
  ) async => const Err(UnknownFailure('not used'));
}

class _FakeTreatmentMethodRepository implements TreatmentMethodRepository {
  int calls = 0;

  @override
  Future<Result<List<TreatmentMethod>>> getTreatmentMethods() async {
    calls++;
    return const Ok([
      TreatmentMethod(id: 'tm-1', code: 'CF', name: 'Cold Fog'),
      TreatmentMethod(id: 'tm-2', code: 'SP', name: 'Spraying'),
    ]);
  }
}

PricingDetail _detail({String? id, String? name, String? code}) =>
    PricingDetail(
      id: 'price-1',
      customerId: 'cust-1',
      serviceId: 'srv-1',
      contractMonths: 12,
      visitFrequency: 1,
      totalVisits: 12,
      markupType: 1,
      markupValue: 0,
      discountAmount: 0,
      taxPercentage: 0,
      supplies: [
        PricingDetailSupply(
          id: 's1',
          supplyType: 1,
          productId: 'p1',
          name: 'Chemical',
          uomCode: 'ML',
          qty: 1,
          doseUnitId: '',
          applicationVolumeUnitId: '',
          frequency: 1,
          unitCost: 0,
          lineTotal: 0,
          treatmentMethodId: id,
          treatmentMethodName: name,
          treatmentMethodCode: code,
        ),
      ],
      workers: const [],
      items: const [],
    );

void main() {
  test('id-only supply gets its method name from the method list', () async {
    final methods = _FakeTreatmentMethodRepository();
    final controller = PricingCalculatorController(
      _FakePricingRepository(_detail(id: 'tm-1')),
      null,
      methods,
    );
    addTearDown(controller.dispose);

    await controller.loadExistingPricing('prop-1');

    final row = controller.supplies.single;
    expect(row.treatmentMethodId.value, 'tm-1');
    expect(row.treatmentMethodName.value, 'Cold Fog');
    expect(row.treatmentMethodCode.value, 'CF');
    expect(methods.calls, 1);
  });

  test('supply with a name from the server does not load the list', () async {
    final methods = _FakeTreatmentMethodRepository();
    final controller = PricingCalculatorController(
      _FakePricingRepository(_detail(id: 'tm-1', name: 'Server Name')),
      null,
      methods,
    );
    addTearDown(controller.dispose);

    await controller.loadExistingPricing('prop-1');

    expect(controller.supplies.single.treatmentMethodName.value, 'Server Name');
    expect(methods.calls, 0);
  });

  test('unknown method id keeps the id and no name', () async {
    final controller = PricingCalculatorController(
      _FakePricingRepository(_detail(id: 'tm-unknown')),
      null,
      _FakeTreatmentMethodRepository(),
    );
    addTearDown(controller.dispose);

    await controller.loadExistingPricing('prop-1');

    final row = controller.supplies.single;
    expect(row.treatmentMethodId.value, 'tm-unknown');
    expect(row.treatmentMethodName.value ?? '', isEmpty);
  });

  test('supply without a method id is left untouched', () async {
    final methods = _FakeTreatmentMethodRepository();
    final controller = PricingCalculatorController(
      _FakePricingRepository(_detail()),
      null,
      methods,
    );
    addTearDown(controller.dispose);

    await controller.loadExistingPricing('prop-1');

    expect(controller.supplies.single.treatmentMethodName.value ?? '', isEmpty);
    expect(methods.calls, 0);
  });
}
