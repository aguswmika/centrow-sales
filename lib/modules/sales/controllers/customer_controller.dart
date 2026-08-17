import 'package:signals/signals.dart';
import '../../../shared/state/ui_state.dart';
import '../../../shared/result/result.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerController {
  final CustomerRepository _repository;

  CustomerController(this._repository);

  final _customersState = signal<UiState<List<Customer>>>(const UiInitial());
  ReadonlySignal<UiState<List<Customer>>> get customersState => _customersState;

  final _searchQuery = signal<String>('');
  ReadonlySignal<String> get searchQuery => _searchQuery;

  final _selectedSegment = signal<String>('all');
  ReadonlySignal<String> get selectedSegment => _selectedSegment;

  final _selectedCustomerId = signal<String>('');
  ReadonlySignal<String> get selectedCustomerId => _selectedCustomerId;

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
    if (_selectedSegment.value != 'all') {
      list = list.where((c) => c.segment == _selectedSegment.value).toList();
    }
    return list;
  });

  late final selectedCustomer = computed(() {
    final list = filteredCustomers.value;
    if (list.isEmpty) return null;
    if (_selectedCustomerId.value.isNotEmpty) {
      final idx = list.indexWhere((c) => c.id == _selectedCustomerId.value);
      if (idx != -1) return list[idx];
    }
    return list.first;
  });

  Future<void> loadCustomers() async {
    _customersState.value = const UiLoading();
    final result = await _repository.getCustomers();
    _customersState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void selectSegment(String segment) {
    _selectedSegment.value = segment;
  }

  void selectCustomer(String id) {
    _selectedCustomerId.value = id;
  }

  void setDetailTab(int tabIndex) {
    _activeDetailTab.value = tabIndex;
  }

  void dispose() {
    _customersState.dispose();
    _searchQuery.dispose();
    _selectedSegment.dispose();
    _selectedCustomerId.dispose();
    _activeDetailTab.dispose();
    filteredCustomers.dispose();
    selectedCustomer.dispose();
  }
}
