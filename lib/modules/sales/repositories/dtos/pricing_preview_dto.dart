import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';

class PricingLineDto {
  final String name;
  final double lineTotal;

  PricingLineDto({required this.name, required this.lineTotal});

  factory PricingLineDto.fromJson(Map<String, dynamic> j) => PricingLineDto(
    name: (j['name'] ?? j['position_name'] ?? '') as String,
    lineTotal: (j['line_total'] as num).toDouble(),
  );

  PricingPreviewLine toEntity() =>
      PricingPreviewLine(name: name, lineTotal: lineTotal);
}

class PricingPreviewDto {
  final double suppliesCost;
  final double workerCost;
  final double fuelCost;
  final double totalCogs;
  final double servicePrice;
  final double addonAmount;
  final double discountAmount;
  final double subtotal;
  final double taxPercentage;
  final double taxAmount;
  final double totalAmount;
  final double marginAmount;
  final double marginPercent;
  final List<PricingLineDto> supplies;
  final List<PricingLineDto> workers;
  final List<PricingLineDto> items;

  PricingPreviewDto._({
    required this.suppliesCost,
    required this.workerCost,
    required this.fuelCost,
    required this.totalCogs,
    required this.servicePrice,
    required this.addonAmount,
    required this.discountAmount,
    required this.subtotal,
    required this.taxPercentage,
    required this.taxAmount,
    required this.totalAmount,
    required this.marginAmount,
    required this.marginPercent,
    required this.supplies,
    required this.workers,
    required this.items,
  });

  factory PricingPreviewDto.fromJson(Map<String, dynamic> json) {
    List<PricingLineDto> parseLines(dynamic raw) => raw == null
        ? []
        : (raw as List)
              .cast<Map<String, dynamic>>()
              .map(PricingLineDto.fromJson)
              .toList();

    return PricingPreviewDto._(
      suppliesCost: (json['supplies_cost'] as num).toDouble(),
      workerCost: (json['worker_cost'] as num).toDouble(),
      fuelCost: (json['fuel_cost'] as num).toDouble(),
      totalCogs: (json['total_cogs'] as num).toDouble(),
      servicePrice: (json['service_price'] as num).toDouble(),
      addonAmount: (json['addon_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxPercentage: (json['tax_percentage'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      marginAmount: (json['margin_amount'] as num).toDouble(),
      marginPercent: (json['margin_percent'] as num).toDouble(),
      supplies: parseLines(json['supplies']),
      workers: parseLines(json['workers']),
      items: parseLines(json['items']),
    );
  }

  PricingPreview toEntity() => PricingPreview(
    suppliesCost: suppliesCost,
    workerCost: workerCost,
    fuelCost: fuelCost,
    totalCogs: totalCogs,
    servicePrice: servicePrice,
    addonAmount: addonAmount,
    discountAmount: discountAmount,
    subtotal: subtotal,
    taxPercentage: taxPercentage,
    taxAmount: taxAmount,
    totalAmount: totalAmount,
    marginAmount: marginAmount,
    marginPercent: marginPercent,
    supplies: supplies.map((e) => e.toEntity()).toList(),
    workers: workers.map((e) => e.toEntity()).toList(),
    items: items.map((e) => e.toEntity()).toList(),
  );
}
