import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';
import 'package:centrow_sales/modules/pc/repositories/product_mapping_repository.dart';

class ProductMappingController {
  final ProductMappingRepository _repository;

  ProductMappingController(this._repository);

  final _state = signal<UiState<List<ProductMapping>>>(const UiInitial());
  ReadonlySignal<UiState<List<ProductMapping>>> get state => _state;

  Future<void> loadProductMappings({
    String? treatmentMethodId,
    String? keyword,
  }) async {
    _state.value = const UiLoading();
    final result = await _repository.getProductMappings(
      treatmentMethodId: treatmentMethodId,
      keyword: keyword,
    );
    _state.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  void dispose() => _state.dispose();
}
