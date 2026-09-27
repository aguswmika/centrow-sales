import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/contract_category.dart';

void main() {
  group('ContractCategory', () {
    test('instantiates with properties', () {
      const category = ContractCategory(id: 'cat-1', name: 'Commercial');
      expect(category.id, 'cat-1');
      expect(category.name, 'Commercial');
      expect(
        category.toString(),
        'ContractCategory(id: cat-1, name: Commercial)',
      );
    });
  });
}
