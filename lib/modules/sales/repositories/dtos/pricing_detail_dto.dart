import 'package:centrow_sales/modules/sales/entities/pricing_detail.dart';

class PricingDetailSupplyDto {
  final String id;
  final int supplyType;
  final String? productId;
  final String? productMappingId;
  final String name;
  final String uomCode;
  final double qty;
  final double? doseUsage;
  final String doseUnitId;
  final double? applicationVolume;
  final String applicationVolumeUnitId;
  final int frequency;
  final double unitCost;
  final double lineTotal;
  final String? treatmentMethodId;
  final String? areaKerja;
  final String? note;
  final int? installedUnits;
  final String code;
  final String uomName;
  final String doseUnitCode;
  final String doseUnitName;
  final String applicationVolumeUnitCode;
  final String applicationVolumeUnitName;
  final String? treatmentMethodCode;
  final String? treatmentMethodName;
  final double? actualDosageUsage;

  double? get spkDoseUsage => actualDosageUsage;

  PricingDetailSupplyDto._(
    this.id,
    this.supplyType,
    this.productId,
    this.productMappingId,
    this.code,
    this.name,
    this.uomCode,
    this.uomName,
    this.qty,
    this.doseUsage,
    this.doseUnitId,
    this.doseUnitCode,
    this.doseUnitName,
    this.applicationVolume,
    this.applicationVolumeUnitId,
    this.applicationVolumeUnitCode,
    this.applicationVolumeUnitName,
    this.frequency,
    this.unitCost,
    this.lineTotal,
    this.treatmentMethodId,
    this.treatmentMethodCode,
    this.treatmentMethodName,
    this.areaKerja,
    this.note,
    this.installedUnits,
    this.actualDosageUsage,
  );

  factory PricingDetailSupplyDto.fromJson(Map<String, dynamic> j) =>
      PricingDetailSupplyDto._(
        j['id'] as String,
        (j['supply_type'] as num).toInt(),
        j['product_id'] as String?,
        j['product_mapping_id'] as String?,
        (j['code'] ??
                    j['product_code'] ??
                    j['productCode'] ??
                    j['item_code'] ??
                    (j['product'] is Map ? j['product']['code'] : null))
                ?.toString() ??
            '',
        j['name'] as String,
        j['uom_code'] as String? ??
            (j['uom'] is Map ? j['uom']['code']?.toString() : null) ??
            '',
        (j['uom_name'] ?? (j['uom'] is Map ? j['uom']['name'] : null))
                ?.toString() ??
            '',
        (j['qty'] as num).toDouble(),
        j['dose_usage'] == null ? null : (j['dose_usage'] as num).toDouble(),
        (j['dose_unit_id'] as String?) ?? '',
        (j['dose_unit_code'] ??
                    (j['dose_unit'] is Map ? j['dose_unit']['code'] : null))
                ?.toString() ??
            '',
        (j['dose_unit_name'] ??
                    (j['dose_unit'] is Map ? j['dose_unit']['name'] : null))
                ?.toString() ??
            '',
        j['application_volume'] == null
            ? null
            : (j['application_volume'] as num).toDouble(),
        (j['application_volume_unit_id'] as String?) ?? '',
        (j['application_volume_unit_code'] ??
                    (j['application_volume_unit'] is Map
                        ? j['application_volume_unit']['code']
                        : null))
                ?.toString() ??
            '',
        (j['application_volume_unit_name'] ??
                    (j['application_volume_unit'] is Map
                        ? j['application_volume_unit']['name']
                        : null))
                ?.toString() ??
            '',
        (j['frequency'] as num).toInt(),
        (j['unit_cost'] as num).toDouble(),
        (j['line_total'] as num).toDouble(),
        j['treatment_method_id'] as String?,
        (j['treatment_method_code'] ??
                (j['treatment_method'] is Map
                    ? j['treatment_method']['code']
                    : null))
            ?.toString(),
        (j['treatment_method_name'] ??
                (j['treatment_method'] is Map
                    ? j['treatment_method']['name']
                    : null))
            ?.toString(),
        j['area_kerja'] as String?,
        j['note'] as String?,
        (j['installed_units'] as num?)?.toInt(),
        (j['actual_dosage_usage'] ?? j['spk_dose_usage']) == null
            ? null
            : ((j['actual_dosage_usage'] ?? j['spk_dose_usage']) as num)
                  .toDouble(),
      );

  PricingDetailSupply toEntity() => PricingDetailSupply(
    id: id,
    supplyType: supplyType,
    productId: productId,
    productMappingId: productMappingId,
    code: code,
    name: name,
    uomCode: uomCode,
    uomName: uomName,
    qty: qty,
    doseUsage: doseUsage,
    doseUnitId: doseUnitId,
    doseUnitCode: doseUnitCode,
    doseUnitName: doseUnitName,
    applicationVolume: applicationVolume,
    applicationVolumeUnitId: applicationVolumeUnitId,
    applicationVolumeUnitCode: applicationVolumeUnitCode,
    applicationVolumeUnitName: applicationVolumeUnitName,
    frequency: frequency,
    unitCost: unitCost,
    lineTotal: lineTotal,
    treatmentMethodId: treatmentMethodId,
    treatmentMethodCode: treatmentMethodCode,
    treatmentMethodName: treatmentMethodName,
    areaKerja: areaKerja,
    note: note,
    installedUnits: installedUnits,
    actualDosageUsage: actualDosageUsage,
  );
}

class PricingDetailWorkerDto {
  final String id;
  final String productId;
  final String code;
  final String positionName;
  final int? visitFrequency;
  final double firstVisitMinutes;
  final double routineMinutes;
  final double hourlyRate;
  final double lineTotal;

