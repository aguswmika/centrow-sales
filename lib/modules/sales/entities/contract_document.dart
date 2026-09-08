import 'package:centrow_sales/modules/sales/entities/document_placeholder.dart';
export 'package:centrow_sales/modules/sales/entities/document_placeholder.dart';

typedef ContractPlaceholder = DocumentPlaceholder;

class ContractDocument {
  final String? documentId;
  final String contractId;
  final String? templateId;
  final String title;
  final String source;
  final Map<String, dynamic> content;
  final int theme;
  final List<ContractPlaceholder> placeholders;
  final DateTime? updatedAt;

  const ContractDocument({
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
}
