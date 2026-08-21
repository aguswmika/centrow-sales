import 'package:centrow_sales/modules/core/entities/tenant.dart';

class TenantDto {
  final String id;
  final String name;
  final String slug;

  TenantDto({required this.id, required this.name, required this.slug});

  factory TenantDto.fromJson(Map<String, dynamic> json) {
    return TenantDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }

  Tenant toEntity() {
    return Tenant(id: id, name: name, slug: slug);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}
