import 'package:centrow_sales/modules/sales/entities/contract_category.dart';

class ContractCategoryDto {
  final String id;
  final String name;
  final String? contractTemplateId;
  final String? createdAt;

  const ContractCategoryDto({
    required this.id,
    required this.name,
    this.contractTemplateId,
    this.createdAt,
  });

  factory ContractCategoryDto.fromJson(Map<String, dynamic> json) =>
      ContractCategoryDto(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        contractTemplateId: json['contract_template_id']?.toString(),
        createdAt: json['created_at']?.toString(),
      );

  ContractCategory toEntity() => ContractCategory(
    id: id,
    name: name,
    contractTemplateId: contractTemplateId,
    createdAt: createdAt,
  );
}
