import 'package:centrow_sales/modules/sales/entities/richtext_image.dart';

class RichtextImageDto {
  final String id;
  final String url;
  final String originalName;
  final String mimeType;
  final int fileSize;
  final String createdAt;

  const RichtextImageDto({
    required this.id,
    required this.url,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
  });

  factory RichtextImageDto.fromJson(Map<String, dynamic> json) {
    return RichtextImageDto(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      originalName: json['original_name']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  RichtextImage toEntity() {
    return RichtextImage(
      id: id,
      url: url,
      originalName: originalName,
      mimeType: mimeType,
      fileSize: fileSize,
      createdAt: createdAt,
    );
  }
}

class RichtextImageListResponseDto {
  final List<RichtextImageDto> items;
  final int total;

  const RichtextImageListResponseDto({
    required this.items,
    required this.total,
  });

  factory RichtextImageListResponseDto.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?) ?? [];
    return RichtextImageListResponseDto(
      items: itemsList
          .map(
            (e) =>
                RichtextImageDto.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}