  PricingDetailWorkerDto._(
    this.id,
    this.productId,
    this.code,
    this.positionName,
    this.visitFrequency,
    this.firstVisitMinutes,
    this.routineMinutes,
    this.hourlyRate,
    this.lineTotal,
  );

  factory PricingDetailWorkerDto.fromJson(Map<String, dynamic> j) =>
      PricingDetailWorkerDto._(
        j['id'] as String,
        j['product_id'] as String? ?? '',
        (j['code'] ??
                    j['product_code'] ??
                    j['productCode'] ??
                    j['item_code'] ??
                    (j['product'] is Map ? j['product']['code'] : null))
                ?.toString() ??
            '',
        j['position_name'] as String,
        j['visit_frequency'] == null
            ? null
            : (j['visit_frequency'] as num).toInt(),
        ((j['first_visit_minutes'] ?? j['first_visit_hours'] ?? 0) as num)
            .toDouble(),
        ((j['routine_minutes'] ?? j['routine_hours'] ?? 0) as num).toDouble(),
        (j['hourly_rate'] as num).toDouble(),
        (j['line_total'] as num).toDouble(),
      );

  PricingDetailWorker toEntity() => PricingDetailWorker(
    id: id,
    productId: productId,
    code: code,
    positionName: positionName,
    visitFrequency: visitFrequency,
    firstVisitMinutes: firstVisitMinutes,
    routineMinutes: routineMinutes,
    hourlyRate: hourlyRate,
    lineTotal: lineTotal,
  );
}

class PricingDetailItemDto {
  final String id;
  final int itemType;
  final String? productId;
  final String code;
  final String name;
  final double qty;
  final int frequency;
  final double unitCost;
  final double? unitPrice;
  final double lineTotal;

  PricingDetailItemDto._(
    this.id,
    this.itemType,
    this.productId,
    this.code,
    this.name,
    this.qty,
    this.frequency,
    this.unitCost,
    this.unitPrice,
    this.lineTotal,
  );

  factory PricingDetailItemDto.fromJson(Map<String, dynamic> j) =>
      PricingDetailItemDto._(
        j['id'] as String,
        (j['item_type'] as num).toInt(),
        j['product_id'] as String?,
        (j['code'] ??
                    j['product_code'] ??
                    j['productCode'] ??
                    j['item_code'] ??
                    (j['product'] is Map ? j['product']['code'] : null))
                ?.toString() ??
            '',
        j['name'] as String,
        (j['qty'] as num).toDouble(),
        (j['frequency'] as num).toInt(),
        (j['unit_cost'] as num).toDouble(),
        j['unit_price'] == null ? null : (j['unit_price'] as num).toDouble(),
        (j['line_total'] as num).toDouble(),
      );

  PricingDetailItem toEntity() => PricingDetailItem(
    id: id,
    itemType: itemType,
    productId: productId,
    code: code,
    name: name,
    qty: qty,
    frequency: frequency,
    unitCost: unitCost,
    unitPrice: unitPrice,
    lineTotal: lineTotal,
  );
}

class PricingDetailDto {
  final String id;
  final String customerId;
  final String serviceId;
  final double? areaSize;
  final String? areaUnitId;
  final int contractMonths;
  final int visitFrequency;
  final int totalVisits;
  final int markupType;
  final double markupValue;
  final double discountAmount;
  final double taxPercentage;
  final int scheduleWorkOrderType;
  final List<PricingDetailSupplyDto> supplies;
  final List<PricingDetailWorkerDto> workers;
  final List<PricingDetailItemDto> items;

  PricingDetailDto._({
    required this.id,
    required this.customerId,
    required this.serviceId,
    this.areaSize,
    this.areaUnitId,
    required this.contractMonths,
    required this.visitFrequency,
    required this.totalVisits,
    required this.markupType,
    required this.markupValue,
    required this.discountAmount,
    required this.taxPercentage,
    required this.scheduleWorkOrderType,
    required this.supplies,
    required this.workers,
    required this.items,
  });

  factory PricingDetailDto.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fn) =>
        raw == null
        ? []
        : (raw as List).cast<Map<String, dynamic>>().map(fn).toList();

    return PricingDetailDto._(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      serviceId: json['service_id'] as String,
      areaSize: (json['area_size'] as num?)?.toDouble(),
      areaUnitId: json['area_unit_id'] as String?,
      contractMonths: (json['contract_months'] as num).toInt(),
      visitFrequency: (json['visit_frequency'] as num).toInt(),
      totalVisits:
          (json['total_visits'] as num?)?.toInt() ??
          (json['visit_frequency'] as num?)?.toInt() ??
          1,
      markupType: (json['markup_type'] as num).toInt(),
      markupValue: (json['markup_value'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      taxPercentage: (json['tax_percentage'] as num).toDouble(),
      scheduleWorkOrderType: json['schedule_work_order_type'] as int? ?? 1,

      supplies: parseList(json['supplies'], PricingDetailSupplyDto.fromJson),
      workers: parseList(json['workers'], PricingDetailWorkerDto.fromJson),
      items: parseList(json['items'], PricingDetailItemDto.fromJson),
    );
  }

  PricingDetail toEntity() => PricingDetail(
    id: id,
    customerId: customerId,
    serviceId: serviceId,
    areaSize: areaSize,
    areaUnitId: areaUnitId,
    contractMonths: contractMonths,
    visitFrequency: visitFrequency,
    totalVisits: totalVisits,
    markupType: markupType,
    markupValue: markupValue,
    discountAmount: discountAmount,
    taxPercentage: taxPercentage,
    scheduleWorkOrderType: scheduleWorkOrderType,
    supplies: supplies.map((e) => e.toEntity()).toList(),
    workers: workers.map((e) => e.toEntity()).toList(),
    items: items.map((e) => e.toEntity()).toList(),
  );
}
