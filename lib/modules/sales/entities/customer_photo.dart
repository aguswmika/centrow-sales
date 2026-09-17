class CustomerPhoto {
  final String id;
  final String url;
  final String originalName;
  final String mimeType;
  final int fileSize;
  final String createdAt;
  final String createdBy;

  const CustomerPhoto({
    required this.id,
    required this.url,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
    required this.createdBy,
  });

  String get sizeLabel {
    const mb = 1024 * 1024;
    const kb = 1024;

    if (fileSize >= mb) {
      final sizeInMb = fileSize / mb;
      return '${sizeInMb.toStringAsFixed(1)} MB';
    } else {
      final sizeInKb = fileSize / kb;
      return '${sizeInKb.toStringAsFixed(0)} KB';
    }
  }

  CustomerPhoto copyWith({
    String? id,
    String? url,
    String? originalName,
    String? mimeType,
    int? fileSize,
    String? createdAt,
    String? createdBy,
  }) {
    return CustomerPhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerPhoto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url &&
          originalName == other.originalName &&
          mimeType == other.mimeType &&
          fileSize == other.fileSize &&
          createdAt == other.createdAt &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(
    id,
    url,
    originalName,
    mimeType,
    fileSize,
    createdAt,
    createdBy,
  );

  @override
  String toString() =>
      'CustomerPhoto(id: $id, originalName: $originalName, mimeType: $mimeType, fileSize: $fileSize)';
}
