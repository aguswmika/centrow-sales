import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/site_risk_dto.dart';

void main() {
  group('SiteRiskMasterDto', () {
    test('parses json correctly and converts to entity', () {
      final json = {
        'id': '0192a3c4-1111-7000-8000-000000000001',
        'name': 'Area kerja terdapat lalu-lalang kendaraan/orang',
      };
      final dto = SiteRiskMasterDto.fromJson(json);

      expect(dto.id, '0192a3c4-1111-7000-8000-000000000001');
      expect(dto.name, 'Area kerja terdapat lalu-lalang kendaraan/orang');

      final entity = dto.toEntity();
      expect(entity.id, dto.id);
      expect(entity.name, dto.name);
    });

    test('parses list response from nested data map', () {
      final json = {
        'data': {
          'items': [
            {'id': '0192a3c4-1111-7000-8000-000000000001', 'name': 'Risk 1'},
            {'id': '0192a3c4-1111-7000-8000-000000000002', 'name': 'Risk 2'},
          ],
        },
        'is_error': false,
        'http_status': 200,
      };

      final listDto = SiteRiskMasterListResponseDto.fromJson(json);
      expect(listDto.items.length, 2);
      expect(listDto.items[0].name, 'Risk 1');
      expect(listDto.items[1].name, 'Risk 2');
    });
  });

  group('CustomerAddressRiskDto', () {
    test('parses master and custom risks correctly', () {
      final jsonMaster = {
        'id': '0192a3c4-2222-7000-8000-000000000001',
        'site_risk_id': '0192a3c4-1111-7000-8000-000000000005',
        'name': 'Bekerja di area ketinggian',
        'is_custom': false,
      };

      final masterDto = CustomerAddressRiskDto.fromJson(jsonMaster);
      expect(masterDto.id, '0192a3c4-2222-7000-8000-000000000001');
      expect(masterDto.siteRiskId, '0192a3c4-1111-7000-8000-000000000005');
      expect(masterDto.name, 'Bekerja di area ketinggian');
      expect(masterDto.isCustom, false);

      final masterEntity = masterDto.toEntity();
      expect(masterEntity.isCustom, false);
      expect(masterEntity.siteRiskId, '0192a3c4-1111-7000-8000-000000000005');

      final jsonCustom = {
        'id': '0192a3c4-2222-7000-8000-000000000002',
        'site_risk_id': null,
        'name': 'Anjing galak di halaman belakang',
        'is_custom': true,
      };

      final customDto = CustomerAddressRiskDto.fromJson(jsonCustom);
      expect(customDto.siteRiskId, isNull);
      expect(customDto.isCustom, true);
    });

    test('parses address risk list response', () {
      final json = {
        'data': {
          'items': [
            {
              'id': '0192a3c4-2222-7000-8000-000000000001',
              'site_risk_id': '0192a3c4-1111-7000-8000-000000000005',
              'name': 'Bekerja di area ketinggian',
              'is_custom': false,
            },
          ],
        },
        'is_error': false,
        'http_status': 200,
      };

      final listDto = CustomerAddressRiskListResponseDto.fromJson(json);
      expect(listDto.items.length, 1);
      expect(listDto.items.first.name, 'Bekerja di area ketinggian');
    });
  });

  group('UpdateAddressRisksPayload', () {
    test('serializes to json map correctly', () {
      const payload = UpdateAddressRisksPayload(
        siteRiskIds: ['id-1', 'id-2'],
        customRisks: ['Hazard 1'],
      );

      final map = payload.toJson();
      expect(map['site_risk_ids'], ['id-1', 'id-2']);
      expect(map['custom_risks'], ['Hazard 1']);
    });
  });
}
