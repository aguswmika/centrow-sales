enum CustomerContactRole {
  pic(1, 'pic', 'PIC', 'brand'),
  picBackup(2, 'pic_backup', 'PIC Cadangan', 'neutral'),
  accounting(3, 'accounting', 'Accounting', 'ok'),
  signatory(4, 'signatory', 'Penandatangan', 'info');

  final int code;
  final String value;
  final String displayName;
  final String badgeType;

  const CustomerContactRole(
    this.code,
    this.value,
    this.displayName,
    this.badgeType,
  );

  static CustomerContactRole fromCode(int code) {
    return CustomerContactRole.values.firstWhere(
      (e) => e.code == code,
      orElse: () => CustomerContactRole.pic,
    );
  }

  static CustomerContactRole fromString(String val) {
    final lower = val.toLowerCase().trim();
    for (final role in CustomerContactRole.values) {
      if (role.value == lower ||
          role.name.toLowerCase() == lower ||
          role.displayName.toLowerCase() == lower) {
        return role;
      }
    }
    return CustomerContactRole.pic;
  }
}

class CustomerLocation {
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

  const CustomerLocation({
    this.id,
    this.customerId,
    this.isPrimary = false,
    this.label = '',
    this.addressLine = '',
    this.village = '',
    this.district = '',
    this.regency = '',
    this.province = '',
    this.areaSize,
    this.latitude,
    this.longitude,
  });

  String get address => addressLine;

  String get area {
    if (areaSize != null && areaSize! > 0) {
      final formatted = areaSize! % 1 == 0
          ? areaSize!.toInt().toString()
          : areaSize!.toString();
      return '$formatted m²';
    }
    return '';
  }

  String get coords {
    if (latitude != null && longitude != null) {
      return '$latitude, $longitude';
    }
    return '';
  }

  CustomerLocation copyWith({
    String? id,
    String? customerId,
    bool? isPrimary,
    String? label,
    String? addressLine,
    String? village,
    String? district,
    String? regency,
    String? province,
    double? areaSize,
    double? latitude,
    double? longitude,
  }) {
    return CustomerLocation(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      isPrimary: isPrimary ?? this.isPrimary,
      label: label ?? this.label,
      addressLine: addressLine ?? this.addressLine,
      village: village ?? this.village,
      district: district ?? this.district,
      regency: regency ?? this.regency,
      province: province ?? this.province,
      areaSize: areaSize ?? this.areaSize,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerLocation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          isPrimary == other.isPrimary &&
          label == other.label &&
          addressLine == other.addressLine &&
          village == other.village &&
          district == other.district &&
          regency == other.regency &&
          province == other.province &&
          areaSize == other.areaSize &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    isPrimary,
    label,
    addressLine,
    village,
    district,
    regency,
    province,
    areaSize,
    latitude,
    longitude,
  );

  @override
  String toString() =>
      'CustomerLocation(id: $id, label: $label, isPrimary: $isPrimary, address: $addressLine)';
}

class CustomerContact {
  final String? id;
  final String? customerId;
  final String name;
  final String position;
  final String email;
  final String phone;
  final String role;
  final bool isPrimary;

  const CustomerContact({
    this.id,
    this.customerId,
    required this.name,
    this.position = '',
    this.email = '',
    this.phone = '',
    required this.role,
    this.isPrimary = false,
  });

