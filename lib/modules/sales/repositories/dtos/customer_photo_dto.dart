import 'package:centrow_sales/modules/sales/entities/customer_photo.dart';

class CustomerPhotoDto {
  final String id;
  final String url;
  final String originalName;
  final String mimeType;
  final int fileSize;
  final String createdAt;
  final String createdBy;

  const CustomerPhotoDto({
    required this.id,
    required this.url,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
    required this.createdBy,
  });

  factory CustomerPhotoDto.fromJson(Map<String, dynamic> json) {
    return CustomerPhotoDto(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      originalName: json['original_name']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
    );
  }

  CustomerPhoto toEntity() {
    return CustomerPhoto(
      id: id,
      url: url,
      originalName: originalName,
      mimeType: mimeType,
      fileSize: fileSize,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}

class CustomerPhotoListResponseDto {
  final List<CustomerPhotoDto> items;

  const CustomerPhotoListResponseDto({required this.items});

  factory CustomerPhotoListResponseDto.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?) ?? [];
    return CustomerPhotoListResponseDto(
      items: itemsList
          .map(
            (e) =>
                CustomerPhotoDto.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
    );
  }
}
