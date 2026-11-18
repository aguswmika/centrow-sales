import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/product_controller.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/modules/sales/repositories/product_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/product_picker_sheet.dart';
import 'package:centrow_sales/shared/result/result.dart';

class MockProductRepository implements ProductRepository {
  @override
  Future<Result<List<Product>>> getProducts({String? q, int? kind}) async {
    return const Ok(<Product>[]);
  }
}

void main() {
  setUp(() {
    if (getIt.isRegistered<ProductRepository>()) {
      getIt.unregister<ProductRepository>();
    }
    if (getIt.isRegistered<ProductController>()) {
      getIt.unregister<ProductController>();
    }
    getIt.registerSingleton<ProductRepository>(MockProductRepository());
    getIt.registerFactory<ProductController>(
      () => ProductController(getIt<ProductRepository>()),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<ProductRepository>()) {
      getIt.unregister<ProductRepository>();
    }
    if (getIt.isRegistered<ProductController>()) {
      getIt.unregister<ProductController>();
    }
  });

  final cases = <int, String>{
    3: 'Pilih Bahan Bakar',
    5: 'Pilih Add On',
    6: 'Pilih Add On (Paket)',
  };

  for (final entry in cases.entries) {
    testWidgets('kind ${entry.key} shows title "${entry.value}"', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProductPickerSheet(kind: entry.key)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(entry.value), findsOneWidget);
    });
  }
}
