import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_detail_dto.dart';

void main() {
  group('PricingDetailTreatmentQuotaDto', () {
    test('fromJson parses correctly from snake_case JSON', () {
      final json = {
        'treatment_method_id': 'tm-10',
        'quota': 12,
        'treatment_method_name': 'Misting',
        'treatment_method_code': 'MST',
        'is_required': true,
      };

      final dto = PricingDetailTreatmentQuotaDto.fromJson(json);
      expect(dto.treatmentMethodId, 'tm-10');
      expect(dto.quota, 12);
      expect(dto.treatmentMethodName, 'Misting');
      expect(dto.treatmentMethodCode, 'MST');
      expect(dto.isRequired, isTrue);

      final entity = dto.toEntity();
      expect(entity.treatmentMethodId, 'tm-10');
      expect(entity.quota, 12);
      expect(entity.treatmentMethodName, 'Misting');
      expect(entity.treatmentMethodCode, 'MST');
      expect(entity.isRequired, isTrue);
    });

    test('fromJson handles camelCase and missing fields gracefully', () {
      final json = {'treatmentMethodId': 'tm-20', 'quota': 4};

      final dto = PricingDetailTreatmentQuotaDto.fromJson(json);
      expect(dto.treatmentMethodId, 'tm-20');
      expect(dto.quota, 4);
      expect(dto.treatmentMethodName, '');
      expect(dto.treatmentMethodCode, '');
      expect(dto.isRequired, isFalse);
    });
  });

  group('PricingDetailDto with treatment_quotas', () {
    test('fromJson and toEntity include treatment quotas', () {
      final json = {
        'id': 'p-1',
        'customer_id': 'c-1',
        'service_id': 's-1',
        'contract_months': 12,
        'visit_frequency': 2,
        'markup_type': 1,
        'markup_value': 10.0,
        'discount_amount': 0.0,
        'tax_percentage': 11.0,
        'supplies': <Map<String, dynamic>>[],
        'workers': <Map<String, dynamic>>[],
        'items': <Map<String, dynamic>>[],
        'treatment_quotas': [
          {
            'treatment_method_id': 'tm-1',
            'quota': 6,
            'treatment_method_name': 'Baiting',
            'treatment_method_code': 'BAIT',
            'is_required': false,
          },
        ],
      };

      final dto = PricingDetailDto.fromJson(json);
      expect(dto.treatmentQuotas.length, 1);
      expect(dto.treatmentQuotas.first.treatmentMethodId, 'tm-1');
      expect(dto.treatmentQuotas.first.quota, 6);

      final entity = dto.toEntity();
      expect(entity.treatmentQuotas.length, 1);
      expect(entity.treatmentQuotas.first.treatmentMethodId, 'tm-1');
      expect(entity.treatmentQuotas.first.quota, 6);
      expect(entity.treatmentQuotas.first.treatmentMethodName, 'Baiting');
      expect(entity.treatmentQuotas.first.treatmentMethodCode, 'BAIT');
      expect(entity.treatmentQuotas.first.isRequired, isFalse);
    });
  });
}
