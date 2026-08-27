import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/pc/controllers/product_mapping_controller.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/modules/pc/repositories/product_mapping_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/product_mapping_picker_sheet.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class MockProductMappingRepository implements ProductMappingRepository {
  List<ProductMapping> mappings = [
    const ProductMapping(
      id: 'pm-1',
      productId: 'prod-1',
      productCode: 'CHM-01',
      productName: 'Termiticide Alpha',
      pestId: 'pest-1',
      pestName: 'Rayap',
      treatmentMethodId: 'tm-1',
      treatmentMethodCode: 'SPRAY',
      treatmentMethodName: 'Spraying',
      doseMinLimit: 2.0,
      doseMaxLimit: 5.0,
      doseUnitId: 'uom-ml',
      doseUnitCode: 'ML',
      defaultDose: 2.5,
    ),
    const ProductMapping(
      id: 'pm-2',
      productId: 'prod-2',
      productCode: 'CHM-02',
      productName: 'Rodenticide Beta',
      pestId: 'pest-2',
      pestName: 'Tikus',
      treatmentMethodId: 'tm-2',
      treatmentMethodCode: 'BAIT',
      treatmentMethodName: 'Baiting',
      doseMinLimit: 10.0,
      doseMaxLimit: 20.0,
      doseUnitId: 'uom-gr',
      doseUnitCode: 'GR',
    ),
  ];

  Result<List<ProductMapping>>? resultOverride;
  int getProductMappingsCalls = 0;

  @override
  Future<Result<List<ProductMapping>>> getProductMappings({
    String? treatmentMethodId,
    String? keyword,
  }) async {
    getProductMappingsCalls++;
    if (resultOverride != null) {
      return resultOverride!;
    }
    var list = mappings;
    if (treatmentMethodId != null && treatmentMethodId.isNotEmpty) {
      list = list
          .where((m) => m.treatmentMethodId == treatmentMethodId)
          .toList();
    }
    if (keyword != null && keyword.isNotEmpty) {
      final q = keyword.toLowerCase();
      list = list
          .where(
            (m) =>
                m.productName.toLowerCase().contains(q) ||
                m.pestName.toLowerCase().contains(q) ||
                (m.treatmentMethodName ?? '').toLowerCase().contains(q),
          )
          .toList();
    }
    return Ok(list);
  }
}

void main() {
  late MockProductMappingRepository mockRepository;

  setUp(() {
    mockRepository = MockProductMappingRepository();
    if (getIt.isRegistered<ProductMappingRepository>()) {
      getIt.unregister<ProductMappingRepository>();
    }
    if (getIt.isRegistered<ProductMappingController>()) {
      getIt.unregister<ProductMappingController>();
    }
    getIt.registerSingleton<ProductMappingRepository>(mockRepository);
    getIt.registerFactory<ProductMappingController>(
      () => ProductMappingController(getIt<ProductMappingRepository>()),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<ProductMappingRepository>()) {
      getIt.unregister<ProductMappingRepository>();
    }
    if (getIt.isRegistered<ProductMappingController>()) {
      getIt.unregister<ProductMappingController>();
    }
  });

  testWidgets('renders ProductMappingPickerSheet and displays mappings', (
    tester,
  ) async {
    ProductMapping? selectedMapping;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  selectedMapping = await showModalBottomSheet<ProductMapping>(
                    context: context,
                    builder: (_) => const ProductMappingPickerSheet(
                      treatmentMethodId: 'tm-1',
                    ),
                  );
                },
                child: const Text('Open Picker'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Picker'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Mapping Bahan Kimia'), findsOneWidget);
    expect(find.text('Termiticide Alpha'), findsOneWidget);
    expect(find.text('Hama: Rayap'), findsOneWidget);
    expect(find.text('Metode: Spraying'), findsOneWidget);
    expect(find.text('Dosis: 2.5 ML'), findsOneWidget);

    // Tap on the first item
    await tester.tap(find.text('Termiticide Alpha'));
    await tester.pumpAndSettle();

    expect(selectedMapping, isNotNull);
    expect(selectedMapping!.id, 'pm-1');
    expect(selectedMapping!.productName, 'Termiticide Alpha');
  });

  testWidgets('filters product mappings by search query', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProductMappingPickerSheet(treatmentMethodId: '')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Termiticide Alpha'), findsOneWidget);
    expect(find.text('Rodenticide Beta'), findsOneWidget);

    // Search for "Tikus"
    await tester.enterText(find.byType(TextFormField), 'Tikus');
    await tester.pumpAndSettle();

    expect(find.text('Termiticide Alpha'), findsNothing);
    expect(find.text('Rodenticide Beta'), findsOneWidget);

    // Search for non-matching string
    await tester.enterText(find.byType(TextFormField), 'Nyamuk');
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada mapping produk ditemukan'), findsOneWidget);
  });

  testWidgets('renders ErrorView when repository fails', (tester) async {
    mockRepository.resultOverride = const Err(ServerFailure('Gagal memuat'));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductMappingPickerSheet(treatmentMethodId: 'tm-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat'), findsOneWidget);
  });
}
