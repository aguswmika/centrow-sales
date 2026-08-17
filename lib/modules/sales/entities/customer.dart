class CustomerLocation {
  final bool isPrimary;
  final String label;
  final String address;
  final String area;
  final String district;
  final String coords;

  const CustomerLocation({
    required this.isPrimary,
    required this.label,
    required this.address,
    required this.area,
    required this.district,
    required this.coords,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerLocation &&
          runtimeType == other.runtimeType &&
          isPrimary == other.isPrimary &&
          label == other.label &&
          address == other.address &&
          area == other.area &&
          district == other.district &&
          coords == other.coords;

  @override
  int get hashCode =>
      Object.hash(isPrimary, label, address, area, district, coords);

  @override
  String toString() =>
      'CustomerLocation(label: $label, isPrimary: $isPrimary, address: $address)';
}

class CustomerContact {
  final String name;
  final String initials;
  final String position;
  final String email;
  final String phone;
  final String role;
  final String roleBadge;

  const CustomerContact({
    required this.name,
    required this.initials,
    required this.position,
    required this.email,
    required this.phone,
    required this.role,
    required this.roleBadge,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerContact &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          initials == other.initials &&
          position == other.position &&
          email == other.email &&
          phone == other.phone &&
          role == other.role &&
          roleBadge == other.roleBadge;

  @override
  int get hashCode =>
      Object.hash(name, initials, position, email, phone, role, roleBadge);

  @override
  String toString() =>
      'CustomerContact(name: $name, position: $position, email: $email)';
}

class CustomerProposalSummary {
  final String title;
  final String code;
  final String date;
  final String amount;
  final String status;
  final String badgeType;

  const CustomerProposalSummary({
    required this.title,
    required this.code,
    required this.date,
    required this.amount,
    required this.status,
    required this.badgeType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerProposalSummary &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          code == other.code &&
          date == other.date &&
          amount == other.amount &&
          status == other.status &&
          badgeType == other.badgeType;

  @override
  int get hashCode => Object.hash(title, code, date, amount, status, badgeType);

  @override
  String toString() =>
      'CustomerProposalSummary(code: $code, title: $title, status: $status)';
}

class Customer {
  final String id;
  final String code;
  final String name;
  final String initials;
  final String segment;
  final String status;
  final String regency;
  final String npwp;
  final String phone;
  final String phoneAlt;
  final String email;
  final String scanCode;
  final String riskNotes;
  final String notes;
  final List<CustomerLocation> locations;
  final List<CustomerContact> contacts;
  final List<CustomerProposalSummary> proposals;

  const Customer({
    required this.id,
    required this.code,
    required this.name,
    required this.initials,
    required this.segment,
    required this.status,
    required this.regency,
    required this.npwp,
    required this.phone,
    required this.phoneAlt,
    required this.email,
    required this.scanCode,
    required this.riskNotes,
    required this.notes,
    required this.locations,
    required this.contacts,
    required this.proposals,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          name == other.name &&
          segment == other.segment &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, code, name, segment, status);

  @override
  String toString() => 'Customer(id: $id, code: $code, name: $name)';
}
