enum SyncAction { created, updated, deleted }

sealed class DataSyncEvent {
  const DataSyncEvent();
}

final class CustomerSyncEvent extends DataSyncEvent {
  final String customerId;
  final SyncAction action;

  const CustomerSyncEvent(this.customerId, {this.action = SyncAction.updated});

  @override
  String toString() =>
      'CustomerSyncEvent(customerId: $customerId, action: $action)';
}

final class ProposalSyncEvent extends DataSyncEvent {
  final String proposalId;
  final String? customerId;
  final SyncAction action;

  const ProposalSyncEvent(
    this.proposalId, {
    this.customerId,
    this.action = SyncAction.updated,
  });

  @override
  String toString() =>
      'ProposalSyncEvent(proposalId: $proposalId, customerId: $customerId, action: $action)';
}

final class PricingSyncEvent extends DataSyncEvent {
  final String proposalId;

  const PricingSyncEvent(this.proposalId);

  @override
  String toString() => 'PricingSyncEvent(proposalId: $proposalId)';
}

final class ContractSyncEvent extends DataSyncEvent {
  final String contractId;
  final String? proposalId;
  final SyncAction action;

  const ContractSyncEvent(
    this.contractId, {
    this.proposalId,
    this.action = SyncAction.created,
  });

  @override
  String toString() =>
      'ContractSyncEvent(contractId: $contractId, proposalId: $proposalId, action: $action)';
}
