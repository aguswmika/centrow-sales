import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';
import 'package:centrow_sales/modules/pc/repositories/treatment_method_repository.dart';

class TreatmentMethodController {
  final TreatmentMethodRepository _repository;

  TreatmentMethodController(this._repository);

  final _state = signal<UiState<List<TreatmentMethod>>>(const UiInitial());
  ReadonlySignal<UiState<List<TreatmentMethod>>> get state => _state;

  Future<void> loadTreatmentMethods() async {
    _state.value = const UiLoading();
    final result = await _repository.getTreatmentMethods();
    _state.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  void dispose() => _state.dispose();
}
