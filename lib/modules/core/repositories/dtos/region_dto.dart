import 'package:centrow_sales/modules/core/entities/region.dart';

class RegionItemDto {
  final int id;
  final String name;

  const RegionItemDto({
    required this.id,
    required this.name,
  });

  factory RegionItemDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final int parsedId;
    if (rawId is num) {
      parsedId = rawId.toInt();
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId) ?? 0;
    } else {
      parsedId = 0;
    }

    return RegionItemDto(
      id: parsedId,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  Province toProvince() => Province(id: id, name: name);
  Regency toRegency() => Regency(id: id, name: name);
  District toDistrict() => District(id: id, name: name);
  Village toVillage() => Village(id: id, name: name);
}

class RegionListResponseDto {
  final List<RegionItemDto> data;

  const RegionListResponseDto({
    required this.data,
  });

  factory RegionListResponseDto.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    final List<dynamic> list;
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      final nested = rawData['items'] ?? rawData['data'];
      if (nested is List) {
        list = nested;
      } else {
        list = [rawData];
      }
    } else {
      list = [];
    }

    return RegionListResponseDto(
      data: list
          .map((item) => RegionItemDto.fromJson(
                (item as Map).cast<String, dynamic>(),
              ))
          .toList(),
    );
  }

  factory RegionListResponseDto.fromList(List<dynamic> list) {
    return RegionListResponseDto(
      data: list
          .map((item) => RegionItemDto.fromJson(
                (item as Map).cast<String, dynamic>(),
              ))
          .toList(),
    );
  }

  List<Province> toProvinces() => data.map((e) => e.toProvince()).toList();
  List<Regency> toRegencies() => data.map((e) => e.toRegency()).toList();
  List<District> toDistricts() => data.map((e) => e.toDistrict()).toList();
  List<Village> toVillages() => data.map((e) => e.toVillage()).toList();
}

typedef RegionDto = RegionItemDto;
typedef ProvinceDto = RegionItemDto;
typedef RegencyDto = RegionItemDto;
typedef DistrictDto = RegionItemDto;
typedef VillageDto = RegionItemDto;
