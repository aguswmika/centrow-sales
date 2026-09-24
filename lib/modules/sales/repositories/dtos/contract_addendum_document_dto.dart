import 'package:centrow_sales/modules/sales/entities/contract_addendum_document.dart';

class ContractAddendumDocumentDto {
  final String? documentId;
  final String addendumId;
  final String templateId;
  final String title;
  final String source;
  final Map<String, dynamic> content;
  final String? updatedAt;

  const ContractAddendumDocumentDto({
    this.documentId,
    required this.addendumId,
    required this.templateId,
    required this.title,
    required this.source,
    required this.content,
    this.updatedAt,
  });

  factory ContractAddendumDocumentDto.fromJson(Map<String, dynamic> json) {
    return ContractAddendumDocumentDto(
      documentId: json['document_id'] as String?,
      addendumId: json['addendum_id']?.toString() ?? '',
      templateId: json['template_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      content: (json['content'] is Map)
          ? (json['content'] as Map).cast<String, dynamic>()
          : <String, dynamic>{},
      updatedAt: json['updated_at'] as String?,
    );
  }

  ContractAddendumDocument toEntity() {
    return ContractAddendumDocument(
      documentId: documentId,
      addendumId: addendumId,
      templateId: templateId,
      title: title,
      source: source,
      content: content,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'addendum_id': addendumId,
      'template_id': templateId,
      'title': title,
      'source': source,
      'content': content,
      'updated_at': updatedAt,
    };
  }
}
