import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/pc/repositories/dtos/treatment_method_dto.dart';

void main() {
  group('TreatmentMethodDto', () {
    test('fromJson parses snake_case is_required', () {
      final json = {
        'id': 'tm-1',
        'code': 'SPRAY',
        'name': 'Spraying',
        'description': 'Chemical spray',
        'is_required': true,
        'is_active': true,
      };

      final dto = TreatmentMethodDto.fromJson(json);

      expect(dto.id, 'tm-1');
      expect(dto.code, 'SPRAY');
      expect(dto.name, 'Spraying');
      expect(dto.description, 'Chemical spray');
      expect(dto.isRequired, true);
      expect(dto.isActive, true);

      final entity = dto.toEntity();
      expect(entity.isRequired, true);
    });

    test('fromJson parses camelCase isRequired fallback', () {
      final json = {
        'id': 'tm-2',
        'code': 'BAIT',
        'name': 'Baiting',
        'isRequired': true,
        'isActive': true,
      };

      final dto = TreatmentMethodDto.fromJson(json);

      expect(dto.isRequired, true);
      expect(dto.isActive, true);
      expect(dto.toEntity().isRequired, true);
    });

    test('fromJson defaults isRequired to false when missing', () {
      final json = {'id': 'tm-3', 'code': 'FOG', 'name': 'Fogging'};

      final dto = TreatmentMethodDto.fromJson(json);

      expect(dto.isRequired, false);
      expect(dto.toEntity().isRequired, false);
    });
  });
}
