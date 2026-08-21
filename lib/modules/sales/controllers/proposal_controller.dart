import 'dart:async';
import 'package:signals/signals.dart';
import '../../../shared/result/result.dart';
import '../../../shared/state/ui_state.dart';
import '../entities/proposal.dart';
import '../repositories/proposal_repository.dart';

class ProposalController {
  final ProposalRepository _repository;

  ProposalController(this._repository);

  bool _isDisposed = false;

  final _proposalsState = signal<UiState<List<Proposal>>>(const UiInitial());
  ReadonlySignal<UiState<List<Proposal>>> get proposalsState => _proposalsState;

  final _proposalDetailState = signal<UiState<Proposal>>(const UiInitial());
  ReadonlySignal<UiState<Proposal>> get proposalDetailState =>
      _proposalDetailState;

  final _selectedProposalId = signal<String>('');
  ReadonlySignal<String> get selectedProposalId => _selectedProposalId;

  final _searchQuery = signal<String>('');
  ReadonlySignal<String> get searchQuery => _searchQuery;

  final _selectedStatus = signal<String>('all');
  ReadonlySignal<String> get selectedStatus => _selectedStatus;

  final _activePricingTab = signal<int>(0);
  ReadonlySignal<int> get activePricingTab => _activePricingTab;

  late final filteredProposals = computed<List<Proposal>>(() {
    final state = _proposalsState.value;
    if (state is! UiSuccess<List<Proposal>>) return <Proposal>[];

    var list = state.data;
    final q = _searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.clientName.toLowerCase().contains(q) ||
                p.code.toLowerCase().contains(q) ||
                p.serviceName.toLowerCase().contains(q) ||
                p.location.toLowerCase().contains(q),
          )
          .toList();
    }
    final status = _selectedStatus.value.trim().toLowerCase();
    if (status != 'all' && status != 'semua' && status.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.status.value.toLowerCase() == status ||
                p.status.displayName.toLowerCase() == status ||
                p.status.name.toLowerCase() == status,
          )
          .toList();
    }
    return list;
  });

  late final selectedProposal = computed<Proposal?>(() {
    final detail = _proposalDetailState.value.dataOrNull;
    if (detail != null &&
        (_selectedProposalId.value.isEmpty ||
            detail.id == _selectedProposalId.value ||
            detail.code == _selectedProposalId.value)) {
      return detail;
    }
    final list = filteredProposals.value;
    if (list.isEmpty) {
      final all = _proposalsState.value.dataOrNull ?? [];
      if (all.isEmpty) return null;
      if (_selectedProposalId.value.isNotEmpty) {
        final idx = all.indexWhere(
          (p) =>
              p.id == _selectedProposalId.value ||
              p.code == _selectedProposalId.value,
        );
        if (idx != -1) return all[idx];
      }
      return all.first;
    }
    if (_selectedProposalId.value.isNotEmpty) {
      final idx = list.indexWhere(
        (p) =>
            p.id == _selectedProposalId.value ||
            p.code == _selectedProposalId.value,
      );
      if (idx != -1) return list[idx];
    }
    return list.first;
  });

  late final activePricingCategory = computed<ProposalItemCategory>(() {
    return switch (_activePricingTab.value) {
      0 => ProposalItemCategory.persiapan,
      1 => ProposalItemCategory.teknisi,
      2 => ProposalItemCategory.transport,
      _ => ProposalItemCategory.persiapan,
    };
  });

  late final activePricingItems = computed<List<ProposalItem>>(() {
    final proposal = selectedProposal.value;
    if (proposal == null) return <ProposalItem>[];
    return proposal.getItemsByCategory(activePricingCategory.value);
  });

  Future<void> loadProposals({bool isRefresh = false}) async {
    if (!isRefresh && _proposalsState.value is! UiSuccess) {
      _proposalsState.value = const UiLoading();
    }
    final result = await _repository.getProposals(
      query: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
      status: _selectedStatus.value != 'all' && _selectedStatus.value != 'semua'
          ? _selectedStatus.value
          : null,
    );
    if (_isDisposed) return;
    _proposalsState.value = switch (result) {
      Ok(:final value) => UiSuccess<List<Proposal>>(value),
      Err(:final failure) => UiFailure<List<Proposal>>(failure),
    };

    final state = _proposalsState.value;
    if (state is UiSuccess<List<Proposal>> && state.data.isNotEmpty) {
      final targetId = _selectedProposalId.value;
      if (targetId.isEmpty ||
          !state.data.any((p) => p.id == targetId || p.code == targetId)) {
        await selectProposal(state.data.first.id);
      }
    }
  }

  Future<void> selectProposal(String id) async {
    _selectedProposalId.value = id;
    if (id.isEmpty) {
      _proposalDetailState.value = const UiInitial();
      return;
    }
    _proposalDetailState.value = const UiLoading();
    final result = await _repository.getProposalById(id);
    if (_isDisposed) return;
    if (_selectedProposalId.value == id) {
      _proposalDetailState.value = switch (result) {
        Ok(:final value) => UiSuccess<Proposal>(value),
        Err(:final failure) => UiFailure<Proposal>(failure),
      };
    }
  }

  Future<void> loadProposalDetail(String id) async {
    await selectProposal(id);
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void selectStatus(String status) {
    _selectedStatus.value = status;
  }

  void setPricingTab(int tabIndex) {
    _activePricingTab.value = tabIndex;
  }

  void setActivePricingTab(int tabIndex) {
    _activePricingTab.value = tabIndex;
  }

  void changeTab(int tabIndex) {
    _activePricingTab.value = tabIndex;
  }

  void setPricingCategory(ProposalItemCategory category) {
    _activePricingTab.value = switch (category) {
      ProposalItemCategory.persiapan => 0,
      ProposalItemCategory.teknisi => 1,
      ProposalItemCategory.transport => 2,
    };
  }

  void dispose() {
    _isDisposed = true;
    _proposalsState.dispose();
    _proposalDetailState.dispose();
    _selectedProposalId.dispose();
    _searchQuery.dispose();
    _selectedStatus.dispose();
    _activePricingTab.dispose();
    filteredProposals.dispose();
    selectedProposal.dispose();
    activePricingCategory.dispose();
    activePricingItems.dispose();
  }
}
