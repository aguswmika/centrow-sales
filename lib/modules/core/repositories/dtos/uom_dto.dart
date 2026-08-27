import 'package:centrow_sales/modules/core/entities/uom.dart';

class UomDto {
  final String id;
  final String code;
  final String name;

  const UomDto({required this.id, required this.code, required this.name});

  factory UomDto.fromJson(Map<String, dynamic> json) {
    return UomDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Uom toEntity() {
    return Uom(id: id, code: code, name: name);
  }
}
