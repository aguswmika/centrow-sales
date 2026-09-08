import 'package:centrow_sales/modules/sales/entities/contract_document.dart';

class ContractPlaceholderDto {
  final String tag;
  final String label;

  const ContractPlaceholderDto({required this.tag, required this.label});

  factory ContractPlaceholderDto.fromJson(Map<String, dynamic> json) {
    return ContractPlaceholderDto(
      tag: json['tag']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  ContractPlaceholder toEntity() {
    return ContractPlaceholder(tag: tag, label: label);
  }
}

class ContractDocumentDto {
  final String? documentId;
  final String contractId;
  final String? templateId;
  final String title;
  final String source;
  final Map<String, dynamic> content;
  final int theme;
  final List<ContractPlaceholderDto> placeholders;
  final String? updatedAt;

  const ContractDocumentDto({
    this.documentId,
    required this.contractId,
    this.templateId,
    required this.title,
    required this.source,
    required this.content,
    this.theme = 1,
    required this.placeholders,
    this.updatedAt,
  });

  factory ContractDocumentDto.fromJson(Map<String, dynamic> json) {
    final placeholdersList =
        (json['placeholders'] as List?)
            ?.cast<Map<String, dynamic>>()
            .map(ContractPlaceholderDto.fromJson)
            .toList() ??
        [];

    return ContractDocumentDto(
      documentId: json['document_id'] as String?,
      contractId: json['contract_id']?.toString() ?? '',
      templateId: json['template_id'] as String?,
      title: json['title']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      content: (json['content'] is Map)
          ? (json['content'] as Map).cast<String, dynamic>()
          : <String, dynamic>{},
      theme: (json['theme'] as num?)?.toInt() ?? 1,
      placeholders: placeholdersList,
      updatedAt: json['updated_at'] as String?,
    );
  }

  ContractDocument toEntity() {
    return ContractDocument(
      documentId: documentId,
      contractId: contractId,
      templateId: templateId,
      title: title,
      source: source,
      content: content,
      theme: theme,
      placeholders: placeholders.map((e) => e.toEntity()).toList(),
      updatedAt: updatedAt != null
          ? DateTime.tryParse(updatedAt!)?.toLocal()
          : null,
    );
  }
}
