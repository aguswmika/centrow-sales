import 'package:centrow_sales/modules/sales/entities/proposal_template_option.dart';

class ProposalTemplateOptionDto {
  final String value;
  final String label;
  final bool isDefault;

  const ProposalTemplateOptionDto({
    required this.value,
    required this.label,
    required this.isDefault,
  });

  factory ProposalTemplateOptionDto.fromJson(Map<String, dynamic> json) =>
      ProposalTemplateOptionDto(
        value: json['value']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        isDefault: json['is_default'] as bool? ?? false,
      );

  ProposalTemplateOption toEntity() =>
      ProposalTemplateOption(value: value, label: label, isDefault: isDefault);
}
