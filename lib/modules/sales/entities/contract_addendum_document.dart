class ContractAddendumDocument {
  final String? documentId;
  final String addendumId;
  final String templateId;
  final String title;
  final String source; // "template" or "document"
  final Map<String, dynamic> content;
  final String? updatedAt;

  const ContractAddendumDocument({
    this.documentId,
    required this.addendumId,
    required this.templateId,
    required this.title,
    required this.source,
    required this.content,
    this.updatedAt,
  });

  bool get isSaved => source == 'document' || documentId != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractAddendumDocument &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId &&
          addendumId == other.addendumId &&
          templateId == other.templateId &&
          title == other.title &&
          source == other.source &&
          _deepEquals(content, other.content) &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    documentId,
    addendumId,
    templateId,
    title,
    source,
    updatedAt,
  );

  @override
  String toString() =>
      'ContractAddendumDocument(documentId: $documentId, addendumId: $addendumId, templateId: $templateId, title: $title, source: $source, updatedAt: $updatedAt)';
}

bool _deepEquals(dynamic a, dynamic b) {
  if (identical(a, b)) return true;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}
