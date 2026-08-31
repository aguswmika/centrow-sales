class ProposalPlaceholder {
  final String tag;
  final String label;

  const ProposalPlaceholder({required this.tag, required this.label});
}

class ProposalDocument {
  final String? documentId;
  final String proposalId;
  final String? templateId;
  final String title;
  final String source;
  final Map<String, dynamic> content;
  final List<ProposalPlaceholder> placeholders;
  final DateTime? updatedAt;

  const ProposalDocument({
    this.documentId,
    required this.proposalId,
    this.templateId,
    required this.title,
    required this.source,
    required this.content,
    required this.placeholders,
    this.updatedAt,
  });
}
