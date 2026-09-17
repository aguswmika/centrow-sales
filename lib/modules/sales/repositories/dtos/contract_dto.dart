import 'package:centrow_sales/modules/sales/entities/contract.dart';

class ContractListItemDto {
  final String id;
  final String code;
  final String customerId;
  final String customerName;
  final String serviceId;
  final String serviceName;
  final String categoryId;
  final String categoryName;
  final String startDate;
  final String? endDate;
  final double contractValue;
  final String paymentType;
  final String status;
  final String? createdAt;

  const ContractListItemDto({
    required this.id,
    required this.code,
    required this.customerId,
    required this.customerName,
    required this.serviceId,
    required this.serviceName,
    required this.categoryId,
    required this.categoryName,
    required this.startDate,
    this.endDate,
    required this.contractValue,
    required this.paymentType,
    required this.status,
    this.createdAt,
  });

  factory ContractListItemDto.fromJson(Map<String, dynamic> json) =>
      ContractListItemDto(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        customerId: json['customer_id']?.toString() ?? '',
        customerName: json['customer_name']?.toString() ?? '',
        serviceId: json['service_id']?.toString() ?? '',
        serviceName: json['service_name']?.toString() ?? '',
        categoryId: json['category_id']?.toString() ?? '',
        categoryName: json['category_name']?.toString() ?? '',
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString(),
        contractValue: (json['contract_value'] as num?)?.toDouble() ?? 0.0,
        paymentType: json['payment_type']?.toString() ?? 'full',
        status: json['status']?.toString() ?? 'draft',
        createdAt: json['created_at']?.toString(),
      );

  Contract toEntity() => Contract(
    id: id,
    code: code,
    customerId: customerId,
    customerName: customerName,
    serviceId: serviceId,
    serviceName: serviceName,
    categoryId: categoryId,
    categoryName: categoryName,
    status: ContractStatus.fromString(status),
    startDate: startDate,
    endDate: endDate,
    contractValue: contractValue,
    paymentType: ContractPaymentType.fromString(paymentType),
    createdAt: createdAt,
  );
}

class ContractListResponseDto {
  final List<ContractListItemDto> items;

  const ContractListResponseDto({required this.items});

  factory ContractListResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = (json['items'] as List<dynamic>?) ?? [];
    return ContractListResponseDto(
      items: raw
          .map(
            (e) => ContractListItemDto.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }

  List<Contract> toEntity() => items.map((e) => e.toEntity()).toList();
}

class ContractDetailDto {
  final String id;
  final String code;
  final String customerId;
  final String customerName;
  final String serviceId;
  final String serviceName;
  final String categoryId;
  final String categoryName;
  final String? signedDate;
  final String startDate;
  final String? endDate;
  final String? firstInvoiceDate;
  final int? totalVisits;
  final double contractValue;
  final int? paymentTypeId;
  final String paymentType;
  final String? signatoryName;
  final String? signatoryPosition;
  final String status;
  final String? statusLabel;
  final String? terminatedAt;
  final String? terminationReason;
  final String? notes;
  final String? createdAt;
  final Map<String, dynamic>? sourceProposal;

  const ContractDetailDto({
    required this.id,
    required this.code,
    required this.customerId,
    required this.customerName,
    required this.serviceId,
    required this.serviceName,
    required this.categoryId,
    required this.categoryName,
    this.signedDate,
    required this.startDate,
    this.endDate,
    this.firstInvoiceDate,
    this.totalVisits,
    required this.contractValue,
    this.paymentTypeId,
    required this.paymentType,
    this.signatoryName,
    this.signatoryPosition,
    required this.status,
    this.statusLabel,
    this.terminatedAt,
    this.terminationReason,
    this.notes,
    this.createdAt,
    this.sourceProposal,
  });

  factory ContractDetailDto.fromJson(Map<String, dynamic> json) =>
      ContractDetailDto(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        customerId: json['customer_id']?.toString() ?? '',
        customerName: json['customer_name']?.toString() ?? '',
        serviceId: json['service_id']?.toString() ?? '',
        serviceName: json['service_name']?.toString() ?? '',
        categoryId: json['category_id']?.toString() ?? '',
        categoryName: json['category_name']?.toString() ?? '',
        signedDate: json['signed_date']?.toString(),
        startDate: json['start_date']?.toString() ?? '',
        endDate: json['end_date']?.toString(),
        firstInvoiceDate: json['first_invoice_date']?.toString(),
        totalVisits: (json['total_visits'] as num?)?.toInt(),
        contractValue: (json['contract_value'] as num?)?.toDouble() ?? 0.0,
        paymentTypeId: (json['payment_type_id'] as num?)?.toInt(),
        paymentType: json['payment_type']?.toString() ?? 'full',
        signatoryName: json['signatory_name']?.toString(),
        signatoryPosition: json['signatory_position']?.toString(),
        status: json['status']?.toString() ?? 'draft',
        statusLabel: json['status_label']?.toString(),
        terminatedAt: json['terminated_at']?.toString(),
        terminationReason: json['termination_reason']?.toString(),
        notes: json['notes']?.toString(),
        createdAt: json['created_at']?.toString(),
        sourceProposal: (json['source_proposal'] as Map?)
            ?.cast<String, dynamic>(),
      );

