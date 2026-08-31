import 'package:centrow_sales/modules/sales/entities/proposal_document.dart';

class ProposalPlaceholderDto {
  final String tag;
  final String label;

  const ProposalPlaceholderDto({required this.tag, required this.label});

  factory ProposalPlaceholderDto.fromJson(Map<String, dynamic> json) {
    return ProposalPlaceholderDto(
      tag: json['tag']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  ProposalPlaceholder toEntity() {
    return ProposalPlaceholder(tag: tag, label: label);
  }
}

class ProposalDocumentDto {
  final String? documentId;
  final String proposalId;
  final String? templateId;
  final String title;
  final String source;
  final Map<String, dynamic> content;
  final List<ProposalPlaceholderDto> placeholders;
  final String? updatedAt;

  const ProposalDocumentDto({
    this.documentId,
    required this.proposalId,
    this.templateId,
    required this.title,
    required this.source,
    required this.content,
    required this.placeholders,
    this.updatedAt,
  });

  factory ProposalDocumentDto.fromJson(Map<String, dynamic> json) {
    final placeholdersList =
        (json['placeholders'] as List?)
            ?.cast<Map<String, dynamic>>()
            .map(ProposalPlaceholderDto.fromJson)
            .toList() ??
        [];

    return ProposalDocumentDto(
      documentId: json['document_id'] as String?,
      proposalId: json['proposal_id']?.toString() ?? '',
      templateId: json['template_id'] as String?,
      title: json['title']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      content: (json['content'] is Map)
          ? (json['content'] as Map).cast<String, dynamic>()
          : <String, dynamic>{},
      placeholders: placeholdersList,
      updatedAt: json['updated_at'] as String?,
    );
  }

  ProposalDocument toEntity() {
    return ProposalDocument(
      documentId: documentId,
      proposalId: proposalId,
      templateId: templateId,
      title: title,
      source: source,
      content: content,
      placeholders: placeholders.map((e) => e.toEntity()).toList(),
      updatedAt: updatedAt != null
          ? DateTime.tryParse(updatedAt!)?.toLocal()
          : null,
    );
  }
}
