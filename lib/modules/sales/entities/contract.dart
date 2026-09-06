enum ContractStatus {
  draft('Draf', 'neutral', 'draft'),
  active('Aktif', 'ok', 'active'),
  suspended('Ditangguhkan', 'warn', 'suspended'),
  expired('Kedaluwarsa', 'err', 'expired'),
  terminated('Diterminasi', 'err', 'terminated'),
  cancelled('Dibatalkan', 'neutral', 'cancelled');

  final String displayName;
  final String badgeType;
  final String value;

  const ContractStatus(this.displayName, this.badgeType, this.value);

  bool get isDraft => this == ContractStatus.draft;
  bool get isActive => this == ContractStatus.active;
  bool get isSuspended => this == ContractStatus.suspended;
  bool get isTerminal =>
      this == ContractStatus.terminated ||
      this == ContractStatus.cancelled ||
      this == ContractStatus.expired;

  bool get canActivate => isDraft || isSuspended;
  bool get canSuspend => isActive;
  bool get canTerminate => isActive || isSuspended;
  bool get canCancel => isDraft;
  bool get canEdit => isDraft;
  bool get canDelete => isDraft;

  static ContractStatus fromString(String val) =>
      switch (val.toLowerCase().trim()) {
        'draft' || 'draf' => ContractStatus.draft,
        'active' || 'aktif' => ContractStatus.active,
        'suspended' || 'ditangguhkan' => ContractStatus.suspended,
        'expired' || 'kedaluwarsa' => ContractStatus.expired,
        'terminated' || 'diterminasi' => ContractStatus.terminated,
        'cancelled' || 'canceled' || 'dibatalkan' => ContractStatus.cancelled,
        _ => ContractStatus.draft,
      };
}

enum ContractPaymentType {
  full('Lunas', 'full', 1),
  deposit('Uang Muka', 'deposit', 2),
  termin('Termin', 'termin', 3),
  monthly('Bulanan', 'monthly', 4);

  final String displayName;
  final String value;
  final int id;

  const ContractPaymentType(this.displayName, this.value, this.id);

  static ContractPaymentType fromString(String val) =>
      switch (val.toLowerCase().trim()) {
        'deposit' => ContractPaymentType.deposit,
        'termin' => ContractPaymentType.termin,
        'monthly' => ContractPaymentType.monthly,
        _ => ContractPaymentType.full,
      };

  static ContractPaymentType fromInt(int val) => switch (val) {
    2 => ContractPaymentType.deposit,
    3 => ContractPaymentType.termin,
    4 => ContractPaymentType.monthly,
    _ => ContractPaymentType.full,
  };
}

class Contract {
  final String id;
  final String code;
  final String customerId;
  final String customerName;
  final String serviceId;
  final String serviceName;
  final String categoryId;
  final String categoryName;
  final ContractStatus status;
  final String startDate;
  final String? endDate;
  final double contractValue;
  final ContractPaymentType paymentType;
  final String? signedDate;
  final String? firstInvoiceDate;
  final int? totalVisits;
  final String? signatoryName;
  final String? signatoryPosition;
  final String? notes;
  final String? terminatedAt;
  final String? terminationReason;
  final String? createdAt;
  final String? sourceProposalId;
  final String? sourceProposalCode;

  const Contract({
    required this.id,
    required this.code,
    required this.customerId,
    this.customerName = '',
    required this.serviceId,
    this.serviceName = '',
    required this.categoryId,
    this.categoryName = '',
    required this.status,
    required this.startDate,
    this.endDate,
    this.contractValue = 0.0,
    this.paymentType = ContractPaymentType.full,
    this.signedDate,
    this.firstInvoiceDate,
    this.totalVisits,
    this.signatoryName,
    this.signatoryPosition,
    this.notes,
    this.terminatedAt,
    this.terminationReason,
    this.createdAt,
    this.sourceProposalId,
    this.sourceProposalCode,
  });

  String get formattedValue => _formatCurrency(contractValue);

  Contract copyWith({
    String? id,
    String? code,
    String? customerId,
    String? customerName,
    String? serviceId,
    String? serviceName,
    String? categoryId,
    String? categoryName,
    ContractStatus? status,
    String? startDate,
    String? endDate,
    double? contractValue,
    ContractPaymentType? paymentType,
    String? signedDate,
    String? firstInvoiceDate,
    int? totalVisits,
    String? signatoryName,
    String? signatoryPosition,
    String? notes,
    String? terminatedAt,
    String? terminationReason,
    String? createdAt,
    String? sourceProposalId,
    String? sourceProposalCode,
  }) {
    return Contract(
      id: id ?? this.id,
      code: code ?? this.code,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      contractValue: contractValue ?? this.contractValue,
      paymentType: paymentType ?? this.paymentType,
      signedDate: signedDate ?? this.signedDate,
      firstInvoiceDate: firstInvoiceDate ?? this.firstInvoiceDate,
      totalVisits: totalVisits ?? this.totalVisits,
      signatoryName: signatoryName ?? this.signatoryName,
      signatoryPosition: signatoryPosition ?? this.signatoryPosition,
      notes: notes ?? this.notes,
      terminatedAt: terminatedAt ?? this.terminatedAt,
      terminationReason: terminationReason ?? this.terminationReason,
      createdAt: createdAt ?? this.createdAt,
      sourceProposalId: sourceProposalId ?? this.sourceProposalId,
      sourceProposalCode: sourceProposalCode ?? this.sourceProposalCode,
    );
  }

  @override
  String toString() =>
      'Contract(id: $id, code: $code, status: ${status.value}, startDate: $startDate)';
}

class ContractStatusResult {
  final String id;
  final ContractStatus status;
  final String? statusLabel;

  const ContractStatusResult({
    required this.id,
    required this.status,
    this.statusLabel,
  });
}

class CreateContractFromProposalInput {
  final String categoryId;
  final String? code;
  final String? signedDate;
  final String startDate;
  final String? endDate;
  final String? firstInvoiceDate;
  final int? totalVisits;
  final double? contractValue;
  final int? paymentTypeId;
  final String? signatoryName;
  final String? signatoryPosition;
  final String? notes;

  const CreateContractFromProposalInput({
    required this.categoryId,
    this.code,
    this.signedDate,
    required this.startDate,
    this.endDate,
    this.firstInvoiceDate,
    this.totalVisits,
    this.contractValue,
    this.paymentTypeId,
    this.signatoryName,
    this.signatoryPosition,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'category_id': categoryId,
    if (code != null && code!.isNotEmpty) 'code': code,
    if (signedDate != null) 'signed_date': signedDate,
    'start_date': startDate,
    if (endDate != null) 'end_date': endDate,
    if (firstInvoiceDate != null) 'first_invoice_date': firstInvoiceDate,
    if (totalVisits != null) 'total_visits': totalVisits,
    if (contractValue != null) 'contract_value': contractValue,
    if (paymentTypeId != null) 'payment_type_id': paymentTypeId,
    if (signatoryName != null) 'signatory_name': signatoryName,
    if (signatoryPosition != null) 'signatory_position': signatoryPosition,
    if (notes != null) 'notes': notes,
  };
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
