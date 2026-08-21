import 'dart:async';
import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';

class CustomerController {
  final CustomerRepository _repository;

  CustomerController(this._repository);
  
  bool _isDisposed = false;

  final _segmentsState = signal<UiState<List<Segment>>>(const UiInitial());
  ReadonlySignal<UiState<List<Segment>>> get segmentsState => _segmentsState;

  final _customersState = signal<UiState<List<Customer>>>(const UiInitial());
  ReadonlySignal<UiState<List<Customer>>> get customersState => _customersState;

  final _customerDetailState = signal<UiState<Customer>>(const UiInitial());
  ReadonlySignal<UiState<Customer>> get customerDetailState =>
      _customerDetailState;

  final _selectedCustomerId = signal<String>('');
  ReadonlySignal<String> get selectedCustomerId => _selectedCustomerId;

  final _searchQuery = signal<String>('');
  ReadonlySignal<String> get searchQuery => _searchQuery;

  final _selectedSegment = signal<String>('all');
  ReadonlySignal<String> get selectedSegment => _selectedSegment;

  final _selectedStatus = signal<String>('all');
  ReadonlySignal<String> get selectedStatus => _selectedStatus;

  final _activeDetailTab = signal<int>(0);
  ReadonlySignal<int> get activeDetailTab => _activeDetailTab;

  late final filteredCustomers = computed(() {
    final state = _customersState.value;
    if (state is! UiSuccess<List<Customer>>) return <Customer>[];

    var list = state.data;
    final q = _searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.name.toLowerCase().contains(q) ||
                c.code.toLowerCase().contains(q) ||
                c.regency.toLowerCase().contains(q),
          )
          .toList();
    }
    if (_selectedSegment.value != 'all' && _selectedSegment.value.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.segmentId == _selectedSegment.value ||
                c.segment.toLowerCase() ==
                    _selectedSegment.value.toLowerCase(),
          )
          .toList();
    }
    if (_selectedStatus.value != 'all' && _selectedStatus.value.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.status.toLowerCase() ==
                _selectedStatus.value.toLowerCase(),
          )
          .toList();
    }
    return list;
  });

  late final selectedCustomer = computed<Customer?>(() {
    final detail = _customerDetailState.value.dataOrNull;
    if (detail != null &&
        (_selectedCustomerId.value.isEmpty ||
            detail.id == _selectedCustomerId.value)) {
      return detail;
    }
    final list = filteredCustomers.value;
    if (list.isEmpty) return null;
    if (_selectedCustomerId.value.isNotEmpty) {
      final idx = list.indexWhere((c) => c.id == _selectedCustomerId.value);
      if (idx != -1) return list[idx];
    }
    return null;
  });

  Future<void> loadSegments() async {
    _segmentsState.value = const UiLoading();
    final result = await _repository.getSegments();
    if (_isDisposed) return;
    _segmentsState.value = switch (result) {
      Ok(:final value) => UiSuccess<List<Segment>>(value),
      Err(:final failure) => UiFailure<List<Segment>>(failure),
    };
  }

  Future<void> loadCustomers({bool isRefresh = false}) async {
    unawaited(loadSegments());
    if (!isRefresh && _customersState.value is! UiSuccess) {
      _customersState.value = const UiLoading();
    }
    final result = await _repository.getCustomers(
      query: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
      segmentId:
          _selectedSegment.value != 'all' ? _selectedSegment.value : null,
      status: _selectedStatus.value != 'all' ? _selectedStatus.value : null,
    );
    if (_isDisposed) return;
    _customersState.value = switch (result) {
      Ok(:final value) => UiSuccess<List<Customer>>(value),
      Err(:final failure) => UiFailure<List<Customer>>(failure),
    };

    final state = _customersState.value;
    if (state is UiSuccess<List<Customer>> && state.data.isNotEmpty) {
      final targetId = _selectedCustomerId.value;
      if (targetId.isNotEmpty && !state.data.any((c) => c.id == targetId)) {
        await selectCustomer('');
      }
    }
  }

  Future<void> selectCustomer(String id) async {
    _selectedCustomerId.value = id;
    if (id.isEmpty) {
      _customerDetailState.value = const UiInitial();
      return;
    }
    _customerDetailState.value = const UiLoading();
    final result = await _repository.getCustomerById(id);
    if (_isDisposed) return;
    if (_selectedCustomerId.value == id) {
      _customerDetailState.value = switch (result) {
        Ok(:final value) => UiSuccess<Customer>(value),
        Err(:final failure) => UiFailure<Customer>(failure),
      };
    }
  }

  Future<void> loadCustomerDetail(String id) async {
    await selectCustomer(id);
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void selectSegment(String segment) {
    if (_selectedSegment.value == segment) return;
    _selectedSegment.value = segment;
    unawaited(loadCustomers(isRefresh: true));
  }

  void selectStatus(String status) {
    _selectedStatus.value = status;
  }

  void setDetailTab(int tabIndex) {
    _activeDetailTab.value = tabIndex;
  }

  void dispose() {
    _isDisposed = true;
    _segmentsState.dispose();
    _customersState.dispose();
    _customerDetailState.dispose();
    _selectedCustomerId.dispose();
    _searchQuery.dispose();
    _selectedSegment.dispose();
    _selectedStatus.dispose();
    _activeDetailTab.dispose();
    filteredCustomers.dispose();
    selectedCustomer.dispose();
  }
}
