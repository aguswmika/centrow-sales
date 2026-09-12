class CreatePricingRequestDto {
  final int contractMonths;
  final int visitFrequency;
  final int markupType;
  final double markupValue;
  final double discountAmount;
  final double taxPercentage;
  final List<PricingSupplyDto> supplies;
  final List<PricingWorkerDto> workers;
  final List<PricingItemDto> items;

  const CreatePricingRequestDto({
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

  Map<String, dynamic> toJson() => {
    'contract_months': contractMonths,
    'visit_frequency': visitFrequency,
    'markup_type': markupType,
    'markup_value': markupValue,
    'discount_amount': discountAmount,
    'tax_percentage': taxPercentage,
    'supplies': supplies.map((e) => e.toJson()).toList(),
    'workers': workers.map((e) => e.toJson()).toList(),
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class PricingSupplyDto {
  final int supplyType;
  final String? productMappingId;
  final String? productId;
  final String name;
  final String uomCode;
  final double? qty;
  final double? doseUsage;
  final String? doseUnitId;
  final double? applicationVolume;
  final String? applicationVolumeUnitId;
  final int frequency;

  const PricingSupplyDto({
    required this.supplyType,
    this.productMappingId,
    this.productId,
    required this.name,
    required this.uomCode,
    this.qty,
    this.doseUsage,
    this.doseUnitId,
    this.applicationVolume,
    this.applicationVolumeUnitId,
    required this.frequency,
  });

  Map<String, dynamic> toJson() => {
    'supply_type': supplyType,
    'name': name,
    'uom_code': uomCode,
    'frequency': frequency,
    if (supplyType == 1) ...{
      'product_mapping_id': productMappingId,
      'dose_usage': doseUsage,
      'dose_unit_id': doseUnitId,
      'application_volume': applicationVolume,
      'application_volume_unit_id': applicationVolumeUnitId,
    },
    if (supplyType == 2) ...{'product_id': productId, 'qty': qty},
  };
}

class PricingWorkerDto {
  final String productId;
  final int? visitFrequency;
  final double firstVisitMinutes;
  final double routineMinutes;

  const PricingWorkerDto({
    required this.productId,
    this.visitFrequency,
    required this.firstVisitMinutes,
    required this.routineMinutes,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    if (visitFrequency != null) 'visit_frequency': visitFrequency,
    'first_visit_minutes': firstVisitMinutes,
    'routine_minutes': routineMinutes,
  };
}

class PricingItemDto {
  final int itemType;
  final String? productId;
  final String name;
  final double qty;
  final int frequency;
  final double? unitPrice;

  const PricingItemDto({
    required this.itemType,
    this.productId,
    required this.name,
    required this.qty,
    required this.frequency,
    this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
    'item_type': itemType,
    if (productId != null) 'product_id': productId,
    'name': name,
    'qty': qty,
    'frequency': frequency,
    if (unitPrice != null) 'unit_price': unitPrice,
  };
}
