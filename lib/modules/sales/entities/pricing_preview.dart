/// Represents a server-computed pricing breakdown returned by
/// POST /api/v1/sales/pricings/preview.
class PricingPreviewLine {
  final String name;
  final double lineTotal;

  const PricingPreviewLine({required this.name, required this.lineTotal});
}

class PricingPreview {
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

  // Per-line breakdown for display
  final List<PricingPreviewLine> supplies;
  final List<PricingPreviewLine> workers;
  final List<PricingPreviewLine> items;

  const PricingPreview({
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
}