  String get initials {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'CP';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  CustomerContactRole get contactRole => CustomerContactRole.fromString(role);
  String get roleBadge => contactRole.badgeType;
  String get displayRole => contactRole.displayName;

  CustomerContact copyWith({
    String? id,
    String? customerId,
    String? name,
    String? position,
    String? email,
    String? phone,
    String? role,
    bool? isPrimary,
  }) {
    return CustomerContact(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      position: position ?? this.position,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerContact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          name == other.name &&
          position == other.position &&
          email == other.email &&
          phone == other.phone &&
          role == other.role &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    name,
    position,
    email,
    phone,
    role,
    isPrimary,
  );

  @override
  String toString() =>
      'CustomerContact(id: $id, name: $name, position: $position, email: $email, role: $role)';
}

class CustomerProposalSummary {
  final String id;
  final String customerId;
  final String code;
  final String serviceId;
  final String serviceName;
  final String proposalDate;
  final String? validUntil;
  final double totalAmount;
  final String status;

  const CustomerProposalSummary({
    this.id = '',
    this.customerId = '',
    required this.code,
    this.serviceId = '',
    this.serviceName = '',
    this.proposalDate = '',
    this.validUntil,
    this.totalAmount = 0.0,
    required this.status,
  });

  String get title => serviceName.isNotEmpty
      ? serviceName
      : (code.isNotEmpty ? 'Proposal $code' : '');

  String get date => proposalDate;

  String get amount {
    if (totalAmount <= 0) return 'Rp 0';
    final formatted = totalAmount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  String get badgeType => switch (status.toLowerCase()) {
    'accepted' || 'disetujui' => 'ok',
    'sent' || 'dikirim' => 'info',
    'negotiation' || 'negosiasi' => 'warn',
    'rejected' ||
    'ditolak' ||
    'cancelled' ||
    'dibatalkan' ||
    'expired' ||
    'kadaluarsa' => 'err',
    'draft' => 'neutral',
    _ => 'neutral',
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerProposalSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          code == other.code &&
          serviceId == other.serviceId &&
          serviceName == other.serviceName &&
          proposalDate == other.proposalDate &&
          validUntil == other.validUntil &&
          totalAmount == other.totalAmount &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    code,
    serviceId,
    serviceName,
    proposalDate,
    validUntil,
    totalAmount,
    status,
  );

  @override
  String toString() =>
      'CustomerProposalSummary(id: $id, code: $code, serviceName: $serviceName, status: $status)';
}

class Customer {
  final String id;
  final String code;
  final String name;
  final String initials;
  final String segmentId;
  final String segment;
  final String status;
  final String npwp;
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
  final List<CustomerLocation> locations;
  final List<CustomerContact> contacts;
  final List<CustomerProposalSummary> proposals;
  final String? explicitRegency;

  const Customer({
    required this.id,
    required this.code,
    required this.name,
    required this.initials,
    this.segmentId = '',
    required this.segment,
    required this.status,
    String? regency,
    this.npwp = '',
    this.phone = '',
    this.phoneAlt = '',
    this.email = '',
    this.scanCode = '',
    this.riskNotes = '',
    this.notes = '',
    this.activeProposalsCount = 0,
    this.activeContractsCount = 0,
    this.createdAt = '',
    this.updatedAt = '',
    this.locations = const [],
    this.contacts = const [],
    this.proposals = const [],
  }) : explicitRegency = regency;

  String get regency {
    final exp = explicitRegency;
    if (exp != null && exp.isNotEmpty) return exp;
    if (locations.isNotEmpty) {
      final primary = locations.firstWhere(
        (l) => l.isPrimary,
        orElse: () => locations.first,
      );
      return primary.regency;
    }
    return '';
  }

  Customer copyWith({
    String? id,
    String? code,
    String? name,
    String? initials,
    String? segmentId,
    String? segment,
    String? status,
    String? regency,
    String? npwp,
    String? phone,
    String? phoneAlt,
    String? email,
    String? scanCode,
    String? riskNotes,
    String? notes,
    int? activeProposalsCount,
    int? activeContractsCount,
    String? createdAt,
    String? updatedAt,
    List<CustomerLocation>? locations,
    List<CustomerContact>? contacts,
    List<CustomerProposalSummary>? proposals,
  }) {
    return Customer(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      segmentId: segmentId ?? this.segmentId,
      segment: segment ?? this.segment,
      status: status ?? this.status,
      regency: regency ?? explicitRegency,
      npwp: npwp ?? this.npwp,
      phone: phone ?? this.phone,
      phoneAlt: phoneAlt ?? this.phoneAlt,
      email: email ?? this.email,
      scanCode: scanCode ?? this.scanCode,
      riskNotes: riskNotes ?? this.riskNotes,
      notes: notes ?? this.notes,
      activeProposalsCount: activeProposalsCount ?? this.activeProposalsCount,
      activeContractsCount: activeContractsCount ?? this.activeContractsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      locations: locations ?? this.locations,
      contacts: contacts ?? this.contacts,
      proposals: proposals ?? this.proposals,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          name == other.name &&
          initials == other.initials &&
          segmentId == other.segmentId &&
          segment == other.segment &&
          status == other.status &&
          npwp == other.npwp &&
          phone == other.phone &&
          phoneAlt == other.phoneAlt &&
          email == other.email &&
          scanCode == other.scanCode &&
          riskNotes == other.riskNotes &&
          notes == other.notes &&
          activeProposalsCount == other.activeProposalsCount &&
          activeContractsCount == other.activeContractsCount &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    initials,
    segmentId,
    segment,
    status,
    npwp,
    phone,
    phoneAlt,
    email,
    scanCode,
    riskNotes,
    notes,
    activeProposalsCount,
    activeContractsCount,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Customer(id: $id, code: $code, name: $name, segment: $segment)';
}
