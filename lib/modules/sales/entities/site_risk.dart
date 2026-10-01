class SiteRiskMaster {
  final String id;
  final String name;

  const SiteRiskMaster({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SiteRiskMaster &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'SiteRiskMaster(id: $id, name: $name)';
}

class CustomerAddressRisk {
  final String id;
  final String? siteRiskId;
  final String name;
  final bool isCustom;

  const CustomerAddressRisk({
    required this.id,
    this.siteRiskId,
    required this.name,
    this.isCustom = false,
  });

  CustomerAddressRisk copyWith({
    String? id,
    String? siteRiskId,
    String? name,
    bool? isCustom,
  }) {
    return CustomerAddressRisk(
      id: id ?? this.id,
      siteRiskId: siteRiskId ?? this.siteRiskId,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAddressRisk &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          siteRiskId == other.siteRiskId &&
          name == other.name &&
          isCustom == other.isCustom;

  @override
  int get hashCode => Object.hash(id, siteRiskId, name, isCustom);

  @override
  String toString() =>
      'CustomerAddressRisk(id: $id, siteRiskId: $siteRiskId, name: $name, isCustom: $isCustom)';
}
