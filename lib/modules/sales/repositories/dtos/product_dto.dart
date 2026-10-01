import 'package:centrow_sales/modules/sales/entities/product.dart';

class ProductDto {
  final String id;
  final String code;
  final String name;
  final String uomId;
  final String uomCode;
  final String uomName;
  final double cogs;
  final bool isActive;

  const ProductDto({
    required this.id,
    required this.code,
    required this.name,
    required this.uomId,
    required this.uomCode,
    this.uomName = '',
    required this.cogs,
    required this.isActive,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id']?.toString() ?? '',
      code:
          (json['code'] ??
                  json['product_code'] ??
                  json['productCode'] ??
                  json['item_code'] ??
                  json['sku'])
              ?.toString() ??
          '',
      name: json['name']?.toString() ?? '',
      uomId: (json['uom_id'] ?? json['uomId'])?.toString() ?? '',
      uomCode:
          (json['uom_code'] ??
                  json['uomCode'] ??
                  (json['uom'] is Map ? json['uom']['code'] : null) ??
                  json['uom'])
              ?.toString() ??
          '',
      uomName:
          (json['uom_name'] ??
                  json['uomName'] ??
                  (json['uom'] is Map ? json['uom']['name'] : null))
              ?.toString() ??
          '',
      cogs: (json['cogs'] as num?)?.toDouble() ?? 0.0,
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
    );
  }

  Product toEntity({int? requestedKind}) {
    return Product(
      id: id,
      code: code,
      name: name,
      uomId: uomId,
      uomCode: uomCode,
      uomName: uomName,
      cogs: cogs,
      isActive: isActive,
      kind: requestedKind,
    );
  }
}
