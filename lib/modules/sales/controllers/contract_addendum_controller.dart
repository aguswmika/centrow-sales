import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_addendum_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_addendum_dto.dart';

class ContractAddendumController {
  final ContractAddendumRepository _repository;

  ContractAddendumController(this._repository);

  bool _isDisposed = false;

  final _addendumsState = signal<UiState<List<ContractAddendum>>>(
    const UiInitial(),
  );
  ReadonlySignal<UiState<List<ContractAddendum>>> get addendumsState =>
      _addendumsState;

  final _createState = signal<UiState<ContractAddendum>>(const UiInitial());
  ReadonlySignal<UiState<ContractAddendum>> get createState => _createState;

  void resetCreateState() {
    _createState.value = const UiInitial();
  }

  Future<void> loadAddendums(String contractId) async {
    _addendumsState.value = const UiLoading();
    final result = await _repository.getAddendums(contractId);
    if (_isDisposed) return;
    _addendumsState.value = switch (result) {
      Ok(:final value) => UiSuccess<List<ContractAddendum>>(value),
      Err(:final failure) => UiFailure<List<ContractAddendum>>(failure),
    };
  }

  Future<Result<ContractAddendum>> createAddendum(
    String contractId,
    CreateContractAddendumRequestDto request,
  ) async {
    _createState.value = const UiLoading();
    final result = await _repository.createAddendum(contractId, request);
    if (_isDisposed) return result;
    _createState.value = switch (result) {
      Ok(:final value) => UiSuccess<ContractAddendum>(value),
      Err(:final failure) => UiFailure<ContractAddendum>(failure),
    };
    return result;
  }

  void dispose() {
    _isDisposed = true;
    _addendumsState.dispose();
    _createState.dispose();
  }
}
