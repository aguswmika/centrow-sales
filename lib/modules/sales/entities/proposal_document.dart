import 'package:centrow_sales/modules/sales/entities/document_placeholder.dart';
export 'package:centrow_sales/modules/sales/entities/document_placeholder.dart';

typedef ProposalPlaceholder = DocumentPlaceholder;

class ProposalDocument {
  final String? documentId;
  final String proposalId;
  final String? templateId;
  final String title;
  final String source;
  final Map<String, dynamic> content;
  final int theme;
  final List<ProposalPlaceholder> placeholders;
  final DateTime? updatedAt;

  const ProposalDocument({
    this.documentId,
    required this.proposalId,
    this.templateId,
    required this.title,
    required this.source,
    required this.content,
    this.theme = 1,
    required this.placeholders,
    this.updatedAt,
  });
}
