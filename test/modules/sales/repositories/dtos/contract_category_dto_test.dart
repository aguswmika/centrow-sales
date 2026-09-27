import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_category_dto.dart';

void main() {
  group('ContractCategoryDto', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'cat-1',
        'name': 'Pest Control',
        'created_at': '2026-01-01',
        'templates': [
          {'id': 'tmpl-1', 'label': 'Template A', 'is_default': true},
        ],
      };

      final dto = ContractCategoryDto.fromJson(json);
      expect(dto.id, 'cat-1');
      expect(dto.name, 'Pest Control');
      expect(dto.templates.length, 1);

      final entity = dto.toEntity();
      expect(entity.id, 'cat-1');
      expect(entity.name, 'Pest Control');
      expect(entity.templates.length, 1);
    });

    test('toEntity works with empty templates', () {
      final json = {'id': 'cat-3', 'name': 'General Service'};

      final dto = ContractCategoryDto.fromJson(json);
      expect(dto.templates, isEmpty);

      final entity = dto.toEntity();
      expect(entity.templates, isEmpty);
    });
  });
}
