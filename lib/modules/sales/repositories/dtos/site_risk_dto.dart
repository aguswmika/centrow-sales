import 'package:centrow_sales/modules/sales/entities/site_risk.dart';

class SiteRiskMasterDto {
  final String id;
  final String name;

  const SiteRiskMasterDto({required this.id, required this.name});

  factory SiteRiskMasterDto.fromJson(Map<String, dynamic> json) {
    return SiteRiskMasterDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  SiteRiskMaster toEntity() {
    return SiteRiskMaster(id: id, name: name);
  }
}

class SiteRiskMasterListResponseDto {
  final List<SiteRiskMasterDto> items;

  const SiteRiskMasterListResponseDto({required this.items});

  factory SiteRiskMasterListResponseDto.fromJson(Map<String, dynamic> json) {
    final dynamic rawItems;
    if (json['data'] is Map && (json['data'] as Map)['items'] is List) {
      rawItems = (json['data'] as Map)['items'];
    } else if (json['data'] is List) {
      rawItems = json['data'];
    } else if (json['items'] is List) {
      rawItems = json['items'];
    } else {
      rawItems = <dynamic>[];
    }

    final list = rawItems as List<dynamic>;
    return SiteRiskMasterListResponseDto(
      items: list
          .map(
            (e) =>
                SiteRiskMasterDto.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
    );
  }
}

class CustomerAddressRiskDto {
  final String id;
  final String? siteRiskId;
  final String name;
  final bool isCustom;

  const CustomerAddressRiskDto({
    required this.id,
    this.siteRiskId,
    required this.name,
    required this.isCustom,
  });

  factory CustomerAddressRiskDto.fromJson(Map<String, dynamic> json) {
    return CustomerAddressRiskDto(
      id: json['id']?.toString() ?? '',
      siteRiskId: json['site_risk_id']?.toString(),
      name: json['name']?.toString() ?? '',
      isCustom: json['is_custom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'site_risk_id': siteRiskId,
    'name': name,
    'is_custom': isCustom,
  };

  CustomerAddressRisk toEntity() {
    return CustomerAddressRisk(
      id: id,
      siteRiskId: siteRiskId,
      name: name,
      isCustom: isCustom,
    );
  }
}

class CustomerAddressRiskListResponseDto {
  final List<CustomerAddressRiskDto> items;

  const CustomerAddressRiskListResponseDto({required this.items});

  factory CustomerAddressRiskListResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic rawItems;
    if (json['data'] is Map && (json['data'] as Map)['items'] is List) {
      rawItems = (json['data'] as Map)['items'];
    } else if (json['data'] is List) {
      rawItems = json['data'];
    } else if (json['items'] is List) {
      rawItems = json['items'];
    } else {
      rawItems = <dynamic>[];
    }

    final list = rawItems as List<dynamic>;
    return CustomerAddressRiskListResponseDto(
      items: list
          .map(
            (e) => CustomerAddressRiskDto.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
    );
  }
}

class UpdateAddressRisksPayload {
  final List<String> siteRiskIds;
  final List<String> customRisks;

  const UpdateAddressRisksPayload({
    required this.siteRiskIds,
    required this.customRisks,
  });

  Map<String, dynamic> toJson() => {
    'site_risk_ids': siteRiskIds,
    'custom_risks': customRisks,
  };
}
