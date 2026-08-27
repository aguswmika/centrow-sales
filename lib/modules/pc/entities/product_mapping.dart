class ProductMapping {
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

  const ProductMapping({
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
}
