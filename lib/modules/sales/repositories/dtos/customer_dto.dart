import '../../entities/create_customer_input.dart';
import '../../entities/customer.dart';

class CustomerListItemDto {
  final String id;
  final String code;
  final String name;
  final String initials;
  final String segmentId;
  final String segment;
  final String status;
  final String npwpNumber;
  final String phone;
  final String email;
  final String scanCode;
  final int activeProposalsCount;
  final int activeContractsCount;
  final String createdAt;
  final String updatedAt;

  const CustomerListItemDto({
    required this.id,
    required this.code,
    required this.name,
    required this.initials,
    required this.segmentId,
    required this.segment,
    required this.status,
    required this.npwpNumber,
    required this.phone,
    required this.email,
    required this.scanCode,
    required this.activeProposalsCount,
    required this.activeContractsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerListItemDto.fromJson(Map<String, dynamic> json) {
    return CustomerListItemDto(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      initials: json['initials']?.toString() ?? '',
      segmentId: json['segment_id']?.toString() ?? '',
      segment: json['segment']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      npwpNumber: json['npwp_number']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      scanCode: json['scan_code']?.toString() ?? '',
      activeProposalsCount:
          (json['active_proposals_count'] as num?)?.toInt() ?? 0,
      activeContractsCount:
          (json['active_contracts_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Customer toEntity() {
    return Customer(
      id: id,
      code: code,
      name: name,
      initials: initials,
      segmentId: segmentId,
      segment: segment,
      status: status,
      npwp: npwpNumber,
      phone: phone,
      email: email,
      scanCode: scanCode,
      activeProposalsCount: activeProposalsCount,
      activeContractsCount: activeContractsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class CustomerLocationDto {
  final String? id;
  final String? customerId;
  final bool isPrimary;
  final String label;
  final String addressLine;
  final String village;
  final String district;
  final String regency;
  final String province;
  final double? areaSize;
  final double? latitude;
  final double? longitude;

  const CustomerLocationDto({
    this.id,
    this.customerId,
    required this.isPrimary,
    required this.label,
    required this.addressLine,
    required this.village,
    required this.district,
    required this.regency,
    required this.province,
    this.areaSize,
    this.latitude,
    this.longitude,
  });

  factory CustomerLocationDto.fromJson(Map<String, dynamic> json) {
    return CustomerLocationDto(
      id: json['id']?.toString(),
      customerId: json['customer_id']?.toString(),
      isPrimary: json['is_primary'] as bool? ?? false,
      label: json['label']?.toString() ?? '',
      addressLine: json['address_line']?.toString() ?? '',
      village: json['village']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      regency: json['regency']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      areaSize: (json['area_size'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  CustomerLocation toEntity() {
    return CustomerLocation(
      id: id,
      customerId: customerId,
      isPrimary: isPrimary,
      label: label,
      addressLine: addressLine,
      village: village,
      district: district,
      regency: regency,
      province: province,
      areaSize: areaSize,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class CustomerContactDto {
  final String? id;
  final String? customerId;
  final String name;
  final String position;
  final String email;
  final String phone;
  final String role;
  final bool isPrimary;

  const CustomerContactDto({
    this.id,
    this.customerId,
    required this.name,
    required this.position,
    required this.email,
    required this.phone,
    required this.role,
    required this.isPrimary,
  });

  factory CustomerContactDto.fromJson(Map<String, dynamic> json) {
    return CustomerContactDto(
      id: json['id']?.toString(),
      customerId: json['customer_id']?.toString(),
      name: json['name']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'pic',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  CustomerContact toEntity() {
    return CustomerContact(
      id: id,
      customerId: customerId,
      name: name,
      position: position,
      email: email,
      phone: phone,
      role: role,
      isPrimary: isPrimary,
    );
  }
}

class CustomerProposalServiceDto {
  final String id;
  final String name;

  const CustomerProposalServiceDto({
    required this.id,
    required this.name,
  });

  factory CustomerProposalServiceDto.fromJson(Map<String, dynamic> json) {
    return CustomerProposalServiceDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class CustomerProposalDto {
  final String id;
  final String customerId;
  final String code;
  final CustomerProposalServiceDto service;
  final String proposalDate;
  final String? validUntil;
  final double totalAmount;
  final String status;

  const CustomerProposalDto({
    required this.id,
    required this.customerId,
    required this.code,
    required this.service,
    required this.proposalDate,
    this.validUntil,
    required this.totalAmount,
    required this.status,
  });

  factory CustomerProposalDto.fromJson(Map<String, dynamic> json) {
    final serviceJson = json['service'] as Map<String, dynamic>? ?? {};
    return CustomerProposalDto(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      service: CustomerProposalServiceDto.fromJson(serviceJson),
      proposalDate: json['proposal_date']?.toString() ?? '',
      validUntil: json['valid_until']?.toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
    );
  }

  CustomerProposalSummary toEntity() {
    return CustomerProposalSummary(
      id: id,
      customerId: customerId,
      code: code,
      serviceId: service.id,
      serviceName: service.name,
      proposalDate: proposalDate,
      validUntil: validUntil,
      totalAmount: totalAmount,
      status: status,
    );
  }
}

class CustomerDetailDto {
  final String id;
  final String code;
  final String name;
  final String initials;
  final String segmentId;
  final String segment;
  final String status;
  final String npwpNumber;
  final String phone;
  final String phoneAlt;
  final String email;
  final String scanCode;
  final String riskNotes;
  final String notes;
  final int activeProposalsCount;
  final int activeContractsCount;
  final String createdAt;
  final String updatedAt;
  final List<CustomerLocationDto> locations;
  final List<CustomerContactDto> contacts;
  final List<CustomerProposalDto> proposals;

  const CustomerDetailDto({
    required this.id,
    required this.code,
    required this.name,
    required this.initials,
    required this.segmentId,
    required this.segment,
    required this.status,
    required this.npwpNumber,
    required this.phone,
    required this.phoneAlt,
    required this.email,
    required this.scanCode,
    required this.riskNotes,
    required this.notes,
    required this.activeProposalsCount,
    required this.activeContractsCount,
    required this.createdAt,
    required this.updatedAt,
    required this.locations,
    required this.contacts,
    required this.proposals,
  });

  factory CustomerDetailDto.fromJson(Map<String, dynamic> json) {
    final locationsList = (json['locations'] as List<dynamic>?) ?? [];
    final contactsList = (json['contacts'] as List<dynamic>?) ?? [];
    final proposalsList = (json['proposals'] as List<dynamic>?) ?? [];

    return CustomerDetailDto(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      initials: json['initials']?.toString() ?? '',
      segmentId: json['segment_id']?.toString() ?? '',
      segment: json['segment']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      npwpNumber: json['npwp_number']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      phoneAlt: json['phone_alt']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      scanCode: json['scan_code']?.toString() ?? '',
      riskNotes: json['risk_notes']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      activeProposalsCount:
          (json['active_proposals_count'] as num?)?.toInt() ?? 0,
      activeContractsCount:
          (json['active_contracts_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      locations: locationsList
          .map((e) => CustomerLocationDto.fromJson(
                (e as Map).cast<String, dynamic>(),
              ))
          .toList(),
      contacts: contactsList
          .map((e) => CustomerContactDto.fromJson(
                (e as Map).cast<String, dynamic>(),
              ))
          .toList(),
      proposals: proposalsList
          .map((e) => CustomerProposalDto.fromJson(
                (e as Map).cast<String, dynamic>(),
              ))
          .toList(),
    );
  }

  Customer toEntity() {
    return Customer(
      id: id,
      code: code,
      name: name,
      initials: initials,
      segmentId: segmentId,
      segment: segment,
      status: status,
      npwp: npwpNumber,
      phone: phone,
      phoneAlt: phoneAlt,
      email: email,
      scanCode: scanCode,
      riskNotes: riskNotes,
      notes: notes,
      activeProposalsCount: activeProposalsCount,
      activeContractsCount: activeContractsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      locations: locations.map((e) => e.toEntity()).toList(),
      contacts: contacts.map((e) => e.toEntity()).toList(),
      proposals: proposals.map((e) => e.toEntity()).toList(),
    );
  }
}

class CustomerPaginationDto {
  final int total;
  final int totalPage;
  final bool hasNext;

  const CustomerPaginationDto({
    required this.total,
    required this.totalPage,
    required this.hasNext,
  });

  factory CustomerPaginationDto.fromJson(Map<String, dynamic> json) {
    return CustomerPaginationDto(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPage: (json['total_page'] as num?)?.toInt() ?? 0,
      hasNext: json['has_next'] as bool? ?? false,
    );
  }
}

class CustomerListResponseDto {
  final List<CustomerListItemDto> items;
  final CustomerPaginationDto pagination;

  const CustomerListResponseDto({
    required this.items,
    required this.pagination,
  });

  factory CustomerListResponseDto.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?) ?? [];
    final paginationJson =
        json['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return CustomerListResponseDto(
      items: itemsList
          .map((e) => CustomerListItemDto.fromJson(
                (e as Map).cast<String, dynamic>(),
              ))
          .toList(),
      pagination: CustomerPaginationDto.fromJson(paginationJson),
    );
  }
}

class CreateCustomerLocationRequestDto {
  final String? label;
  final String? addressLine;
  final int? provinceId;
  final int? regencyId;
  final int? districtId;
  final int? villageId;
  final double? areaSize;
  final double? latitude;
  final double? longitude;

  const CreateCustomerLocationRequestDto({
    this.label,
    this.addressLine,
    this.provinceId,
    this.regencyId,
    this.districtId,
    this.villageId,
    this.areaSize,
    this.latitude,
    this.longitude,
  });

  factory CreateCustomerLocationRequestDto.fromInput(CreateLocationInput input) {
    return CreateCustomerLocationRequestDto(
      label: input.label.isNotEmpty ? input.label : null,
      addressLine: input.address.isNotEmpty ? input.address : null,
      provinceId: input.provinceId,
      regencyId: input.regencyId,
      districtId: input.districtId,
      villageId: input.villageId,
      areaSize: input.areaSize,
      latitude: input.latitude,
      longitude: input.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (label != null) map['label'] = label;
    if (addressLine != null) map['address_line'] = addressLine;
    if (provinceId != null) map['province_id'] = provinceId;
    if (regencyId != null) map['regency_id'] = regencyId;
    if (districtId != null) map['district_id'] = districtId;
    if (villageId != null) map['village_id'] = villageId;
    if (areaSize != null) map['area_size'] = areaSize;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    return map;
  }
}

class CreateCustomerContactRequestDto {
  final String name;
  final String? position;
  final String? email;
  final String? phone;
  final int role;
  final bool isPrimary;

  const CreateCustomerContactRequestDto({
    required this.name,
    this.position,
    this.email,
    this.phone,
    required this.role,
    this.isPrimary = false,
  });

  factory CreateCustomerContactRequestDto.fromInput(CreateContactInput input) {
    return CreateCustomerContactRequestDto(
      name: input.name,
      position: input.position.isNotEmpty ? input.position : null,
      email: input.email.isNotEmpty ? input.email : null,
      phone: input.phone.isNotEmpty ? input.phone : null,
      role: input.roleCode,
      isPrimary: input.isPrimary,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'role': role,
      'is_primary': isPrimary,
    };
    if (position != null) map['position'] = position;
    if (email != null) map['email'] = email;
    if (phone != null) map['phone'] = phone;
    return map;
  }
}

class CreateCustomerRequestDto {
  final String? code;
  final String name;
  final String segmentId;
  final String? npwpNumber;
  final String? email;
  final String? phone;
  final String? phoneAlt;
  final String? riskNotes;
  final String? notes;
  final List<CreateCustomerLocationRequestDto> locations;
  final List<CreateCustomerContactRequestDto> contacts;

  const CreateCustomerRequestDto({
    this.code,
    required this.name,
    required this.segmentId,
    this.npwpNumber,
    this.email,
    this.phone,
    this.phoneAlt,
    this.riskNotes,
    this.notes,
    this.locations = const [],
    this.contacts = const [],
  });

  factory CreateCustomerRequestDto.fromInput(CreateCustomerInput input) {
    return CreateCustomerRequestDto(
      code: input.code.isNotEmpty ? input.code : null,
      name: input.name,
      segmentId: input.segmentId,
      npwpNumber: input.npwp.isNotEmpty ? input.npwp : null,
      email: input.email.isNotEmpty ? input.email : null,
      phone: input.phone.isNotEmpty ? input.phone : null,
      phoneAlt: input.phoneAlt.isNotEmpty ? input.phoneAlt : null,
      riskNotes: input.riskNotes.isNotEmpty ? input.riskNotes : null,
      notes: input.notes.isNotEmpty ? input.notes : null,
      locations: input.locations
          .map((l) => CreateCustomerLocationRequestDto.fromInput(l))
          .toList(),
      contacts: input.contacts
          .where((c) => c.name.trim().isNotEmpty)
          .map((c) => CreateCustomerContactRequestDto.fromInput(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'segment_id': segmentId,
    };
    if (code != null) map['code'] = code;
    if (npwpNumber != null) map['npwp_number'] = npwpNumber;
    if (email != null) map['email'] = email;
    if (phone != null) map['phone'] = phone;
    if (phoneAlt != null) map['phone_alt'] = phoneAlt;
    if (riskNotes != null) map['risk_notes'] = riskNotes;
    if (notes != null) map['notes'] = notes;
    if (locations.isNotEmpty) {
      map['locations'] = locations.map((l) => l.toJson()).toList();
    }
    if (contacts.isNotEmpty) {
      map['contacts'] = contacts.map((c) => c.toJson()).toList();
    }
    return map;
  }
}

class CreateCustomerResponseDto {
  final String id;
  final String code;
  final String name;
  final String initials;
  final String segment;
  final String status;
  final String createdAt;

  const CreateCustomerResponseDto({
    required this.id,
    required this.code,
    required this.name,
    required this.initials,
    required this.segment,
    required this.status,
    required this.createdAt,
  });

  factory CreateCustomerResponseDto.fromJson(Map<String, dynamic> json) {
    return CreateCustomerResponseDto(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      initials: json['initials']?.toString() ?? '',
      segment: json['segment']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Customer toEntity() {
    return Customer(
      id: id,
      code: code,
      name: name,
      initials: initials,
      segment: segment,
      status: status,
      createdAt: createdAt,
    );
  }
}
