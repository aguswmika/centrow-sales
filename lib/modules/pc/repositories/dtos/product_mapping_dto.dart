import 'package:centrow_sales/modules/pc/entities/product_mapping.dart';

class ProductMappingDto {
  final String id;
  final String productId;
  final String? productCode;
  final String productName;
  final String pestId;
  final String? pestCode;
  final String pestName;
  final String treatmentMethodId;
  final String treatmentMethodCode;
  final String? treatmentMethodName;
  final double doseMinLimit;
  final double doseMaxLimit;
  final String doseUnitId;
  final String doseUnitCode;
  final String? doseUnitName;
  final double? defaultDose;
  final String? notes;
  final bool isActive;
  final double unitPrice;

  const ProductMappingDto({
    required this.id,
    required this.productId,
    this.productCode,
    required this.productName,
    required this.pestId,
    this.pestCode,
    required this.pestName,
    required this.treatmentMethodId,
    required this.treatmentMethodCode,
    this.treatmentMethodName,
    required this.doseMinLimit,
    required this.doseMaxLimit,
    required this.doseUnitId,
    required this.doseUnitCode,
    this.doseUnitName,
    this.defaultDose,
    this.notes,
    this.isActive = true,
    this.unitPrice = 0.0,
  });

  factory ProductMappingDto.fromJson(Map<String, dynamic> json) {
    return ProductMappingDto(
      id: json['id']?.toString() ?? '',
      productId:
          (json['product_id'] ??
                  json['productId'] ??
                  (json['product'] is Map ? json['product']['id'] : null))
              ?.toString() ??
          '',
      productCode:
          (json['product_code'] ??
                  json['productCode'] ??
                  (json['product'] is Map ? json['product']['code'] : null))
              ?.toString(),
      productName:
          (json['product_name'] ??
                  json['productName'] ??
                  (json['product'] is Map ? json['product']['name'] : null))
              ?.toString() ??
          '',
      pestId:
          (json['pest_id'] ??
                  json['pestId'] ??
                  (json['pest'] is Map ? json['pest']['id'] : null))
              ?.toString() ??
          '',
      pestCode:
          (json['pest_code'] ??
                  json['pestCode'] ??
                  (json['pest'] is Map ? json['pest']['code'] : null))
              ?.toString(),
      pestName:
          (json['pest_name'] ??
                  json['pestName'] ??
                  (json['pest'] is Map ? json['pest']['name'] : null))
              ?.toString() ??
          '',
      treatmentMethodId:
          (json['treatment_method_id'] ??
                  json['treatmentMethodId'] ??
                  (json['treatment_method'] is Map
                      ? json['treatment_method']['id']
                      : null))
              ?.toString() ??
          '',
      treatmentMethodCode:
          (json['treatment_method_code'] ??
                  json['treatmentMethodCode'] ??
                  (json['treatment_method'] is Map
                      ? json['treatment_method']['code']
                      : null))
              ?.toString() ??
          '',
      treatmentMethodName:
          (json['treatment_method_name'] ??
                  json['treatmentMethodName'] ??
                  (json['treatment_method'] is Map
                      ? json['treatment_method']['name']
                      : null))
              ?.toString(),
      doseMinLimit:
          ((json['dose_min_limit'] ?? json['doseMinLimit']) as num?)
              ?.toDouble() ??
          0.0,
      doseMaxLimit:
          ((json['dose_max_limit'] ?? json['doseMaxLimit']) as num?)
              ?.toDouble() ??
          0.0,
      doseUnitId:
          (json['dose_unit_id'] ??
                  json['doseUnitId'] ??
                  (json['dose_unit'] is Map ? json['dose_unit']['id'] : null))
              ?.toString() ??
          '',
      doseUnitCode:
          (json['dose_unit_code'] ??
                  json['doseUnitCode'] ??
                  (json['dose_unit'] is Map ? json['dose_unit']['code'] : null))
              ?.toString() ??
          '',
      doseUnitName:
          (json['dose_unit_name'] ??
                  json['doseUnitName'] ??
                  (json['dose_unit'] is Map ? json['dose_unit']['name'] : null))
              ?.toString(),
      defaultDose: ((json['default_dose'] ?? json['defaultDose']) as num?)
          ?.toDouble(),
      notes: (json['notes'] ?? json['note'])?.toString(),
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      unitPrice:
          ((json['unit_price'] ?? json['unitPrice']) as num?)?.toDouble() ??
          0.0,
    );
  }

  ProductMapping toEntity() {
    return ProductMapping(
      id: id,
      productId: productId,
      productCode: productCode,
      productName: productName,
      pestId: pestId,
      pestCode: pestCode,
      pestName: pestName,
      treatmentMethodId: treatmentMethodId,
      treatmentMethodCode: treatmentMethodCode,
      treatmentMethodName: treatmentMethodName,
      doseMinLimit: doseMinLimit,
      doseMaxLimit: doseMaxLimit,
      doseUnitId: doseUnitId,
      doseUnitCode: doseUnitCode,
      doseUnitName: doseUnitName,
      defaultDose: defaultDose,
      notes: notes,
      isActive: isActive,
      unitPrice: unitPrice,
    );
  }
}
