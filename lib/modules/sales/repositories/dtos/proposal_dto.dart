import 'package:centrow_sales/modules/sales/entities/proposal.dart';

class ProposalListItemDto {
  final String id;
  final String code;
  final String customerId;
  final String customerName;
  final String serviceId;
  final String serviceName;
  final String proposalDate;
  final String? validUntil;
  final double totalAmount;
  final String status;
  final String createdAt;

  const ProposalListItemDto({
    required this.id,
    required this.code,
    required this.customerId,
    required this.customerName,
    required this.serviceId,
    required this.serviceName,
    required this.proposalDate,
    this.validUntil,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory ProposalListItemDto.fromJson(Map<String, dynamic> json) {
    return ProposalListItemDto(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      proposalDate: json['proposal_date']?.toString() ?? '',
      validUntil: json['valid_until']?.toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Proposal toEntity() {
    return Proposal(
      id: id,
      code: code,
      customerId: customerId,
      clientName: customerName,
      serviceId: serviceId,
      serviceName: serviceName,
      status: ProposalStatus.fromString(status),
      date: proposalDate,
      validUntil: validUntil ?? '',
      location: '',
      version: '1',
      total: totalAmount,
      createdAt: createdAt,
    );
  }
}

class ProposalPaginationDto {
  final int total;
  final int totalPage;
  final bool hasNext;

  const ProposalPaginationDto({
    required this.total,
    required this.totalPage,
    required this.hasNext,
  });

  factory ProposalPaginationDto.fromJson(Map<String, dynamic> json) {
    return ProposalPaginationDto(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPage: (json['total_page'] as num?)?.toInt() ?? 0,
      hasNext: json['has_next'] as bool? ?? false,
    );
  }
}

class ProposalListResponseDto {
  final List<ProposalListItemDto> items;
  final ProposalPaginationDto pagination;

  const ProposalListResponseDto({
    required this.items,
    required this.pagination,
  });

  factory ProposalListResponseDto.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?) ?? [];
    final paginationJson =
        json['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return ProposalListResponseDto(
      items: itemsList
          .map(
            (e) => ProposalListItemDto.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
      pagination: ProposalPaginationDto.fromJson(paginationJson),
    );
  }

  List<Proposal> toEntity() => items.map((e) => e.toEntity()).toList();
}

class ProposalDetailDto {
  final String id;
  final String code;
  final String customerId;
  final String customerName;
  final String serviceId;
  final String serviceName;
  final int version;
  final String proposalDate;
  final String? validUntil;
  final double totalAmount;
  final String status;
  final String? statusLabel;
  final String? sentAt;
  final String? decidedAt;
  final String? rejectionReason;
  final String? notes;
  final String createdAt;

  const ProposalDetailDto({
    required this.id,
    required this.code,
    required this.customerId,
    required this.customerName,
    required this.serviceId,
    required this.serviceName,
    required this.version,
    required this.proposalDate,
    this.validUntil,
    required this.totalAmount,
    required this.status,
    this.statusLabel,
    this.sentAt,
    this.decidedAt,
    this.rejectionReason,
    this.notes,
    required this.createdAt,
  });

  factory ProposalDetailDto.fromJson(Map<String, dynamic> json) {
    return ProposalDetailDto(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      version: (json['version'] as num?)?.toInt() ?? 1,
      proposalDate: json['proposal_date']?.toString() ?? '',
      validUntil: json['valid_until']?.toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString(),
      sentAt: json['sent_at']?.toString(),
      decidedAt: json['decided_at']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Proposal toEntity() {
    return Proposal(
      id: id,
      code: code,
      customerId: customerId,
      clientName: customerName,
      serviceId: serviceId,
      serviceName: serviceName,
      status: ProposalStatus.fromString(status),
      date: proposalDate,
      validUntil: validUntil ?? '',
      location: '',
      version: version.toString(),
      total: totalAmount,
      notes: notes,
      sentAt: sentAt,
      decidedAt: decidedAt,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
    );
  }
}

class CreateProposalResponseDto {
  final String id;
  final String code;
  final String customerId;
  final String serviceId;
  final String proposalDate;
  final String status;
  final double totalAmount;
  final String createdAt;

  const CreateProposalResponseDto({
    required this.id,
    required this.code,
    required this.customerId,
    required this.serviceId,
    required this.proposalDate,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory CreateProposalResponseDto.fromJson(Map<String, dynamic> json) {
    return CreateProposalResponseDto(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      proposalDate: json['proposal_date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Proposal toEntity() {
    return Proposal(
      id: id,
      code: code,
      customerId: customerId,
      clientName: '',
      serviceId: serviceId,
      serviceName: '',
      status: ProposalStatus.fromString(status),
      date: proposalDate,
      validUntil: '',
      location: '',
      version: '1',
      total: totalAmount,
      createdAt: createdAt,
    );
  }
}

class ProposalItemDto {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double qty;
  final double frequency;
  final String unitCode;
  final double unitCost;
  final int? kind;

  const ProposalItemDto({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.price,
    this.qty = 1.0,
    this.frequency = 1.0,
    this.unitCode = '',
    this.unitCost = 0.0,
    this.kind,
  });

  factory ProposalItemDto.fromJson(Map<String, dynamic> json) {
    return ProposalItemDto(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      qty: (json['qty'] as num?)?.toDouble() ?? 1.0,
      frequency: (json['frequency'] as num?)?.toDouble() ?? 1.0,
      unitCode: (json['unit_code'] ?? json['unitCode'])?.toString() ?? '',
      unitCost:
          ((json['unit_cost'] ?? json['unitCost']) as num?)?.toDouble() ?? 0.0,
      kind: (json['kind'] as num?)?.toInt(),
    );
  }

  ProposalItem toEntity() {
    return ProposalItem(
      id: id,
      title: title,
      description: description,
      category: ProposalItemCategory.fromString(category),
      price: price,
      qty: qty,
      frequency: frequency,
      unitCode: unitCode,
      unitCost: unitCost,
      kind: kind,
    );
  }
}
