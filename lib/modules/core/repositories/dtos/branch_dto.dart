import 'package:centrow_sales/modules/core/entities/branch.dart';

class BranchDto {
  final String id;
  final String name;
  final String slug;

  BranchDto({required this.id, required this.name, required this.slug});

  factory BranchDto.fromJson(Map<String, dynamic> json) {
    return BranchDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }

  Branch toEntity() {
    return Branch(id: id, name: name, slug: slug);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}
