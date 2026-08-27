import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/pc/repositories/dtos/product_mapping_dto.dart';

void main() {
  group('ProductMappingDto', () {
    test('fromJson correctly parses flat snake_case JSON format', () {
      final json = {
        'id': 'pm-101',
        'product_id': 'prod-001',
        'product_code': 'PRD-001',
        'product_name': 'Permethrin 500EC',
        'pest_id': 'pest-001',
        'pest_code': 'PST-NYM',
        'pest_name': 'Nyamuk Aedes',
        'treatment_method_id': 'tm-001',
        'treatment_method_code': 'FOGGING',
        'treatment_method_name': 'Thermal Fogging',
        'dose_min_limit': 10.0,
        'dose_max_limit': 20.0,
        'dose_unit_id': 'unit-ml',
        'dose_unit_code': 'ml/L',
        'dose_unit_name': 'Mililiter per Liter',
        'default_dose': 15.0,
        'notes': 'Larutkan dengan solar atau white oil',
        'is_active': true,
        'unit_price': 85000,
      };

      final dto = ProductMappingDto.fromJson(json);

      expect(dto.id, 'pm-101');
      expect(dto.productId, 'prod-001');
      expect(dto.productCode, 'PRD-001');
      expect(dto.productName, 'Permethrin 500EC');
      expect(dto.pestId, 'pest-001');
      expect(dto.pestCode, 'PST-NYM');
      expect(dto.pestName, 'Nyamuk Aedes');
      expect(dto.treatmentMethodId, 'tm-001');
      expect(dto.treatmentMethodCode, 'FOGGING');
      expect(dto.treatmentMethodName, 'Thermal Fogging');
      expect(dto.doseMinLimit, 10.0);
      expect(dto.doseMaxLimit, 20.0);
      expect(dto.doseUnitId, 'unit-ml');
      expect(dto.doseUnitCode, 'ml/L');
      expect(dto.doseUnitName, 'Mililiter per Liter');
      expect(dto.defaultDose, 15.0);
      expect(dto.notes, 'Larutkan dengan solar atau white oil');
      expect(dto.isActive, true);
      expect(dto.unitPrice, 85000.0);

      final entity = dto.toEntity();
      expect(entity.id, dto.id);
      expect(entity.productId, dto.productId);
      expect(entity.productName, dto.productName);
      expect(entity.pestId, dto.pestId);
      expect(entity.pestName, dto.pestName);
      expect(entity.treatmentMethodId, dto.treatmentMethodId);
      expect(entity.treatmentMethodCode, dto.treatmentMethodCode);
      expect(entity.treatmentMethodName, dto.treatmentMethodName);
      expect(entity.doseMinLimit, dto.doseMinLimit);
      expect(entity.doseMaxLimit, dto.doseMaxLimit);
      expect(entity.doseUnitId, dto.doseUnitId);
      expect(entity.doseUnitCode, dto.doseUnitCode);
      expect(entity.doseUnitName, dto.doseUnitName);
      expect(entity.defaultDose, dto.defaultDose);
      expect(entity.notes, dto.notes);
      expect(entity.isActive, dto.isActive);
      expect(entity.unitPrice, dto.unitPrice);
    });

    test('fromJson correctly parses nested object JSON format', () {
      final json = {
        'id': 'pm-102',
        'product': {
          'id': 'prod-002',
          'code': 'PRD-002',
          'name': 'Cypermethrin 100EC',
        },
        'pest': {'id': 'pest-002', 'code': 'PST-KEC', 'name': 'Kecoak Jerman'},
        'treatment_method': {
          'id': 'tm-002',
          'code': 'SPRAYING',
          'name': 'Residual Spraying',
        },
        'dose_min_limit': 5.0,
        'dose_max_limit': 10.0,
        'dose_unit': {
          'id': 'unit-ml',
          'code': 'ml/L',
          'name': 'Mililiter per Liter',
        },
        'default_dose': 8.0,
        'is_active': true,
        'unit_price': 50000,
      };

      final dto = ProductMappingDto.fromJson(json);

      expect(dto.id, 'pm-102');
      expect(dto.productId, 'prod-002');
      expect(dto.productCode, 'PRD-002');
      expect(dto.productName, 'Cypermethrin 100EC');
      expect(dto.pestId, 'pest-002');
      expect(dto.pestCode, 'PST-KEC');
      expect(dto.pestName, 'Kecoak Jerman');
      expect(dto.treatmentMethodId, 'tm-002');
      expect(dto.treatmentMethodCode, 'SPRAYING');
      expect(dto.treatmentMethodName, 'Residual Spraying');
      expect(dto.doseMinLimit, 5.0);
      expect(dto.doseMaxLimit, 10.0);
      expect(dto.doseUnitId, 'unit-ml');
      expect(dto.doseUnitCode, 'ml/L');
      expect(dto.doseUnitName, 'Mililiter per Liter');
      expect(dto.defaultDose, 8.0);
      expect(dto.unitPrice, 50000.0);
    });

    test('fromJson handles nulls and defaults gracefully', () {
      final json = <String, dynamic>{};
      final dto = ProductMappingDto.fromJson(json);

      expect(dto.id, '');
      expect(dto.productId, '');
      expect(dto.productName, '');
      expect(dto.pestId, '');
      expect(dto.pestName, '');
      expect(dto.treatmentMethodId, '');
      expect(dto.treatmentMethodCode, '');
      expect(dto.doseMinLimit, 0.0);
      expect(dto.doseMaxLimit, 0.0);
      expect(dto.doseUnitId, '');
      expect(dto.doseUnitCode, '');
      expect(dto.isActive, true);
      expect(dto.unitPrice, 0.0);
      expect(dto.defaultDose, isNull);
      expect(dto.notes, isNull);
    });
  });
}
