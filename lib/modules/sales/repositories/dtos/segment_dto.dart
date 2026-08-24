import 'package:centrow_sales/modules/sales/entities/segment.dart';

class SegmentItemDto {
  final String id;
  final String name;
  final String createdAt;

  const SegmentItemDto({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory SegmentItemDto.fromJson(Map<String, dynamic> json) {
    return SegmentItemDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Segment toEntity() {
    return Segment(id: id, name: name, createdAt: createdAt);
  }
}

class SegmentPaginationDto {
  final int total;
  final int totalPage;
  final bool hasNext;

  const SegmentPaginationDto({
    required this.total,
    required this.totalPage,
    required this.hasNext,
  });

  factory SegmentPaginationDto.fromJson(Map<String, dynamic> json) {
    return SegmentPaginationDto(
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPage: (json['total_page'] as num?)?.toInt() ?? 0,
      hasNext: json['has_next'] as bool? ?? false,
    );
  }
}

class SegmentListResponseDto {
  final List<SegmentItemDto> items;
  final SegmentPaginationDto? pagination;

  const SegmentListResponseDto({required this.items, this.pagination});

  factory SegmentListResponseDto.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?) ?? [];
    final paginationJson = json['pagination'] as Map<String, dynamic>?;

    return SegmentListResponseDto(
      items: itemsList
          .map(
            (e) => SegmentItemDto.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      pagination: paginationJson != null
          ? SegmentPaginationDto.fromJson(paginationJson)
          : null,
    );
  }
}
