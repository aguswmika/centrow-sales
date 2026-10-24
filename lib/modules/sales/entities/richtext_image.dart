class RichtextImage {
  final String id;
  final String url;
  final String originalName;
  final String mimeType;
  final int fileSize;
  final String createdAt;

  const RichtextImage({
    required this.id,
    required this.url,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RichtextImage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url &&
          originalName == other.originalName &&
          mimeType == other.mimeType &&
          fileSize == other.fileSize &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, url, originalName, mimeType, fileSize, createdAt);

  @override
  String toString() =>
      'RichtextImage(id: $id, originalName: $originalName, mimeType: $mimeType, fileSize: $fileSize)';
}

class RichtextImagePage {
  final List<RichtextImage> items;
  final int total;

  const RichtextImagePage({required this.items, required this.total});
}
