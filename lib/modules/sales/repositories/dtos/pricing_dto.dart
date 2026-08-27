class CreatePricingRequestDto {
  final String customerId;
  final String serviceId;
  final double? areaValue;
  final String? areaUnitId;
  final int contractMonths;
  final int visitFrequency;
  final int markupType;
  final double markupValue;
  final double discountAmount;
  final List<PricingMaterialDto> materials;
  final List<PricingLaborDto> labors;
  final List<PricingItemDto> items;

  const CreatePricingRequestDto({
    required this.customerId,
    required this.serviceId,
    this.areaValue,
    this.areaUnitId,
    required this.contractMonths,
    required this.visitFrequency,
    required this.markupType,
    required this.markupValue,
    required this.discountAmount,
    required this.materials,
    required this.labors,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'customer_id': customerId,
    'service_id': serviceId,
    if (areaValue != null) 'area_value': areaValue,
    if (areaUnitId != null) 'area_unit_id': areaUnitId,
    'contract_months': contractMonths,
    'visit_frequency': visitFrequency,
    'markup_type': markupType,
    'markup_value': markupValue,
    'discount_amount': discountAmount,
    'materials': materials.map((e) => e.toJson()).toList(),
    'labors': labors.map((e) => e.toJson()).toList(),
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class PricingMaterialDto {
  final String productMappingId;
  final String name;
  final String uomCode;
  final double doseUsage;
  final String doseUnitId;
  final double applicationVolume;
  final String applicationVolumeUnitId;
  final int frequency;

  const PricingMaterialDto({
    required this.productMappingId,
    required this.name,
    required this.uomCode,
    required this.doseUsage,
    required this.doseUnitId,
    required this.applicationVolume,
    required this.applicationVolumeUnitId,
    required this.frequency,
  });

  Map<String, dynamic> toJson() => {
    'product_mapping_id': productMappingId,
    'name': name,
    'uom_code': uomCode,
    'dose_usage': doseUsage,
    'dose_unit_id': doseUnitId,
    'application_volume': applicationVolume,
    'application_volume_unit_id': applicationVolumeUnitId,
    'frequency': frequency,
  };
}

class PricingLaborDto {
  final String positionName;
  final double firstVisitHours;
  final double routineHours;
  final double hourlyRate;

  const PricingLaborDto({
    required this.positionName,
    required this.firstVisitHours,
    required this.routineHours,
    required this.hourlyRate,
  });

  Map<String, dynamic> toJson() => {
    'position_name': positionName,
    'first_visit_hours': firstVisitHours,
    'routine_hours': routineHours,
    'hourly_rate': hourlyRate,
  };
}

class PricingItemDto {
  final int itemType;
  final String productId;
  final String name;
  final double qty;
  final int frequency;
  final double? unitPrice;

  const PricingItemDto({
    required this.itemType,
    required this.productId,
    required this.name,
    required this.qty,
    required this.frequency,
    this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
    'item_type': itemType,
    'product_id': productId,
    'name': name,
    'qty': qty,
    'frequency': frequency,
    if (unitPrice != null) 'unit_price': unitPrice,
  };
}
