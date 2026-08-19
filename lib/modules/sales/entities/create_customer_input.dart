import 'customer.dart';

class CreateLocationInput {
  final String label;
  final String address;
  final int? provinceId;
  final int? regencyId;
  final int? districtId;
  final int? villageId;
  final String province;
  final String regency;
  final String district;
  final String village;
  final double? areaSize;
  final String areaUnit;
  final String coords;
  final double? latitude;
  final double? longitude;
  final bool isPrimary;

  const CreateLocationInput({
    this.label = '',
    this.address = '',
    this.provinceId,
    this.regencyId,
    this.districtId,
    this.villageId,
    this.province = '',
    this.regency = '',
    this.district = '',
    this.village = '',
    this.areaSize,
    this.areaUnit = 'm²',
    this.coords = '',
    this.latitude,
    this.longitude,
    this.isPrimary = false,
  });

  CreateLocationInput copyWith({
    String? label,
    String? address,
    int? provinceId,
    int? regencyId,
    int? districtId,
    int? villageId,
    String? province,
    String? regency,
    String? district,
    String? village,
    double? areaSize,
    String? areaUnit,
    String? coords,
    double? latitude,
    double? longitude,
    bool? isPrimary,
  }) {
    return CreateLocationInput(
      label: label ?? this.label,
      address: address ?? this.address,
      provinceId: provinceId ?? this.provinceId,
      regencyId: regencyId ?? this.regencyId,
      districtId: districtId ?? this.districtId,
      villageId: villageId ?? this.villageId,
      province: province ?? this.province,
      regency: regency ?? this.regency,
      district: district ?? this.district,
      village: village ?? this.village,
      areaSize: areaSize ?? this.areaSize,
      areaUnit: areaUnit ?? this.areaUnit,
      coords: coords ?? this.coords,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'address_line': address,
        if (provinceId != null) 'province_id': provinceId,
        if (regencyId != null) 'regency_id': regencyId,
        if (districtId != null) 'district_id': districtId,
        if (villageId != null) 'village_id': villageId,
        if (province.isNotEmpty) 'province': province,
        if (regency.isNotEmpty) 'regency': regency,
        if (district.isNotEmpty) 'district': district,
        if (village.isNotEmpty) 'village': village,
        'area_size': areaSize,
        'area_unit': areaUnit,
        'coords': coords,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'is_primary': isPrimary,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateLocationInput &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          address == other.address &&
          provinceId == other.provinceId &&
          regencyId == other.regencyId &&
          districtId == other.districtId &&
          villageId == other.villageId &&
          province == other.province &&
          regency == other.regency &&
          district == other.district &&
          village == other.village &&
          areaSize == other.areaSize &&
          areaUnit == other.areaUnit &&
          coords == other.coords &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode => Object.hash(
        label,
        address,
        provinceId,
        regencyId,
        districtId,
        villageId,
        province,
        regency,
        district,
        village,
        areaSize,
        areaUnit,
        coords,
        latitude,
        longitude,
        isPrimary,
      );

  @override
  String toString() =>
      'CreateLocationInput(label: $label, isPrimary: $isPrimary)';
}

class CreateContactInput {
  final String name;
  final String position;
  final String email;
  final String phone;
  final String role;
  final String roleBadge;
  final bool isPrimary;
  final int? explicitRoleCode;

  const CreateContactInput({
    this.name = '',
    this.position = '',
    this.email = '',
    this.phone = '',
    this.role = 'Pengambil Keputusan',
    this.roleBadge = 'brand',
    this.isPrimary = false,
    int? roleCode,
  }) : explicitRoleCode = roleCode;

  CustomerContactRole get contactRole => CustomerContactRole.fromString(role);

  int get roleCode => explicitRoleCode ?? contactRole.code;

  CreateContactInput copyWith({
    String? name,
    String? position,
    String? email,
    String? phone,
    String? role,
    String? roleBadge,
    bool? isPrimary,
    int? roleCode,
  }) {
    return CreateContactInput(
      name: name ?? this.name,
      position: position ?? this.position,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      roleBadge: roleBadge ?? this.roleBadge,
      isPrimary: isPrimary ?? this.isPrimary,
      roleCode: roleCode ?? explicitRoleCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'position': position,
        'email': email,
        'phone': phone,
        'role': roleCode,
        'role_badge': roleBadge,
        'is_primary': isPrimary,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateContactInput &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          position == other.position &&
          email == other.email &&
          phone == other.phone &&
          role == other.role &&
          roleBadge == other.roleBadge &&
          isPrimary == other.isPrimary &&
          roleCode == other.roleCode;

  @override
  int get hashCode => Object.hash(
        name,
        position,
        email,
        phone,
        role,
        roleBadge,
        isPrimary,
        roleCode,
      );

  @override
  String toString() => 'CreateContactInput(name: $name, email: $email, role: $role)';
}

class CreateCustomerInput {
  final String name;
  final String code;
  final String segmentId;
  final String segment;
  final String regency;
  final String status;
  final String scanCode;
  final String npwp;
  final String phone;
  final String phoneAlt;
  final String email;
  final String riskNotes;
  final String notes;
  final List<CreateLocationInput> locations;
  final List<CreateContactInput> contacts;

  const CreateCustomerInput({
    this.name = '',
    this.code = '',
    this.segmentId = '',
    this.segment = '',
    this.regency = '',
    this.status = 'Aktif',
    this.scanCode = '',
    this.npwp = '',
    this.phone = '',
    this.phoneAlt = '',
    this.email = '',
    this.riskNotes = '',
    this.notes = '',
    this.locations = const [],
    this.contacts = const [],
  });

  CreateCustomerInput copyWith({
    String? name,
    String? code,
    String? segmentId,
    String? segment,
    String? regency,
    String? status,
    String? scanCode,
    String? npwp,
    String? phone,
    String? phoneAlt,
    String? email,
    String? riskNotes,
    String? notes,
    List<CreateLocationInput>? locations,
    List<CreateContactInput>? contacts,
  }) {
    return CreateCustomerInput(
      name: name ?? this.name,
      code: code ?? this.code,
      segmentId: segmentId ?? this.segmentId,
      segment: segment ?? this.segment,
      regency: regency ?? this.regency,
      status: status ?? this.status,
      scanCode: scanCode ?? this.scanCode,
      npwp: npwp ?? this.npwp,
      phone: phone ?? this.phone,
      phoneAlt: phoneAlt ?? this.phoneAlt,
      email: email ?? this.email,
      riskNotes: riskNotes ?? this.riskNotes,
      notes: notes ?? this.notes,
      locations: locations ?? this.locations,
      contacts: contacts ?? this.contacts,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'segment_id': segmentId,
        'segment': segment,
        'regency': regency,
        'status': status,
        'scan_code': scanCode,
        'npwp_number': npwp,
        'phone': phone,
        'phone_alt': phoneAlt,
        'email': email,
        'risk_notes': riskNotes,
        'notes': notes,
        'locations': locations.map((l) => l.toJson()).toList(),
        'contacts': contacts.map((c) => c.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateCustomerInput &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          code == other.code &&
          segmentId == other.segmentId &&
          segment == other.segment &&
          regency == other.regency &&
          status == other.status &&
          scanCode == other.scanCode &&
          npwp == other.npwp &&
          phone == other.phone &&
          phoneAlt == other.phoneAlt &&
          email == other.email &&
          riskNotes == other.riskNotes &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
        name,
        code,
        segmentId,
        segment,
        regency,
        status,
        scanCode,
        npwp,
        phone,
        phoneAlt,
        email,
        riskNotes,
        notes,
      );

  @override
  String toString() => 'CreateCustomerInput(name: $name, code: $code)';
}
