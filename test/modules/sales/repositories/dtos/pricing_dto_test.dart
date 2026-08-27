import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';

void main() {
  group('Pricing DTOs', () {
    test(
      'CreatePricingRequestDto toJson serializes correctly with snake_case keys',
      () {
        const material = PricingMaterialDto(
          productMappingId: 'pm1',
          name: 'Chemical A',
          uomCode: 'BTL',
          doseUsage: 2.0,
          doseUnitId: 'uom-ml',
          applicationVolume: 10.0,
          applicationVolumeUnitId: 'uom-l',
          frequency: 2,
        );

        const labor = PricingLaborDto(
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
          areaValue: 500.0,
          areaUnitId: 'uom-m2',
          contractMonths: 12,
          visitFrequency: 24,
          markupType: 1,
          markupValue: 20.0,
          discountAmount: 10000.0,
          materials: [material],
          labors: [labor],
          items: [item],
        );

        final json = request.toJson();

        expect(json['customer_id'], 'c1');
        expect(json['service_id'], 's1');
        expect(json['area_value'], 500.0);
        expect(json['area_unit_id'], 'uom-m2');
        expect(json['contract_months'], 12);
        expect(json['visit_frequency'], 24);
        expect(json['markup_type'], 1);
        expect(json['markup_value'], 20.0);
        expect(json['discount_amount'], 10000.0);

        final materialsList = json['materials'] as List<dynamic>;
        expect(materialsList.length, 1);
        expect(materialsList[0], {
          'product_mapping_id': 'pm1',
          'name': 'Chemical A',
          'uom_code': 'BTL',
          'dose_usage': 2.0,
          'dose_unit_id': 'uom-ml',
          'application_volume': 10.0,
          'application_volume_unit_id': 'uom-l',
          'frequency': 2,
        });

        final laborsList = json['labors'] as List<dynamic>;
        expect(laborsList.length, 1);
        expect(laborsList[0], {
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
