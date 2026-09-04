import re

with open("lib/modules/sales/repositories/dtos/pricing_detail_dto.dart", "r") as f:
    content = f.read()

# restore toEntity
to_entity = """
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
"""

content = content.replace("      taxPercentage: (json['tax_percentage'] as num).toDouble(),\n  );\n}", "      taxPercentage: (json['tax_percentage'] as num).toDouble(),\n" + to_entity)

with open("lib/modules/sales/repositories/dtos/pricing_detail_dto.dart", "w") as f:
    f.write(content)

