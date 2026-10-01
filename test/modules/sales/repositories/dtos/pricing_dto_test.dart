import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_detail_dto.dart';

void main() {
  group('Pricing DTOs', () {
    test(
      'CreatePricingRequestDto toJson serializes correctly with snake_case keys and new supply fields',
      () {
        const supply = PricingSupplyDto(
          supplyType: 1,
          productMappingId: 'pm1',
          name: 'Chemical A',
          uomCode: 'BTL',
          doseUsage: 2.0,
          doseUnitId: 'uom-ml',
          applicationVolume: 10.0,
          applicationVolumeUnitId: 'uom-l',
          frequency: 2,
          treatmentMethodId: 'tm-1',
          areaKerja: 'Kitchen',
          note: 'Handle with care',
        );

        const tool = PricingSupplyDto(
          supplyType: 2,
          productId: 'p-tool',
          name: 'Sprayer',
          uomCode: 'UNIT',
          qty: 1.0,
          frequency: 1,
          treatmentMethodId: 'tm-2',
          areaKerja: 'Lobby',
          note: 'Wall mount',
          installedUnits: 2,
        );

        const worker = PricingWorkerDto(
          productId: 'prod-tech',
          firstVisitMinutes: 120.0,
          routineMinutes: 90.0,
        );

        const item = PricingItemDto(
          itemType: 1,
          productId: 'p2',
          name: 'Equipment B',
          qty: 1.0,
          frequency: 1,
          unitPrice: 150000.0,
        );

        const request = CreatePricingRequestDto(
          contractMonths: 12,
          visitFrequency: 4,
          totalVisits: 48,
          markupType: 1,
          markupValue: 20.0,
          discountAmount: 10000.0,
          taxPercentage: 11.0,
          scheduleWorkOrderType: 2,
          supplies: [supply, tool],
          workers: [worker],
          items: [item],
        );

        final json = request.toJson();

        expect(json['contract_months'], 12);
        expect(json['visit_frequency'], 4);
        expect(json['total_visits'], 48);
        expect(json['markup_type'], 1);
        expect(json['markup_value'], 20.0);
        expect(json['discount_amount'], 10000.0);
        expect(json['tax_percentage'], 11.0);
        expect(json['schedule_work_order_type'], 2);
        expect(json.containsKey('treatment_quotas'), isFalse);

        final suppliesList = json['supplies'] as List<dynamic>;
        expect(suppliesList.length, 2);
        expect(suppliesList[0], {
          'supply_type': 1,
          'product_mapping_id': 'pm1',
          'name': 'Chemical A',
          'uom_code': 'BTL',
          'dose_usage': 2.0,
          'dose_unit_id': 'uom-ml',
          'application_volume': 10.0,
          'application_volume_unit_id': 'uom-l',
          'frequency': 2,
          'treatment_method_id': 'tm-1',
          'area_kerja': 'Kitchen',
          'note': 'Handle with care',
        });
        expect(suppliesList[1], {
          'supply_type': 2,
          'product_id': 'p-tool',
          'name': 'Sprayer',
          'uom_code': 'UNIT',
          'qty': 1.0,
          'frequency': 1,
          'treatment_method_id': 'tm-2',
          'area_kerja': 'Lobby',
          'note': 'Wall mount',
          'installed_units': 2,
        });

        final workersList = json['workers'] as List<dynamic>;
        expect(workersList.length, 1);
        expect(workersList[0], {
          'product_id': 'prod-tech',
          'first_visit_minutes': 120.0,
          'routine_minutes': 90.0,
        });

        final itemsList = json['items'] as List<dynamic>;
        expect(itemsList.length, 1);
        expect(itemsList[0], {
          'item_type': 1,
          'product_id': 'p2',
          'name': 'Equipment B',
          'qty': 1.0,
          'frequency': 1,
          'unit_price': 150000.0,
        });
      },
    );
  });

  group('PricingSupplyDto.toJson() — spk_dose_usage / actual_dosage_usage', () {
    test(
      'chemical supply with spkDoseUsage emits both actual_dosage_usage and spk_dose_usage in toJson',
      () {
        const dto = PricingSupplyDto(
          supplyType: 1,
          productMappingId: 'pm-chem',
          name: 'Chemical B',
          uomCode: 'ML',
          doseUsage: 2.0,
          doseUnitId: 'uom-ml',
          applicationVolume: 5.0,
          applicationVolumeUnitId: 'uom-l',
          frequency: 1,
          actualDosageUsage: 60.0,
        );

        final json = dto.toJson();
        expect(json.containsKey('actual_dosage_usage'), isTrue);
        expect(json['actual_dosage_usage'], 60.0);
        expect(json.containsKey('spk_dose_usage'), isTrue);
        expect(json['spk_dose_usage'], 60.0);
        expect(dto.spkDoseUsage, 60.0);
      },
    );

    test(
      'chemical supply with null spkDoseUsage does NOT emit actual_dosage_usage or spk_dose_usage',
      () {
        const dto = PricingSupplyDto(
          supplyType: 1,
          productMappingId: 'pm-chem2',
          name: 'Chemical C',
          uomCode: 'ML',
          doseUsage: 1.5,
          doseUnitId: 'uom-ml',
          applicationVolume: 3.0,
          applicationVolumeUnitId: 'uom-l',
          frequency: 2,
          spkDoseUsage: null,
        );

        final json = dto.toJson();
        expect(json.containsKey('actual_dosage_usage'), isFalse);
        expect(json.containsKey('spk_dose_usage'), isFalse);
      },
    );

    test(
      'tool supply does NOT emit actual_dosage_usage or spk_dose_usage even if spkDoseUsage is non-null',
      () {
        const dto = PricingSupplyDto(
          supplyType: 2,
          productId: 'p-trap',
          name: 'Rodent Trap',
          uomCode: 'PCS',
          qty: 5.0,
          frequency: 1,
          installedUnits: 5,
          spkDoseUsage: 99.0,
        );

        final json = dto.toJson();
        expect(json.containsKey('actual_dosage_usage'), isFalse);
        expect(json.containsKey('spk_dose_usage'), isFalse);
      },
    );
  });

  group(
    'PricingDetailSupplyDto.fromJson() — actual_dosage_usage / spk_dose_usage & unit names',
    () {
      test(
        'maps actual_dosage_usage and unit names to entity when present',
        () {
          final json = <String, dynamic>{
            'id': 'sup-1',
            'supply_type': 1,
            'name': 'Chemical X',
            'uom_code': 'ML',
            'uom_name': 'Mililiter',
            'qty': 10,
            'dose_usage': 2.0,
            'dose_unit_id': 'uom-ml',
            'dose_unit_code': 'ML',
            'dose_unit_name': 'Mililiter',
            'application_volume': 5.0,
            'application_volume_unit_id': 'uom-l',
            'application_volume_unit_code': 'LTR',
            'application_volume_unit_name': 'Liter',
            'frequency': 2,
            'unit_cost': 5000.0,
            'line_total': 10000.0,
            'actual_dosage_usage': 60.0,
            'treatment_method_id': 'tm-1',
            'treatment_method_name': 'Penyemprotan',
            'treatment_method_code': 'SPRAY',
          };

          final dto = PricingDetailSupplyDto.fromJson(json);
          expect(dto.actualDosageUsage, 60.0);
          expect(dto.spkDoseUsage, 60.0);
          expect(dto.uomName, 'Mililiter');
          expect(dto.doseUnitName, 'Mililiter');
          expect(dto.applicationVolumeUnitName, 'Liter');
          expect(dto.treatmentMethodName, 'Penyemprotan');

          final entity = dto.toEntity();
          expect(entity.actualDosageUsage, 60.0);
          expect(entity.spkDoseUsage, 60.0);
          expect(entity.uomName, 'Mililiter');
          expect(entity.doseUnitName, 'Mililiter');
          expect(entity.applicationVolumeUnitName, 'Liter');
          expect(entity.treatmentMethodName, 'Penyemprotan');
        },
      );

      test(
        'maps legacy spk_dose_usage to entity when actual_dosage_usage is absent',
        () {
          final json = <String, dynamic>{
            'id': 'sup-1',
            'supply_type': 1,
            'name': 'Chemical X',
            'uom_code': 'ML',
            'qty': 10,
            'dose_usage': 2.0,
            'dose_unit_id': 'uom-ml',
            'application_volume': 5.0,
            'application_volume_unit_id': 'uom-l',
            'frequency': 2,
            'unit_cost': 5000.0,
            'line_total': 10000.0,
            'spk_dose_usage': 60.0,
          };

          final dto = PricingDetailSupplyDto.fromJson(json);
          expect(dto.spkDoseUsage, 60.0);
          expect(dto.actualDosageUsage, 60.0);

          final entity = dto.toEntity();
          expect(entity.spkDoseUsage, 60.0);
          expect(entity.actualDosageUsage, 60.0);
        },
      );

      test(
        'maps null actual_dosage_usage to entity.actualDosageUsage == null when absent',
        () {
          final json = <String, dynamic>{
            'id': 'sup-2',
            'supply_type': 1,
            'name': 'Chemical Y',
            'uom_code': 'ML',
            'qty': 5,
            'dose_usage': 1.0,
            'dose_unit_id': 'uom-ml',
            'application_volume': 1.0,
            'application_volume_unit_id': 'uom-l',
            'frequency': 1,
            'unit_cost': 3000.0,
            'line_total': 3000.0,
          };

          final dto = PricingDetailSupplyDto.fromJson(json);
          expect(dto.spkDoseUsage, isNull);
          expect(dto.actualDosageUsage, isNull);

          final entity = dto.toEntity();
          expect(entity.spkDoseUsage, isNull);
          expect(entity.actualDosageUsage, isNull);
        },
      );
    },
  );
}
