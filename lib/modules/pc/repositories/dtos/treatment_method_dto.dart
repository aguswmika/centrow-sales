import 'package:centrow_sales/modules/pc/entities/treatment_method.dart';

class TreatmentMethodDto {
  final String id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;

  const TreatmentMethodDto({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.isActive = true,
  });

  factory TreatmentMethodDto.fromJson(Map<String, dynamic> json) {
    return TreatmentMethodDto(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: (json['description'] ?? json['desc'])?.toString(),
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
    );
  }

  TreatmentMethod toEntity() {
    return TreatmentMethod(
      id: id,
      code: code,
      name: name,
      description: description,
      isActive: isActive,
    );
  }
}
