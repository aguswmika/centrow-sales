import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_detail_dto.dart';

void main() {
  group('PricingDetailSupplyDto', () {
    test('fromJson parses correctly from snake_case JSON with new fields', () {
      final json = {
        'id': 'sup-1',
        'supply_type': 2,
        'product_id': 'prod-1',
        'product_mapping_id': 'pm-1',
        'name': 'Fly Trap',
        'uom_code': 'PCS',
        'qty': 5,
        'dose_usage': 1.0,
        'dose_unit_id': 'unit-1',
        'application_volume': 1.0,
        'application_volume_unit_id': 'vol-1',
        'frequency': 2,
        'unit_cost': 50000.0,
        'line_total': 250000.0,
        'treatment_method_id': 'tm-1',
        'area_kerja': 'Kitchen Area',
        'note': 'Install near back door',
        'installed_units': 3,
      };

      final dto = PricingDetailSupplyDto.fromJson(json);
      expect(dto.id, 'sup-1');
      expect(dto.supplyType, 2);
      expect(dto.productId, 'prod-1');
      expect(dto.treatmentMethodId, 'tm-1');
      expect(dto.areaKerja, 'Kitchen Area');
      expect(dto.note, 'Install near back door');
      expect(dto.installedUnits, 3);

      final entity = dto.toEntity();
      expect(entity.id, 'sup-1');
      expect(entity.treatmentMethodId, 'tm-1');
      expect(entity.areaKerja, 'Kitchen Area');
      expect(entity.note, 'Install near back door');
      expect(entity.installedUnits, 3);
    });
  });

  group('PricingDetailDto', () {
    test('fromJson and toEntity include total_visits and supplies', () {
      final json = {
        'id': 'p-1',
        'customer_id': 'c-1',
        'service_id': 's-1',
        'contract_months': 12,
        'visit_frequency': 2,
        'total_visits': 24,
        'markup_type': 1,
        'markup_value': 10.0,
        'discount_amount': 0.0,
        'tax_percentage': 11.0,
        'schedule_work_order_type': 2,
        'supplies': <Map<String, dynamic>>[
          {
            'id': 'sup-1',
            'supply_type': 1,
            'name': 'Chemical A',
            'uom_code': 'LTR',
            'qty': 10,
            'frequency': 1,
            'unit_cost': 20000.0,
            'line_total': 200000.0,
            'treatment_method_id': 'tm-2',
            'area_kerja': 'Lobby',
            'note': 'Routine misting',
          },
        ],
        'workers': <Map<String, dynamic>>[],
        'items': <Map<String, dynamic>>[],
      };

      final dto = PricingDetailDto.fromJson(json);
      expect(dto.totalVisits, 24);
      expect(dto.scheduleWorkOrderType, 2);
      expect(dto.supplies.length, 1);
      expect(dto.supplies.first.treatmentMethodId, 'tm-2');
      expect(dto.supplies.first.areaKerja, 'Lobby');
      expect(dto.supplies.first.note, 'Routine misting');

      final entity = dto.toEntity();
      expect(entity.totalVisits, 24);
      expect(entity.scheduleWorkOrderType, 2);
      expect(entity.supplies.length, 1);
      expect(entity.supplies.first.treatmentMethodId, 'tm-2');
      expect(entity.supplies.first.areaKerja, 'Lobby');
    });

    test(
      'fromJson falls back to scheduleWorkOrderType = 1 when field is absent',
      () {
        final json = {
          'id': 'p-2',
          'customer_id': 'c-2',
          'service_id': 's-2',
          'contract_months': 6,
          'visit_frequency': 1,
          'total_visits': 6,
          'markup_type': 1,
          'markup_value': 0.0,
          'discount_amount': 0.0,
          'tax_percentage': 0.0,
          'supplies': <Map<String, dynamic>>[],
          'workers': <Map<String, dynamic>>[],
          'items': <Map<String, dynamic>>[],
          // schedule_work_order_type intentionally omitted
        };

        final dto = PricingDetailDto.fromJson(json);
        expect(dto.scheduleWorkOrderType, 1);
        expect(dto.toEntity().scheduleWorkOrderType, 1);
      },
    );

    test('fromJson and toEntity include addon_cost and item unit_cost', () {
      final json = {
        'id': 'p-3',
        'customer_id': 'c-3',
        'service_id': 's-3',
        'contract_months': 12,
        'visit_frequency': 1,
        'total_visits': 12,
        'markup_type': 3,
        'markup_value': 1000000.0,
        'discount_amount': 0.0,
        'tax_percentage': 11.0,
        'addon_cost': 250000.0,
        'supplies': <Map<String, dynamic>>[],
        'workers': <Map<String, dynamic>>[],
        'items': <Map<String, dynamic>>[
          {
            'id': 'item-1',
            'item_type': 2,
            'name': 'Custom Addon',
            'qty': 1,
            'frequency': 1,
            'unit_cost': 250000.0,
            'unit_price': 500000.0,
            'line_total': 500000.0,
          },
        ],
      };

      final dto = PricingDetailDto.fromJson(json);
      expect(dto.addonCost, 250000.0);
      expect(dto.items.first.unitCost, 250000.0);

      final entity = dto.toEntity();
      expect(entity.addonCost, 250000.0);
      expect(entity.items.first.unitCost, 250000.0);
    });

    test('item parses actual_qty and addon_kind when present', () {
      final json = _pricingJsonWithItems([
        {
          'id': 'item-2',
          'item_type': 2,
          'product_id': 'prod-2',
          'name': 'Paket Add-on',
          'qty': 1,
          'frequency': 1,
          'unit_cost': 100000.0,
          'unit_price': 200000.0,
          'line_total': 200000.0,
          'actual_qty': 3,
          'addon_kind': 6,
        },
      ]);

      final item = PricingDetailDto.fromJson(json).items.first;
      expect(item.actualQty, 3.0);
      expect(item.addonKind, 6);

      final entity = PricingDetailDto.fromJson(json).toEntity().items.first;
      expect(entity.actualQty, 3.0);
      expect(entity.addonKind, 6);
    });

    test('item without actual_qty and addon_kind falls back to null and 0', () {
      final json = _pricingJsonWithItems([
        {
          'id': 'item-3',
          'item_type': 2,
          'product_id': 'prod-3',
          'name': 'Add-on',
          'qty': 2,
          'frequency': 1,
          'unit_cost': 10000.0,
          'line_total': 20000.0,
        },
      ]);

      final item = PricingDetailDto.fromJson(json).items.first;
      expect(item.actualQty, isNull);
      expect(item.addonKind, 0);

      final entity = PricingDetailDto.fromJson(json).toEntity().items.first;
      expect(entity.actualQty, isNull);
      expect(entity.addonKind, 0);
    });

    test(
      'supply with only treatment_method_id keeps the id; treatment_method object supplies id too',
      () {
        final idOnly = PricingDetailSupplyDto.fromJson({
          'id': 'sup-a',
          'supply_type': 1,
          'name': 'Chemical',
          'uom_code': 'LTR',
          'qty': 1,
          'frequency': 1,
          'unit_cost': 1.0,
          'line_total': 1.0,
          'treatment_method_id': 'tm-9',
        });
        expect(idOnly.treatmentMethodId, 'tm-9');
        expect(idOnly.treatmentMethodName, isNull);
        expect(idOnly.treatmentMethodCode, isNull);

        final withObject = PricingDetailSupplyDto.fromJson({
          'id': 'sup-b',
          'supply_type': 1,
          'name': 'Chemical',
          'uom_code': 'LTR',
          'qty': 1,
          'frequency': 1,
          'unit_cost': 1.0,
          'line_total': 1.0,
          'treatment_method': {'id': 'tm-10', 'code': 'CF', 'name': 'Cold Fog'},
        });
        expect(withObject.treatmentMethodId, 'tm-10');
        expect(withObject.treatmentMethodCode, 'CF');
        expect(withObject.treatmentMethodName, 'Cold Fog');
      },
    );
  });
}

Map<String, dynamic> _pricingJsonWithItems(List<Map<String, dynamic>> items) =>
    {
      'id': 'p-items',
      'customer_id': 'c-items',
      'service_id': 's-items',
      'contract_months': 12,
      'visit_frequency': 1,
      'total_visits': 12,
      'markup_type': 1,
      'markup_value': 0.0,
      'discount_amount': 0.0,
      'tax_percentage': 11.0,
      'supplies': <Map<String, dynamic>>[],
      'workers': <Map<String, dynamic>>[],
      'items': items,
    };
