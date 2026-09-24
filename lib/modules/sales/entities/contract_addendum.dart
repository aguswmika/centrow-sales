class ContractAddendum {
  final String id;
  final String contractId;
  final int visitDelta;
  final int oldTotalVisits;
  final int newTotalVisits;
  final double oldContractValue;
  final double newContractValue;
  final String? pricingId;
  final String? reason;
  final String? createdBy;
  final String? createdAt;

  const ContractAddendum({
    required this.id,
    required this.contractId,
    required this.visitDelta,
    required this.oldTotalVisits,
    required this.newTotalVisits,
    required this.oldContractValue,
    required this.newContractValue,
    this.pricingId,
    this.reason,
    this.createdBy,
    this.createdAt,
  });

  String get formattedVisitDelta =>
      visitDelta > 0 ? '+$visitDelta' : '$visitDelta';

  String get formattedOldContractValue => _formatCurrency(oldContractValue);

  String get formattedNewContractValue => _formatCurrency(newContractValue);

  double get contractValueDelta => newContractValue - oldContractValue;

  String get formattedContractValueDelta {
    final delta = contractValueDelta;
    if (delta > 0) {
      return '+${_formatCurrency(delta)}';
    } else if (delta < 0) {
      return _formatCurrency(delta);
    } else {
      return 'Rp 0';
    }
  }

  @override
  String toString() =>
      'ContractAddendum(id: $id, contractId: $contractId, pricingId: $pricingId, visitDelta: $visitDelta, oldTotalVisits: $oldTotalVisits, newTotalVisits: $newTotalVisits)';
}

String _formatCurrency(double amount) {
  if (amount == 0) return 'Rp 0';
  final isNegative = amount < 0;
  final absAmount = amount.abs();
  final intPart = absAmount.truncate();
  final formattedInt = intPart.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
  return isNegative ? '-Rp $formattedInt' : 'Rp $formattedInt';
}
