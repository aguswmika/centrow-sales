import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/site_risk.dart';
import 'package:centrow_sales/modules/sales/repositories/site_risk_repository.dart';

class SiteRiskController {
  final SiteRiskRepository _repository;

  SiteRiskController(this._repository);

  bool _isDisposed = false;

  final _masterRisks = signal<UiState<List<SiteRiskMaster>>>(const UiInitial());
  ReadonlySignal<UiState<List<SiteRiskMaster>>> get masterRisks => _masterRisks;

  final _addressRisks = signal<UiState<List<CustomerAddressRisk>>>(
    const UiInitial(),
  );
  ReadonlySignal<UiState<List<CustomerAddressRisk>>> get addressRisks =>
      _addressRisks;

  final _saveState = signal<UiState<List<CustomerAddressRisk>>>(
    const UiInitial(),
  );
  ReadonlySignal<UiState<List<CustomerAddressRisk>>> get saveState =>
      _saveState;

  final _selectedSiteRiskIds = signal<Set<String>>({});
  ReadonlySignal<Set<String>> get selectedSiteRiskIds => _selectedSiteRiskIds;

  final _customRisks = signal<List<String>>([]);
  ReadonlySignal<List<String>> get customRisks => _customRisks;

  Future<void> loadMasterRisks() async {
    _masterRisks.value = const UiLoading();
    final result = await _repository.getSiteRiskMasters();
    if (_isDisposed) return;
    _masterRisks.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
  }

  Future<void> loadAddressRisks(String customerId, String addressId) async {
    _addressRisks.value = const UiLoading();
    final result = await _repository.getAddressRisks(
      customerId: customerId,
      addressId: addressId,
    );
    if (_isDisposed) return;
    switch (result) {
      case Ok(:final value):
        batch(() {
          _addressRisks.value = UiSuccess(value);
          _selectedSiteRiskIds.value = value
              .where((e) => e.siteRiskId != null)
              .map((e) => e.siteRiskId!)
              .toSet();
          _customRisks.value = value
              .where((e) => e.isCustom)
              .map((e) => e.name)
              .toList();
        });
      case Err(:final failure):
        _addressRisks.value = UiFailure(failure);
    }
  }

  void toggleMasterRisk(String id) {
    final current = _selectedSiteRiskIds.value;
    if (current.contains(id)) {
      _selectedSiteRiskIds.value = current.where((e) => e != id).toSet();
    } else {
      _selectedSiteRiskIds.value = {...current, id};
    }
  }

  void addCustomRisk(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 255) return;
    if (!_customRisks.value.contains(trimmed)) {
      _customRisks.value = [..._customRisks.value, trimmed];
    }
  }

  void removeCustomRisk(int index) {
    if (index < 0 || index >= _customRisks.value.length) return;
    final updated = List<String>.from(_customRisks.value)..removeAt(index);
    _customRisks.value = updated;
  }

  Future<void> saveAddressRisks(String customerId, String addressId) async {
    _saveState.value = const UiLoading();
    final result = await _repository.updateAddressRisks(
      customerId: customerId,
      addressId: addressId,
      siteRiskIds: _selectedSiteRiskIds.value.toList(),
      customRisks: _customRisks.value,
    );
    if (_isDisposed) return;
    switch (result) {
      case Ok(:final value):
        batch(() {
          _saveState.value = UiSuccess(value);
          _addressRisks.value = UiSuccess(value);
        });
      case Err(:final failure):
        _saveState.value = UiFailure(failure);
    }
  }

  void dispose() {
    _isDisposed = true;
    _masterRisks.dispose();
    _addressRisks.dispose();
    _saveState.dispose();
    _selectedSiteRiskIds.dispose();
    _customRisks.dispose();
  }
}
