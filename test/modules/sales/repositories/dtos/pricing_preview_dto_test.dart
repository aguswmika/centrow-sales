import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_preview_dto.dart';

void main() {
  group('PricingPreviewDto', () {
    test('fromJson parses complete valid JSON correctly', () {
      final json = {
        'supplies_cost': 120000.0,
        'worker_cost': 80000.0,
        'fuel_cost': 25000.0,
        'addon_cost': 15000.0,
        'total_cogs': 240000.0,
        'service_price': 500000.0,
        'addon_amount': 50000.0,
        'discount_amount': 10000.0,
        'subtotal': 540000.0,
        'tax_percentage': 11.0,
        'tax_amount': 59400.0,
        'total_amount': 599400.0,
        'margin_amount': 300000.0,
        'margin_percent': 55.5,
        'supplies': [
          {'name': 'Chemical A', 'line_total': 120000.0},
        ],
        'workers': [
          {'position_name': 'Technician', 'line_total': 80000.0},
        ],
        'items': [
          {'name': 'Transport', 'line_total': 25000.0},
        ],
      };

      final dto = PricingPreviewDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.suppliesCost, 120000.0);
      expect(entity.workerCost, 80000.0);
      expect(entity.fuelCost, 25000.0);
      expect(entity.addonCost, 15000.0);
      expect(entity.totalCost, 240000.0);
      expect(entity.servicePrice, 500000.0);
      expect(entity.addonAmount, 50000.0);
      expect(entity.discountAmount, 10000.0);
      expect(entity.subtotal, 540000.0);
      expect(entity.taxPercentage, 11.0);
      expect(entity.taxAmount, 59400.0);
      expect(entity.totalAmount, 599400.0);
      expect(entity.marginAmount, 300000.0);
      expect(entity.marginPercent, 55.5);
      expect(entity.supplies.length, 1);
      expect(entity.supplies.first.name, 'Chemical A');
      expect(entity.supplies.first.lineTotal, 120000.0);
      expect(entity.workers.length, 1);
      expect(entity.workers.first.name, 'Technician');
      expect(entity.items.length, 1);
    });

    test('fromJson gracefully handles null and missing numeric fields', () {
      final json = <String, dynamic>{
        'supplies_cost': null,
        'worker_cost': 50000,
        'fuel_cost': null,
        'addon_cost': null,
        'total_cogs': null,
        'service_price': null,
        'addon_amount': null,
        'discount_amount': null,
        'subtotal': null,
        'tax_percentage': null,
        'tax_amount': null,
        'total_amount': null,
        'margin_amount': null,
        'margin_percent': null,
        'supplies': [
          {'name': 'Null Line', 'line_total': null},
        ],
        'workers': null,
        'items': null,
      };

      final dto = PricingPreviewDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.suppliesCost, 0.0);
      expect(entity.workerCost, 50000.0);
      expect(entity.fuelCost, 0.0);
      expect(entity.addonCost, 0.0);
      expect(entity.totalCost, 0.0);
      expect(entity.servicePrice, 0.0);
      expect(entity.addonAmount, 0.0);
      expect(entity.discountAmount, 0.0);
      expect(entity.subtotal, 0.0);
      expect(entity.taxPercentage, 0.0);
      expect(entity.taxAmount, 0.0);
      expect(entity.totalAmount, 0.0);
      expect(entity.marginAmount, 0.0);
      expect(entity.marginPercent, 0.0);
      expect(entity.supplies.length, 1);
      expect(entity.supplies.first.name, 'Null Line');
      expect(entity.supplies.first.lineTotal, 0.0);
      expect(entity.workers, isEmpty);
      expect(entity.items, isEmpty);
    });

    test('fromJson handles string numbers and camelCase fallback keys', () {
      final json = {
        'suppliesCost': '150000',
        'workerCost': '75000.5',
        'subtotal': '225000.5',
      };

      final dto = PricingPreviewDto.fromJson(json);
      expect(dto.suppliesCost, 150000.0);
      expect(dto.workerCost, 75000.5);
      expect(dto.subtotal, 225000.5);
    });

    test('fromJson parses total_cost', () {
      final dto = PricingPreviewDto.fromJson({'total_cost': 111.0});
      expect(dto.toEntity().totalCost, 111.0);
    });

    test('fromJson falls back to legacy total_cogs', () {
      final entity = PricingPreviewDto.fromJson({
        'total_cogs': 222.0,
      }).toEntity();
      expect(entity.totalCost, 222.0);
      expect(entity.totalCogs, 222.0);
    });
  });
}
