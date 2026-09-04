import 'dart:async';
import 'package:signals/signals.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_status_result.dart';
import 'package:centrow_sales/modules/sales/entities/update_proposal_input.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';

class ProposalController {
  final ProposalRepository _repository;

  ProposalController(this._repository);

  bool _isDisposed = false;

  final _proposalsState = signal<UiState<List<Proposal>>>(const UiInitial());
  ReadonlySignal<UiState<List<Proposal>>> get proposalsState => _proposalsState;

  final _proposalDetailState = signal<UiState<Proposal>>(const UiInitial());
  ReadonlySignal<UiState<Proposal>> get proposalDetailState =>
      _proposalDetailState;

  final _actionState = signal<UiState<ProposalStatusResult>>(const UiInitial());
  ReadonlySignal<UiState<ProposalStatusResult>> get actionState => _actionState;

  void resetActionState() => _actionState.value = const UiInitial();

  final _selectedProposalId = signal<String>('');
  ReadonlySignal<String> get selectedProposalId => _selectedProposalId;

  final _searchQuery = signal<String>('');
  ReadonlySignal<String> get searchQuery => _searchQuery;

  final _selectedStatus = signal<String>('all');
  ReadonlySignal<String> get selectedStatus => _selectedStatus;

  final _activePricingTab = signal<int>(0);
  ReadonlySignal<int> get activePricingTab => _activePricingTab;

  final _activeDetailTab = signal<int>(0);
  ReadonlySignal<int> get activeDetailTab => _activeDetailTab;

  void setDetailTab(int tabIndex) {
    _activeDetailTab.value = tabIndex;
  }

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
                p.status.name.toLowerCase() == status ||
                (p.status == ProposalStatus.sent &&
                    (status == 'dikirim' || status == 'terkirim')) ||
                (p.status == ProposalStatus.accepted &&
                    (status == 'disetujui' || status == 'diterima')) ||
                (p.status == ProposalStatus.rejected && status == 'ditolak'),
          )
          .toList();
    }
    return list;
  });

  late final selectedProposal = computed<Proposal?>(() {
    final selectedId = _selectedProposalId.value;
    if (selectedId.isEmpty) return null;

    final detail = _proposalDetailState.value.dataOrNull;
    if (detail != null &&
        (detail.id == selectedId || detail.code == selectedId)) {
      return detail;
    }
    final list = filteredProposals.value;
    final idx = list.indexWhere(
      (p) => p.id == selectedId || p.code == selectedId,
    );
    if (idx != -1) return list[idx];

    final all = _proposalsState.value.dataOrNull ?? [];
    final allIdx = all.indexWhere(
      (p) => p.id == selectedId || p.code == selectedId,
    );
    if (allIdx != -1) return all[allIdx];

    return null;
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
      if (targetId.isNotEmpty &&
          !state.data.any((p) => p.id == targetId || p.code == targetId)) {
        await selectProposal('');
      }
    }
  }

  Future<void> reviseProposal(String id, UpdateProposalInput data) async {
    _proposalDetailState.value = const UiLoading();
    final result = await _repository.reviseProposal(id, data);
    _proposalDetailState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };
    if (result is Ok) {
      await loadProposals(); // refresh master list
    }
  }

  Future<Result<ProposalStatusResult>> sendProposal(String id) async {
    return _handleTransition(() => _repository.sendProposal(id));
  }

  Future<Result<ProposalStatusResult>> acceptProposal(String id) async {
    return _handleTransition(() => _repository.acceptProposal(id));
  }

  Future<Result<ProposalStatusResult>> rejectProposal(
    String id,
    String reason,
  ) async {
    return _handleTransition(() => _repository.rejectProposal(id, reason));
  }

  Future<Result<ProposalStatusResult>> expireProposal(String id) async {
    return _handleTransition(() => _repository.expireProposal(id));
  }

  Future<Result<ProposalStatusResult>> cancelProposal(String id) async {
    return _handleTransition(() => _repository.cancelProposal(id));
  }

  Future<Result<ProposalStatusResult>> _handleTransition(
    Future<Result<ProposalStatusResult>> Function() action,
  ) async {
    _actionState.value = const UiLoading();
    final result = await action();
    if (_isDisposed) return result;

    _actionState.value = switch (result) {
      Ok(:final value) => UiSuccess(value),
      Err(:final failure) => UiFailure(failure),
    };

    if (result is Ok<ProposalStatusResult>) {
      _applyStatusResult(result.value);
      await loadProposals(isRefresh: true);
    }
    return result;
  }

  void _applyStatusResult(ProposalStatusResult res) {
    final current = _proposalDetailState.value.dataOrNull;
    if (current != null && current.id == res.id) {
      _proposalDetailState.value = UiSuccess(
        current.copyWith(
          status: res.status,
          sentAt: res.sentAt ?? current.sentAt,
          decidedAt: res.decidedAt ?? current.decidedAt,
          rejectionReason: res.rejectionReason ?? current.rejectionReason,
        ),
      );
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
    _actionState.dispose();
    _selectedProposalId.dispose();
    _searchQuery.dispose();
    _selectedStatus.dispose();
    _activePricingTab.dispose();
    _activeDetailTab.dispose();
    filteredProposals.dispose();
    selectedProposal.dispose();
    activePricingCategory.dispose();
    activePricingItems.dispose();
  }
}
