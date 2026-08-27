import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/product.dart';
import 'package:centrow_sales/modules/sales/repositories/product_repository.dart';

class ProductController {
  final ProductRepository _repository;
  ProductController(this._repository);

  final _state = signal<UiState<List<Product>>>(const UiInitial());
  ReadonlySignal<UiState<List<Product>>> get state => _state;

  Future<void> loadProducts({String? q, int? kind}) async {
    _state.value = const UiLoading();
    final result = await _repository.getProducts(q: q, kind: kind);
    _state.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  void dispose() => _state.dispose();
}
