import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/pc/repositories/dtos/treatment_method_dto.dart';

void main() {
  group('TreatmentMethodDto', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'tm-1',
        'code': 'SPRAY',
        'name': 'Spraying',
        'description': 'Chemical spray',
        'is_active': true,
      };

      final dto = TreatmentMethodDto.fromJson(json);

      expect(dto.id, 'tm-1');
      expect(dto.code, 'SPRAY');
      expect(dto.name, 'Spraying');
      expect(dto.description, 'Chemical spray');
      expect(dto.isActive, true);

      final entity = dto.toEntity();
      expect(entity.id, 'tm-1');
      expect(entity.code, 'SPRAY');
      expect(entity.name, 'Spraying');
      expect(entity.isActive, true);
    });

    test('fromJson parses fallback isActive', () {
      final json = {
        'id': 'tm-2',
        'code': 'BAIT',
        'name': 'Baiting',
        'isActive': true,
      };

      final dto = TreatmentMethodDto.fromJson(json);

      expect(dto.isActive, true);
      expect(dto.toEntity().isActive, true);
    });

    test('fromJson defaults isActive to true when missing', () {
      final json = {'id': 'tm-3', 'code': 'FOG', 'name': 'Fogging'};

      final dto = TreatmentMethodDto.fromJson(json);

      expect(dto.isActive, true);
      expect(dto.toEntity().isActive, true);
    });
  });
}
