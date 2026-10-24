import 'package:centrow_sales/modules/sales/entities/pricing_preview.dart';

double _toDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

class PricingLineDto {
  final String name;
  final double lineTotal;

  PricingLineDto({required this.name, required this.lineTotal});

  factory PricingLineDto.fromJson(Map<String, dynamic> j) => PricingLineDto(
    name: (j['name'] ?? j['position_name'] ?? j['title'] ?? '').toString(),
    lineTotal: _toDouble(j['line_total'] ?? j['total'] ?? j['amount']),
  );

  PricingPreviewLine toEntity() =>
      PricingPreviewLine(name: name, lineTotal: lineTotal);
}

class PricingPreviewDto {
  final double suppliesCost;
  final double workerCost;
  final double fuelCost;
  final double addonCost;
  final double totalCost;
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
    this.addonCost = 0.0,
    required this.totalCost,
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
    List<PricingLineDto> parseLines(dynamic raw) {
      if (raw is! List) return [];
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => PricingLineDto.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    return PricingPreviewDto._(
      suppliesCost: _toDouble(json['supplies_cost'] ?? json['suppliesCost']),
      workerCost: _toDouble(json['worker_cost'] ?? json['workerCost']),
      fuelCost: _toDouble(json['fuel_cost'] ?? json['fuelCost']),
      addonCost: _toDouble(json['addon_cost'] ?? json['addonCost']),
      totalCost: _toDouble(
        json['total_cost'] ??
            json['totalCost'] ??
            json['total_cogs'] ??
            json['totalCogs'],
      ),
      servicePrice: _toDouble(json['service_price'] ?? json['servicePrice']),
      addonAmount: _toDouble(json['addon_amount'] ?? json['addonAmount']),
      discountAmount: _toDouble(
        json['discount_amount'] ?? json['discountAmount'],
      ),
      subtotal: _toDouble(json['subtotal']),
      taxPercentage: _toDouble(json['tax_percentage'] ?? json['taxPercentage']),
      taxAmount: _toDouble(json['tax_amount'] ?? json['taxAmount']),
      totalAmount: _toDouble(json['total_amount'] ?? json['totalAmount']),
      marginAmount: _toDouble(json['margin_amount'] ?? json['marginAmount']),
      marginPercent: _toDouble(json['margin_percent'] ?? json['marginPercent']),
      supplies: parseLines(json['supplies']),
      workers: parseLines(json['workers']),
      items: parseLines(json['items']),
    );
  }

  PricingPreview toEntity() => PricingPreview(
    suppliesCost: suppliesCost,
    workerCost: workerCost,
    fuelCost: fuelCost,
    addonCost: addonCost,
    totalCost: totalCost,
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
