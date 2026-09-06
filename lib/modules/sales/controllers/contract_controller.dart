import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_repository.dart';

class ContractController {
  final ContractRepository _repository;
  ContractController(this._repository);

  bool _isDisposed = false;

  final _contractsState = signal<UiState<List<Contract>>>(const UiInitial());
  ReadonlySignal<UiState<List<Contract>>> get contractsState => _contractsState;

  final _contractDetailState = signal<UiState<Contract>>(const UiInitial());
  ReadonlySignal<UiState<Contract>> get contractDetailState =>
      _contractDetailState;

  final _actionState = signal<UiState<ContractStatusResult>>(const UiInitial());
  ReadonlySignal<UiState<ContractStatusResult>> get actionState => _actionState;

  void resetActionState() => _actionState.value = const UiInitial();

  final _selectedContractId = signal<String>('');
  ReadonlySignal<String> get selectedContractId => _selectedContractId;

  final _searchQuery = signal<String>('');
  ReadonlySignal<String> get searchQuery => _searchQuery;

  final _selectedStatus = signal<int?>(null);
  ReadonlySignal<int?> get selectedStatus => _selectedStatus;

  late final filteredContracts = computed<List<Contract>>(() {
    final state = _contractsState.value;
    if (state is! UiSuccess<List<Contract>>) return <Contract>[];

    var list = state.data;
    final q = _searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.code.toLowerCase().contains(q) ||
                c.customerName.toLowerCase().contains(q) ||
                c.serviceName.toLowerCase().contains(q) ||
                c.categoryName.toLowerCase().contains(q),
          )
          .toList();
    }
    final status = _selectedStatus.value;
    if (status != null) {
      list = list.where((c) {
        return switch (status) {
          1 => c.status == ContractStatus.draft,
          2 => c.status == ContractStatus.active,
          3 => c.status == ContractStatus.suspended,
          4 => c.status == ContractStatus.expired,
          5 => c.status == ContractStatus.terminated,
          6 => c.status == ContractStatus.cancelled,
          _ => true,
        };
      }).toList();
    }
    return list;
  });

  late final selectedContract = computed<Contract?>(() {
    final id = _selectedContractId.value;
    if (id.isEmpty) return null;
    final detail = _contractDetailState.value.dataOrNull;
    if (detail != null && detail.id == id) return detail;
    final list = _contractsState.value.dataOrNull ?? [];
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  });

  // ── Intents ─────────────────────────────────────────────────────────────

  Future<void> loadContracts({bool isRefresh = false}) async {
    if (!isRefresh && _contractsState.value is! UiSuccess) {
      _contractsState.value = const UiLoading();
    }
    final result = await _repository.getContracts(
      query: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
      status: _selectedStatus.value,
    );
    if (_isDisposed) return;
    _contractsState.value = switch (result) {
      Ok(:final value) => UiSuccess<List<Contract>>(value),
      Err(:final failure) => UiFailure<List<Contract>>(failure),
    };
  }

  Future<void> selectContract(String id) async {
    _selectedContractId.value = id;
    if (id.isEmpty) {
      _contractDetailState.value = const UiInitial();
      return;
    }
    _contractDetailState.value = const UiLoading();
    final result = await _repository.getContractById(id);
    if (_isDisposed) return;
    if (_selectedContractId.value == id) {
      _contractDetailState.value = switch (result) {
        Ok(:final value) => UiSuccess<Contract>(value),
        Err(:final failure) => UiFailure<Contract>(failure),
      };
    }
  }

  Future<Result<Contract>> createContractFromProposal(
    String proposalId,
    CreateContractFromProposalInput input,
  ) async {
    _actionState.value = const UiLoading();
    final result = await _repository.createContractFromProposal(
      proposalId,
      input,
    );
    if (_isDisposed) return result;
    _actionState.value = const UiInitial();
    if (result is Ok<Contract>) {
      await loadContracts(isRefresh: true);
    }
    return result;
  }

  Future<Result<ContractStatusResult>> activateContract(String id) =>
      _handleTransition(() => _repository.activateContract(id));

  Future<Result<ContractStatusResult>> suspendContract(String id) =>
      _handleTransition(() => _repository.suspendContract(id));

  Future<Result<ContractStatusResult>> terminateContract(
    String id,
    String reason,
  ) => _handleTransition(() => _repository.terminateContract(id, reason));

  Future<Result<ContractStatusResult>> cancelContract(String id) =>
      _handleTransition(() => _repository.cancelContract(id));

  Future<Result<ContractStatusResult>> _handleTransition(
    Future<Result<ContractStatusResult>> Function() action,
  ) async {
    _actionState.value = const UiLoading();
    final result = await action();
    if (_isDisposed) return result;
    _actionState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
    if (result is Ok<ContractStatusResult>) {
      _applyStatusResult(result.value);
      await loadContracts(isRefresh: true);
    }
    return result;
  }

  void _applyStatusResult(ContractStatusResult res) {
    final current = _contractDetailState.value.dataOrNull;
    if (current != null && current.id == res.id) {
      _contractDetailState.value = UiSuccess(
        current.copyWith(status: res.status),
      );
    }
  }

  void setSearchQuery(String q) => _searchQuery.value = q;
  void selectStatus(int? s) => _selectedStatus.value = s;

  void dispose() {
    _isDisposed = true;
    _contractsState.dispose();
    _contractDetailState.dispose();
    _actionState.dispose();
    _selectedContractId.dispose();
    _searchQuery.dispose();
    _selectedStatus.dispose();
    filteredContracts.dispose();
    selectedContract.dispose();
  }
}
