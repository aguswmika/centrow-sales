import 'package:centrow_sales/modules/sales/entities/contract_category.dart';
import 'package:centrow_sales/modules/sales/entities/contract_template_option.dart';

class ContractTemplateOptionDto {
  final String id;
  final String label;
  final bool isDefault;

  const ContractTemplateOptionDto({
    required this.id,
    required this.label,
    required this.isDefault,
  });

  factory ContractTemplateOptionDto.fromJson(Map<String, dynamic> json) =>
      ContractTemplateOptionDto(
        id: json['id']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        isDefault: json['is_default'] as bool? ?? false,
      );

  ContractTemplateOption toEntity() =>
      ContractTemplateOption(id: id, label: label, isDefault: isDefault);
}

class ContractCategoryDto {
  final String id;
  final String name;
  final String? createdAt;
  final List<ContractTemplateOptionDto> templates;

  const ContractCategoryDto({
    required this.id,
    required this.name,
    this.createdAt,
    this.templates = const [],
  });

  factory ContractCategoryDto.fromJson(Map<String, dynamic> json) =>
      ContractCategoryDto(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        createdAt: json['created_at']?.toString(),
        templates:
            (json['templates'] as List?)
                ?.map(
                  (t) => ContractTemplateOptionDto.fromJson(
                    (t as Map).cast<String, dynamic>(),
                  ),
                )
                .toList() ??
            const [],
      );

  ContractCategory toEntity() => ContractCategory(
    id: id,
    name: name,
    createdAt: createdAt,
    templates: templates.map((t) => t.toEntity()).toList(),
  );
}
