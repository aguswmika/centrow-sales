import 'package:centrow_sales/modules/sales/entities/proposal.dart';

class ProposalStatusResult {
  final String id;
  final ProposalStatus status;
  final String? statusLabel;
  final String? sentAt;
  final String? decidedAt;
  final String? rejectionReason;

  const ProposalStatusResult({
    required this.id,
    required this.status,
    this.statusLabel,
    this.sentAt,
    this.decidedAt,
    this.rejectionReason,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProposalStatusResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          statusLabel == other.statusLabel &&
          sentAt == other.sentAt &&
          decidedAt == other.decidedAt &&
          rejectionReason == other.rejectionReason;

  @override
  int get hashCode =>
      Object.hash(id, status, statusLabel, sentAt, decidedAt, rejectionReason);

  @override
  String toString() =>
      'ProposalStatusResult(id: $id, status: ${status.value}, sentAt: $sentAt, decidedAt: $decidedAt, rejectionReason: $rejectionReason)';
}
