import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';

void main() {
  group('Pricing DTOs', () {
    test(
      'CreatePricingRequestDto toJson serializes correctly with snake_case keys',
      () {
        const material = PricingMaterialDto(
          supplyType: 1,
          productMappingId: 'pm1',
          name: 'Chemical A',
          uomCode: 'BTL',
          doseUsage: 2.0,
          doseUnitId: 'uom-ml',
          applicationVolume: 10.0,
          applicationVolumeUnitId: 'uom-l',
          frequency: 2,
        );

        const tool = PricingMaterialDto(
          supplyType: 2,
          productId: 'p-tool',
          name: 'Sprayer',
          uomCode: 'UNIT',
          qty: 1.0,
          frequency: 1,
        );

        const worker = PricingWorkerDto(
          positionName: 'Technician',
          firstVisitHours: 2.0,
          routineHours: 1.5,
          hourlyRate: 75000.0,
        );

        const item = PricingItemDto(
          itemType: 1,
          productId: 'p2',
          name: 'Equipment B',
          qty: 1.0,
          frequency: 1,
          unitPrice: 150000.0,
        );

        const request = CreatePricingRequestDto(
          customerId: 'c1',
          serviceId: 's1',
          contractMonths: 12,
          visitFrequency: 24,
          markupType: 1,
          markupValue: 20.0,
          discountAmount: 10000.0,
          taxPercentage: 11.0,
          materials: [material, tool],
          workers: [worker],
          items: [item],
        );

        final json = request.toJson();

        expect(json['customer_id'], 'c1');
        expect(json['service_id'], 's1');
        expect(json['contract_months'], 12);
        expect(json['visit_frequency'], 24);
        expect(json['markup_type'], 1);
        expect(json['markup_value'], 20.0);
        expect(json['discount_amount'], 10000.0);
        expect(json['tax_percentage'], 11.0);
        expect(json.containsKey('area_value'), isFalse);

        final suppliesList = json['supplies'] as List<dynamic>;
        expect(suppliesList.length, 2);
        expect(suppliesList[0], {
          'supply_type': 1,
          'product_mapping_id': 'pm1',
          'name': 'Chemical A',
          'uom_code': 'BTL',
          'dose_usage': 2.0,
          'dose_unit_id': 'uom-ml',
          'application_volume': 10.0,
          'application_volume_unit_id': 'uom-l',
          'frequency': 2,
        });
        expect(suppliesList[1], {
          'supply_type': 2,
          'product_id': 'p-tool',
          'name': 'Sprayer',
          'uom_code': 'UNIT',
          'qty': 1.0,
          'frequency': 1,
        });

        final workersList = json['workers'] as List<dynamic>;
        expect(workersList.length, 1);
        expect(workersList[0], {
          'position_name': 'Technician',
          'first_visit_hours': 2.0,
          'routine_hours': 1.5,
          'hourly_rate': 75000.0,
        });

        final itemsList = json['items'] as List<dynamic>;
        expect(itemsList.length, 1);
        expect(itemsList[0], {
          'item_type': 1,
          'product_id': 'p2',
          'name': 'Equipment B',
          'qty': 1.0,
          'frequency': 1,
          'unit_price': 150000.0,
        });
      },
    );
  });
}
