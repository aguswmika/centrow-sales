// Entity returned by GET /api/v1/sales/pricings/:id.
// Pure Dart — no Flutter, no Dio, no signals.

class PricingDetailSupply {
  final String id;
  final int supplyType; // 1 = chemical, 2 = tool
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

  const PricingDetailSupply({
    required this.id,
    required this.supplyType,
    this.productId,
    this.productMappingId,
    required this.name,
    required this.uomCode,
    required this.qty,
    this.doseUsage,
    required this.doseUnitId,
    this.applicationVolume,
    required this.applicationVolumeUnitId,
    required this.frequency,
    required this.unitCost,
    required this.lineTotal,
  });
}

class PricingDetailWorker {
  final String id;
  final String productId;
  final String positionName;
  final int? visitFrequency;
  final double firstVisitHours;
  final double routineHours;
  final double hourlyRate;
  final double lineTotal;

  const PricingDetailWorker({
    required this.id,
    required this.productId,
    required this.positionName,
    this.visitFrequency,
    required this.firstVisitHours,
    required this.routineHours,
    required this.hourlyRate,
    required this.lineTotal,
  });
}

class PricingDetailItem {
  final String id;
  final int itemType; // 1 = transport, 2 = add-on
  final String? productId;
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
  final int markupType;
  final double markupValue;
  final double discountAmount;
  final double taxPercentage;

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
    required this.markupType,
    required this.markupValue,
    required this.discountAmount,
    required this.taxPercentage,
    required this.supplies,
    required this.workers,
    required this.items,
  });
}