  Contract toEntity() {
    final sp = sourceProposal;
    return Contract(
      id: id,
      code: code,
      customerId: customerId,
      customerName: customerName,
      serviceId: serviceId,
      serviceName: serviceName,
      categoryId: categoryId,
      categoryName: categoryName,
      status: ContractStatus.fromString(status),
      startDate: startDate,
      endDate: endDate,
      contractValue: contractValue,
      paymentType: ContractPaymentType.fromString(paymentType),
      signedDate: signedDate,
      firstInvoiceDate: firstInvoiceDate,
      totalVisits: totalVisits,
      signatoryName: signatoryName,
      signatoryPosition: signatoryPosition,
      notes: notes,
      terminatedAt: terminatedAt,
      terminationReason: terminationReason,
      createdAt: createdAt,
      sourceProposalId: sp?['id']?.toString(),
      sourceProposalCode: sp?['code']?.toString(),
    );
  }
}

class ContractStatusResponseDto {
  final String id;
  final String status;
  final String? statusLabel;

  const ContractStatusResponseDto({
    required this.id,
    required this.status,
    this.statusLabel,
  });

  factory ContractStatusResponseDto.fromJson(Map<String, dynamic> json) =>
      ContractStatusResponseDto(
        id: json['id']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        statusLabel: json['status_label']?.toString(),
      );

  ContractStatusResult toEntity() => ContractStatusResult(
    id: id,
    status: ContractStatus.fromString(status),
    statusLabel: statusLabel,
  );
}

class CreateContractResponseDto {
  final String id;
  final String code;
  final String customerId;
  final String serviceId;
  final String categoryId;
  final String startDate;
  final double contractValue;
  final String paymentType;
  final String status;
  final String? createdAt;
  final String? proposalId;

  const CreateContractResponseDto({
    required this.id,
    required this.code,
    required this.customerId,
    required this.serviceId,
    required this.categoryId,
    required this.startDate,
    required this.contractValue,
    required this.paymentType,
    required this.status,
    this.createdAt,
    this.proposalId,
  });

  factory CreateContractResponseDto.fromJson(Map<String, dynamic> json) =>
      CreateContractResponseDto(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        customerId: json['customer_id']?.toString() ?? '',
        serviceId: json['service_id']?.toString() ?? '',
        categoryId: json['category_id']?.toString() ?? '',
        startDate: json['start_date']?.toString() ?? '',
        contractValue: (json['contract_value'] as num?)?.toDouble() ?? 0.0,
        paymentType: json['payment_type']?.toString() ?? 'full',
        status: json['status']?.toString() ?? 'draft',
        createdAt: json['created_at']?.toString(),
        proposalId: json['proposal_id']?.toString(),
      );

  Contract toEntity() => Contract(
    id: id,
    code: code,
    customerId: customerId,
    serviceId: serviceId,
    categoryId: categoryId,
    status: ContractStatus.fromString(status),
    startDate: startDate,
    contractValue: contractValue,
    paymentType: ContractPaymentType.fromString(paymentType),
    createdAt: createdAt,
    sourceProposalId: proposalId,
  );
}

class ContractFormRequestDto {
  final String categoryId;
  final String startDate;
  final String? endDate;
  final String? firstInvoiceDate;
  final String signedDate;
  final int paymentTypeId;
  final String notes;
  final String? contractTemplateId;

  const ContractFormRequestDto({
    required this.categoryId,
    required this.startDate,
    this.endDate,
    this.firstInvoiceDate,
    required this.signedDate,
    required this.paymentTypeId,
    required this.notes,
    this.contractTemplateId,
  });

  factory ContractFormRequestDto.fromInput(ContractFormInput input) =>
      ContractFormRequestDto(
        categoryId: input.categoryId,
        startDate: input.startDate,
        endDate: input.endDate,
        firstInvoiceDate: input.firstInvoiceDate,
        signedDate: input.signedDate,
        paymentTypeId: input.paymentTypeId,
        notes: input.notes,
        contractTemplateId: input.contractTemplateId,
      );

  Map<String, dynamic> toJson() => {
    'category_id': categoryId,
    'start_date': startDate,
    if (endDate != null && endDate!.isNotEmpty) 'end_date': endDate,
    if (firstInvoiceDate != null && firstInvoiceDate!.isNotEmpty)
      'first_invoice_date': firstInvoiceDate,
    'signed_date': signedDate,
    'payment_type_id': paymentTypeId,
    'notes': notes,
    if (contractTemplateId != null) 'contract_template_id': contractTemplateId,
  };
}
