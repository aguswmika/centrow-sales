import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/pc/controllers/product_mapping_controller.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/modules/pc/repositories/product_mapping_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class FakeProductMappingRepository implements ProductMappingRepository {
  List<ProductMapping> mappings = [];
  bool shouldFail = false;
  String? lastTreatmentMethodId;
  String? lastKeyword;

  @override
  Future<Result<List<ProductMapping>>> getProductMappings({
    String? treatmentMethodId,
    String? keyword,
  }) async {
    lastTreatmentMethodId = treatmentMethodId;
    lastKeyword = keyword;
    if (shouldFail) {
      return const Err(ServerFailure('Gagal memuat mapping produk'));
    }
    return Ok(mappings);
  }
}

void main() {
  group('ProductMappingController', () {
    late FakeProductMappingRepository repository;
    late ProductMappingController controller;

    setUp(() {
      repository = FakeProductMappingRepository();
      controller = ProductMappingController(repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is UiInitial', () {
      expect(controller.state.value, isA<UiInitial<List<ProductMapping>>>());
    });

    test(
      'loadProductMappings transitions to UiLoading then UiSuccess',
      () async {
        const mapping = ProductMapping(
          id: 'pm-1',
          productId: 'prod-1',
          productName: 'Chemical X',
          pestId: 'pest-1',
          pestName: 'Pest A',
          treatmentMethodId: 'tm-1',
          treatmentMethodCode: 'SPRAY',
          doseMinLimit: 1.0,
          doseMaxLimit: 5.0,
          doseUnitId: 'du-1',
          doseUnitCode: 'ML',
        );
        repository.mappings = [mapping];

        final future = controller.loadProductMappings(
          treatmentMethodId: 'tm-1',
          keyword: 'Chemical',
        );
        expect(controller.state.value, isA<UiLoading<List<ProductMapping>>>());

        await future;

        expect(controller.state.value, isA<UiSuccess<List<ProductMapping>>>());
        final state = controller.state.value as UiSuccess<List<ProductMapping>>;
        expect(state.data.length, 1);
        expect(state.data.first.id, 'pm-1');
        expect(repository.lastTreatmentMethodId, 'tm-1');
        expect(repository.lastKeyword, 'Chemical');
      },
    );

    test(
      'loadProductMappings transitions to UiLoading then UiFailure on error',
      () async {
        repository.shouldFail = true;

        final future = controller.loadProductMappings();
        expect(controller.state.value, isA<UiLoading<List<ProductMapping>>>());

        await future;

        expect(controller.state.value, isA<UiFailure<List<ProductMapping>>>());
        final state = controller.state.value as UiFailure<List<ProductMapping>>;
        expect(state.failure.message, 'Gagal memuat mapping produk');
      },
    );
  });
}
