import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/contract_category.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_category_dto.dart';

void main() {
  group('ContractCategoryDto', () {
    test('fromJson parses schedule_cycle as integer', () {
      final json = {
        'id': 'cat-1',
        'name': 'Pest Control Bulanan',
        'created_at': '2026-01-01',
        'schedule_cycle': 2,
        'templates': [
          {'id': 'tmpl-1', 'label': 'Template A', 'is_default': true},
        ],
      };

      final dto = ContractCategoryDto.fromJson(json);
      expect(dto.id, 'cat-1');
      expect(dto.name, 'Pest Control Bulanan');
      expect(dto.scheduleCycle, 2);
      expect(dto.templates.length, 1);

      final entity = dto.toEntity();
      expect(entity.id, 'cat-1');
      expect(entity.name, 'Pest Control Bulanan');
      expect(entity.scheduleCycle, ContractScheduleCycle.monthly);
      expect(entity.templates.length, 1);
    });

    test('fromJson parses schedule_cycle as string and maps to yearly', () {
      final json = {
        'id': 'cat-2',
        'name': 'Termite Control Tahunan',
        'schedule_cycle': '1',
      };

      final dto = ContractCategoryDto.fromJson(json);
      expect(dto.scheduleCycle, 1);

      final entity = dto.toEntity();
      expect(entity.scheduleCycle, ContractScheduleCycle.yearly);
    });

    test(
      'toEntity defaults scheduleCycle to yearly when schedule_cycle is missing or null',
      () {
        final json = {'id': 'cat-3', 'name': 'General Service'};

        final dto = ContractCategoryDto.fromJson(json);
        expect(dto.scheduleCycle, isNull);

        final entity = dto.toEntity();
        expect(entity.scheduleCycle, ContractScheduleCycle.yearly);
      },
    );

    test(
      'toEntity defaults scheduleCycle to yearly when schedule_cycle has unknown value',
      () {
        const dto = ContractCategoryDto(
          id: 'cat-4',
          name: 'Special Service',
          scheduleCycle: 99,
        );

        final entity = dto.toEntity();
        expect(entity.scheduleCycle, ContractScheduleCycle.yearly);
      },
    );
  });
}
