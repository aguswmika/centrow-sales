import 'package:centrow_sales/modules/sales/repositories/dtos/product_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductDto', () {
    test('fromJson parses selling_price', () {
      final dto = ProductDto.fromJson({'id': '1', 'selling_price': 25000.0});
      expect(dto.toEntity().sellingPrice, 25000.0);
    });

    test('fromJson falls back to legacy cogs', () {
      final entity = ProductDto.fromJson({'id': '1', 'cogs': 12000}).toEntity();
      expect(entity.sellingPrice, 12000.0);
      expect(entity.cogs, 12000.0);
    });

    test('fromJson prefers selling_price over cogs', () {
      final dto = ProductDto.fromJson({
        'id': '1',
        'selling_price': 30000,
        'cogs': 12000,
      });
      expect(dto.toEntity().sellingPrice, 30000.0);
    });

    test('fromJson defaults to zero when neither field is present', () {
      expect(ProductDto.fromJson({'id': '1'}).toEntity().sellingPrice, 0.0);
    });
  });
}
