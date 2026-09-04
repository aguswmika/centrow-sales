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

  PricingDetailSupplyDto._(
    this.id,
    this.supplyType,
    this.productId,
    this.productMappingId,
    this.name,
    this.uomCode,
    this.qty,
    this.doseUsage,
    this.doseUnitId,
    this.applicationVolume,
    this.applicationVolumeUnitId,
    this.frequency,
    this.unitCost,
    this.lineTotal,
  );

  factory PricingDetailSupplyDto.fromJson(Map<String, dynamic> j) =>
      PricingDetailSupplyDto._(
        j['id'] as String,
        (j['supply_type'] as num).toInt(),
        j['product_id'] as String?,
        j['product_mapping_id'] as String?,
        j['name'] as String,
        j['uom_code'] as String,
        (j['qty'] as num).toDouble(),
        j['dose_usage'] == null ? null : (j['dose_usage'] as num).toDouble(),
        (j['dose_unit_id'] as String?) ?? '',
        j['application_volume'] == null
            ? null
            : (j['application_volume'] as num).toDouble(),
        (j['application_volume_unit_id'] as String?) ?? '',
        (j['frequency'] as num).toInt(),
        (j['unit_cost'] as num).toDouble(),
        (j['line_total'] as num).toDouble(),
      );

  PricingDetailSupply toEntity() => PricingDetailSupply(
    id: id,
    supplyType: supplyType,
    productId: productId,
    productMappingId: productMappingId,
    name: name,
    uomCode: uomCode,
    qty: qty,
    doseUsage: doseUsage,
    doseUnitId: doseUnitId,
    applicationVolume: applicationVolume,
    applicationVolumeUnitId: applicationVolumeUnitId,
    frequency: frequency,
    unitCost: unitCost,
    lineTotal: lineTotal,
  );
}

class PricingDetailWorkerDto {
  final String id;
  final String productId;
  final String positionName;
  final int? visitFrequency;
  final double firstVisitHours;
  final double routineHours;
  final double hourlyRate;
  final double lineTotal;

  PricingDetailWorkerDto._(
    this.id,
    this.productId,
    this.positionName,
    this.visitFrequency,
    this.firstVisitHours,
    this.routineHours,
    this.hourlyRate,
    this.lineTotal,
  );

  factory PricingDetailWorkerDto.fromJson(Map<String, dynamic> j) =>
      PricingDetailWorkerDto._(
        j['id'] as String,
        j['product_id'] as String? ?? '',
        j['position_name'] as String,
        j['visit_frequency'] == null
            ? null
            : (j['visit_frequency'] as num).toInt(),
        (j['first_visit_hours'] as num).toDouble(),
        (j['routine_hours'] as num).toDouble(),
        (j['hourly_rate'] as num).toDouble(),
        (j['line_total'] as num).toDouble(),
      );

  PricingDetailWorker toEntity() => PricingDetailWorker(
    id: id,
    productId: productId,
    positionName: positionName,
    visitFrequency: visitFrequency,
    firstVisitHours: firstVisitHours,
    routineHours: routineHours,
    hourlyRate: hourlyRate,
    lineTotal: lineTotal,
  );
}

class PricingDetailItemDto {
  final String id;
  final int itemType;
  final String? productId;
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
  final int markupType;
  final double markupValue;
  final double discountAmount;
  final double taxPercentage;
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
    required this.markupType,
    required this.markupValue,
    required this.discountAmount,
    required this.taxPercentage,
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
      markupType: (json['markup_type'] as num).toInt(),
      markupValue: (json['markup_value'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      taxPercentage: (json['tax_percentage'] as num).toDouble(),

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
    markupType: markupType,
    markupValue: markupValue,
    discountAmount: discountAmount,
    taxPercentage: taxPercentage,
    supplies: supplies.map((e) => e.toEntity()).toList(),
    workers: workers.map((e) => e.toEntity()).toList(),
    items: items.map((e) => e.toEntity()).toList(),
  );
}
