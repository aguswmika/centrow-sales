import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/sales_dashboard.dart';
import 'package:centrow_sales/modules/sales/repositories/sales_dashboard_repository.dart';

class SalesDashboardController {
  final SalesDashboardRepository _repository;

  SalesDashboardController(this._repository);

  final _state = signal<UiState<SalesDashboardSummary>>(const UiInitial());
  ReadonlySignal<UiState<SalesDashboardSummary>> get state => _state;

  Future<void> loadDashboard() async {
    _state.value = const UiLoading();
    final result = await _repository.getDashboardSummary();
    _state.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  Future<void> refresh() async {
    final result = await _repository.getDashboardSummary();
    _state.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  void dispose() {
    _state.dispose();
  }
}
