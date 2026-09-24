import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/contract_category.dart';

void main() {
  group('ContractScheduleCycle', () {
    test('values and properties are correctly defined', () {
      expect(ContractScheduleCycle.values, [
        ContractScheduleCycle.yearly,
        ContractScheduleCycle.monthly,
      ]);

      expect(ContractScheduleCycle.yearly.id, 1);
      expect(ContractScheduleCycle.yearly.displayName, 'Tahunan');
      expect(ContractScheduleCycle.yearly.unitPeriod, 'tahun');

      expect(ContractScheduleCycle.monthly.id, 2);
      expect(ContractScheduleCycle.monthly.displayName, 'Bulanan');
      expect(ContractScheduleCycle.monthly.unitPeriod, 'bulan');
    });

    test('boolean flags return correct values', () {
      expect(ContractScheduleCycle.yearly.isYearly, isTrue);
      expect(ContractScheduleCycle.yearly.isMonthly, isFalse);

      expect(ContractScheduleCycle.monthly.isMonthly, isTrue);
      expect(ContractScheduleCycle.monthly.isYearly, isFalse);
    });

    group('fromDynamic', () {
      test('returns null for null or invalid inputs', () {
        expect(ContractScheduleCycle.fromDynamic(null), isNull);
        expect(ContractScheduleCycle.fromDynamic(0), isNull);
        expect(ContractScheduleCycle.fromDynamic(3), isNull);
        expect(ContractScheduleCycle.fromDynamic(''), isNull);
        expect(ContractScheduleCycle.fromDynamic('random'), isNull);
        expect(ContractScheduleCycle.fromDynamic(true), isNull);
      });

      test('parses numbers correctly', () {
        expect(
          ContractScheduleCycle.fromDynamic(1),
          ContractScheduleCycle.yearly,
        );
        expect(
          ContractScheduleCycle.fromDynamic(2),
          ContractScheduleCycle.monthly,
        );
        expect(
          ContractScheduleCycle.fromDynamic(1.0),
          ContractScheduleCycle.yearly,
        );
        expect(
          ContractScheduleCycle.fromDynamic(2.0),
          ContractScheduleCycle.monthly,
        );
      });

      test('parses numeric strings correctly', () {
        expect(
          ContractScheduleCycle.fromDynamic('1'),
          ContractScheduleCycle.yearly,
        );
        expect(
          ContractScheduleCycle.fromDynamic('2'),
          ContractScheduleCycle.monthly,
        );
        expect(
          ContractScheduleCycle.fromDynamic(' 1 '),
          ContractScheduleCycle.yearly,
        );
        expect(
          ContractScheduleCycle.fromDynamic(' 2 '),
          ContractScheduleCycle.monthly,
        );
      });

      test('parses name and locale strings case-insensitively', () {
        expect(
          ContractScheduleCycle.fromDynamic('yearly'),
          ContractScheduleCycle.yearly,
        );
        expect(
          ContractScheduleCycle.fromDynamic('YEARLY'),
          ContractScheduleCycle.yearly,
        );
        expect(
          ContractScheduleCycle.fromDynamic('tahunan'),
          ContractScheduleCycle.yearly,
        );
        expect(
          ContractScheduleCycle.fromDynamic(' Tahunan '),
          ContractScheduleCycle.yearly,
        );

        expect(
          ContractScheduleCycle.fromDynamic('monthly'),
          ContractScheduleCycle.monthly,
        );
        expect(
          ContractScheduleCycle.fromDynamic('MONTHLY'),
          ContractScheduleCycle.monthly,
        );
        expect(
          ContractScheduleCycle.fromDynamic('bulanan'),
          ContractScheduleCycle.monthly,
        );
        expect(
          ContractScheduleCycle.fromDynamic(' Bulanan '),
          ContractScheduleCycle.monthly,
        );
      });
    });
  });

  group('ContractCategory', () {
    test('defaults scheduleCycle to yearly', () {
      const category = ContractCategory(id: 'cat-1', name: 'Commercial');
      expect(category.scheduleCycle, ContractScheduleCycle.yearly);
      expect(
        category.toString(),
        contains('scheduleCycle: ContractScheduleCycle.yearly'),
      );
    });

    test('accepts custom scheduleCycle', () {
      const category = ContractCategory(
        id: 'cat-2',
        name: 'Residential',
        scheduleCycle: ContractScheduleCycle.monthly,
      );
      expect(category.scheduleCycle, ContractScheduleCycle.monthly);
    });
  });
}
