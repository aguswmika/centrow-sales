// Entity returned by GET /api/v1/sales/pricings/:id.
// Pure Dart — no Flutter, no Dio, no signals.

class PricingDetailSupply {
  final String id;
  final int supplyType; // 1 = chemical, 2 = tool
  final String? productId;
  final String? productMappingId;
  final String code;
  final String name;
  final String uomCode;
  final String uomName;
  final double qty;
  final double? doseUsage;
  final String doseUnitId;
  final String doseUnitCode;
  final String doseUnitName;
  final double? applicationVolume;
  final String applicationVolumeUnitId;
  final String applicationVolumeUnitCode;
  final String applicationVolumeUnitName;
  final int frequency;
  final double unitCost;
  final double lineTotal;
  final String? treatmentMethodId;
  final String? treatmentMethodCode;
  final String? treatmentMethodName;
  final String? areaKerja;
  final String? note;
  final int? installedUnits;
  final double? actualDosageUsage;

  double? get spkDoseUsage => actualDosageUsage;

  const PricingDetailSupply({
    required this.id,
    required this.supplyType,
    this.productId,
    this.productMappingId,
    this.code = '',
    required this.name,
    required this.uomCode,
    this.uomName = '',
    required this.qty,
    this.doseUsage,
    required this.doseUnitId,
    this.doseUnitCode = '',
    this.doseUnitName = '',
    this.applicationVolume,
    required this.applicationVolumeUnitId,
    this.applicationVolumeUnitCode = '',
    this.applicationVolumeUnitName = '',
    required this.frequency,
    required this.unitCost,
    required this.lineTotal,
    this.treatmentMethodId,
    this.treatmentMethodCode,
    this.treatmentMethodName,
    this.areaKerja,
    this.note,
    this.installedUnits,
    double? actualDosageUsage,
    double? spkDoseUsage,
  }) : actualDosageUsage = actualDosageUsage ?? spkDoseUsage;
}

class PricingDetailWorker {
  final String id;
  final String productId;
  final String code;
  final String positionName;
  final int? visitFrequency;
  final double firstVisitMinutes;
  final double routineMinutes;
  final double hourlyRate;
  final double lineTotal;

  const PricingDetailWorker({
    required this.id,
    required this.productId,
    this.code = '',
    required this.positionName,
    this.visitFrequency,
    required this.firstVisitMinutes,
    required this.routineMinutes,
    required this.hourlyRate,
    required this.lineTotal,
  });
}

class PricingDetailItem {
  final String id;
  final int itemType; // 1 = transport, 2 = add-on
  final String? productId;
  final String code;
  final String name;
  final double qty;
  final int frequency;
  final double unitCost;
  final double? unitPrice;
  final double lineTotal;

  const PricingDetailItem({
    required this.id,
    required this.itemType,
    this.productId,
    this.code = '',
    required this.name,
    required this.qty,
    required this.frequency,
    required this.unitCost,
    this.unitPrice,
    required this.lineTotal,
  });
}

class PricingDetail {
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

  final List<PricingDetailSupply> supplies;
  final List<PricingDetailWorker> workers;
  final List<PricingDetailItem> items;

  const PricingDetail({
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
    this.scheduleWorkOrderType = 1,
    required this.supplies,
    required this.workers,
    required this.items,
  });

  PricingDetail copyWith({
    String? id,
    String? customerId,
    String? serviceId,
    double? areaSize,
    String? areaUnitId,
    int? contractMonths,
    int? visitFrequency,
    int? totalVisits,
    int? markupType,
    double? markupValue,
    double? discountAmount,
    double? taxPercentage,
    int? scheduleWorkOrderType,
    List<PricingDetailSupply>? supplies,
    List<PricingDetailWorker>? workers,
    List<PricingDetailItem>? items,
  }) {
    return PricingDetail(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      areaSize: areaSize ?? this.areaSize,
      areaUnitId: areaUnitId ?? this.areaUnitId,
      contractMonths: contractMonths ?? this.contractMonths,
      visitFrequency: visitFrequency ?? this.visitFrequency,
      totalVisits: totalVisits ?? this.totalVisits,
      markupType: markupType ?? this.markupType,
      markupValue: markupValue ?? this.markupValue,
      discountAmount: discountAmount ?? this.discountAmount,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      scheduleWorkOrderType:
          scheduleWorkOrderType ?? this.scheduleWorkOrderType,
      supplies: supplies ?? this.supplies,
      workers: workers ?? this.workers,
      items: items ?? this.items,
    );
  }
}
