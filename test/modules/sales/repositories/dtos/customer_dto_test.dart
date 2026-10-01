import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/customer_dto.dart';

void main() {
  group('Customer DTOs', () {
    test('CustomerListItemDto fromJson and toEntity', () {
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'code': 'CUST-001',
        'name': 'Villa Bali Resort',
        'initials': 'VB',
        'segment_id': '660e8400-e29b-41d4-a716-446655440001',
        'segment': 'Hospitality',
        'status': 'active',
        'npwp_number': '12.345.678.0-123.456',
        'phone': '+62-361-123-4567',
        'email': 'info@villabali.example.com',
        'scan_code': 'VC-550e8400-e29b',
        'active_proposals_count': 2,
        'active_contracts_count': 0,
        'created_at': '2025-06-15T10:30:00Z',
        'updated_at': '2025-08-18T14:22:30Z',
      };

      final dto = CustomerListItemDto.fromJson(json);
      expect(dto.name, 'Villa Bali Resort');
      expect(dto.activeProposalsCount, 2);

      final entity = dto.toEntity();
      expect(entity.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(entity.name, 'Villa Bali Resort');
      expect(entity.segmentId, '660e8400-e29b-41d4-a716-446655440001');
      expect(entity.activeProposalsCount, 2);
    });

    test('CustomerLocationDto fromJson and toEntity', () {
      final json = {
        'id': '880e8400-e29b-41d4-a716-446655440003',
        'customer_id': '550e8400-e29b-41d4-a716-446655440000',
        'is_primary': true,
        'label': 'Main Resort',
        'address_line': 'Jalan Pantai Kuta, Kuta, Bali',
        'village': 'Kuta',
        'district': 'Kuta',
        'regency': 'Badung',
        'province': 'Bali',
        'area_size': 25000.5,
        'latitude': -8.6500,
        'longitude': 115.1700,
      };

      final dto = CustomerLocationDto.fromJson(json);
      expect(dto.label, 'Main Resort');
      expect(dto.areaSize, 25000.5);

      final entity = dto.toEntity();
      expect(entity.isPrimary, true);
      expect(entity.address, 'Jalan Pantai Kuta, Kuta, Bali');
      expect(entity.area, '25000.5 m²');
      expect(entity.coords, '-8.65, 115.17');
    });

    test(
      'CustomerLocationDto fromJson and toEntity with region {id, name} objects',
      () {
        final json = {
          'id': '880e8400-e29b-41d4-a716-446655440003',
          'customer_id': '550e8400-e29b-41d4-a716-446655440000',
          'is_primary': true,
          'label': 'Main Resort',
          'address_line': 'Jalan Pantai Kuta, Kuta, Bali',
          'village': {'id': 5103040001, 'name': 'Kuta'},
          'district': {'id': 5103040, 'name': 'Kuta'},
          'regency': {'id': 5103, 'name': 'Badung'},
          'province': {'id': 51, 'name': 'Bali'},
          'area_size': 25000.5,
          'latitude': -8.6500,
          'longitude': 115.1700,
        };

        final dto = CustomerLocationDto.fromJson(json);
        expect(dto.provinceId, 51);
        expect(dto.province, 'Bali');
        expect(dto.regencyId, 5103);
        expect(dto.regency, 'Badung');
        expect(dto.districtId, 5103040);
        expect(dto.district, 'Kuta');
        expect(dto.villageId, 5103040001);
        expect(dto.village, 'Kuta');

        final entity = dto.toEntity();
        expect(entity.provinceId, 51);
        expect(entity.province, 'Bali');
        expect(entity.regencyId, 5103);
        expect(entity.regency, 'Badung');
        expect(entity.districtId, 5103040);
        expect(entity.district, 'Kuta');
        expect(entity.villageId, 5103040001);
        expect(entity.village, 'Kuta');
      },
    );

    test(
      'CustomerLocationDto handles generic Map<dynamic, dynamic> with string and int IDs',
      () {
        final Map<dynamic, dynamic> genericRegency = <dynamic, dynamic>{
          'id': '5103',
          'name': 'Badung',
        };
        final Map<dynamic, dynamic> genericDistrict = <dynamic, dynamic>{
          'id': 5103040,
          'name': 'Kuta',
        };
        final Map<dynamic, dynamic> genericVillage = <dynamic, dynamic>{
          'id': '5103040001',
          'name': 'Kuta',
        };

        final json = <String, dynamic>{
          'is_primary': true,
          'label': 'Branch',
          'address_line': 'Jl. Kuta',
          'province': <dynamic, dynamic>{'id': 51, 'name': 'Bali'},
          'regency': genericRegency,
          'district': genericDistrict,
          'village': genericVillage,
        };

        final dto = CustomerLocationDto.fromJson(json);
        expect(dto.provinceId, 51);
        expect(dto.province, 'Bali');
        expect(dto.regencyId, 5103);
        expect(dto.regency, 'Badung');
        expect(dto.districtId, 5103040);
        expect(dto.district, 'Kuta');
        expect(dto.villageId, 5103040001);
        expect(dto.village, 'Kuta');
      },
    );

    test('CustomerLocationDto resolves fallback alias keys', () {
      final json = <String, dynamic>{
        'is_primary': false,
        'label': 'Fallback Office',
        'address_line': 'Jl. Diponegoro',
        'province_name': 'Jawa Timur',
        'province_id': 35,
        'city': {'id': 3578, 'name': 'Surabaya'},
        'city_id': 3578,
        'kecamatan': 'Gubeng',
        'kecamatan_id': 3578010,
        'subdistrict': {'id': 3578010001, 'name': 'Airlangga'},
        'subdistrict_id': 3578010001,
      };

      final dto = CustomerLocationDto.fromJson(json);
      expect(dto.province, 'Jawa Timur');
      expect(dto.provinceId, 35);
      expect(dto.regency, 'Surabaya');
      expect(dto.regencyId, 3578);
      expect(dto.district, 'Gubeng');
      expect(dto.districtId, 3578010);
      expect(dto.village, 'Airlangga');
      expect(dto.villageId, 3578010001);
    });

    test(
      'CustomerLocationDto resolves additional alias keys (kabupaten, kelurahan, desa)',
      () {
        final json = <String, dynamic>{
          'is_primary': false,
          'label': 'Rural Office',
          'address_line': 'Jl. Pedesaan',
          'province_name': 'Jawa Barat',
          'province_id': '32',
          'kabupaten': 'Bandung Barat',
          'kabupaten_id': '3217',
          'district_name': 'Lembang',
          'district_id': '3217010',
          'kelurahan': 'Kayuambon',
          'kelurahan_id': '3217010005',
        };

        final dto = CustomerLocationDto.fromJson(json);
        expect(dto.province, 'Jawa Barat');
        expect(dto.provinceId, 32);
        expect(dto.regency, 'Bandung Barat');
        expect(dto.regencyId, 3217);
        expect(dto.district, 'Lembang');
        expect(dto.districtId, 3217010);
        expect(dto.village, 'Kayuambon');
        expect(dto.villageId, 3217010005);
      },
    );

    test(
      'CustomerLocationDto parses numeric string IDs in json root fields',
      () {
        final json = <String, dynamic>{
          'is_primary': false,
          'label': 'String IDs',
          'address_line': 'Jl. Angka',
          'province': 'Bali',
          'province_id': '51',
          'regency': 'Badung',
          'regency_id': '5103',
          'district': 'Kuta',
          'district_id': '5103040',
          'village': 'Kuta',
          'village_id': '5103040001',
        };

        final dto = CustomerLocationDto.fromJson(json);
        expect(dto.provinceId, 51);
        expect(dto.regencyId, 5103);
        expect(dto.districtId, 5103040);
        expect(dto.villageId, 5103040001);
      },
    );

    test('CustomerContactDto fromJson and toEntity', () {
      final json = {
        'id': 'aa0e8400-e29b-41d4-a716-446655440005',
        'customer_id': '550e8400-e29b-41d4-a716-446655440000',
        'name': 'Budi Santoso',
        'position': 'General Manager',
        'email': 'budi@villabali.example.com',
        'phone': '+62-361-123-4567',
        'role': 'pic',
        'is_primary': true,
      };

      final dto = CustomerContactDto.fromJson(json);
      expect(dto.name, 'Budi Santoso');
      expect(dto.role, 'pic');

      final entity = dto.toEntity();
      expect(entity.initials, 'BS');
      expect(entity.roleBadge, 'brand');
      expect(entity.displayRole, 'PIC');
    });

    test('CustomerProposalDto fromJson and toEntity', () {
      final json = {
        'id': 'dd0e8400-e29b-41d4-a716-446655440008',
        'customer_id': '550e8400-e29b-41d4-a716-446655440000',
        'code': 'PROP-2025-001',
        'service': {
          'id': 'ee0e8400-e29b-41d4-a716-446655440009',
          'name': 'Pest Control Monthly',
        },
        'proposal_date': '2025-08-10',
        'valid_until': '2025-09-10',
        'total_amount': 5000000.00,
        'status': 'sent',
      };

      final dto = CustomerProposalDto.fromJson(json);
      expect(dto.service.name, 'Pest Control Monthly');

      final entity = dto.toEntity();
      expect(entity.title, 'Pest Control Monthly');
      expect(entity.amount, 'Rp 5.000.000');
      expect(entity.badgeType, 'info');
    });

    test('CustomerDetailDto fromJson and toEntity', () {
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'code': 'CUST-001',
        'name': 'Villa Bali Resort',
        'initials': 'VB',
        'segment_id': '660e8400-e29b-41d4-a716-446655440001',
        'segment': 'Hospitality',
        'status': 'active',
        'npwp_number': '12.345.678.0-123.456',
        'phone': '+62-361-123-4567',
        'phone_alt': '+62-361-123-4568',
        'email': 'info@villabali.example.com',
        'scan_code': 'VC-550e8400-e29b',
        'risk_notes': 'Risk note',
        'notes': 'Operational note',
        'active_proposals_count': 1,
        'active_contracts_count': 0,
        'created_at': '2025-06-15T10:30:00Z',
        'updated_at': '2025-08-18T14:22:30Z',
        'locations': [
          {
            'id': 'loc-1',
            'is_primary': true,
            'label': 'Main',
            'address_line': 'Seminyak',
            'regency': 'Badung',
          },
        ],
        'contacts': [
          {'id': 'con-1', 'name': 'Budi', 'role': 'pic', 'is_primary': true},
        ],
        'proposals': [
          {
            'id': 'prop-1',
            'code': 'PROP-1',
            'service': {'id': 's1', 'name': 'Pest Control'},
            'proposal_date': '2025-08-10',
            'total_amount': 1000000,
            'status': 'sent',
          },
        ],
      };

      final dto = CustomerDetailDto.fromJson(json);
      final entity = dto.toEntity();
      expect(entity.name, 'Villa Bali Resort');
      expect(entity.locations.length, 1);
      expect(entity.contacts.length, 1);
      expect(entity.proposals.length, 1);
      expect(entity.regency, 'Badung');
    });

    test('CreateCustomerRequestDto from input creates correct payload', () {
      const input = CreateCustomerInput(
        name: 'Resto Mewah',
        segmentId: 'seg-1',
        locations: [
          CreateLocationInput(
            label: 'Main',
            address: 'Jl. Sudirman',
            provinceId: 1,
            regencyId: 2,
            districtId: 3,
            villageId: 4,
            areaSize: 100,
          ),
        ],
        contacts: [
          CreateContactInput(name: 'Andi', role: 'pic', isPrimary: true),
        ],
      );

      final requestDto = CreateCustomerRequestDto.fromInput(input);
      final json = requestDto.toJson();

      expect(json['name'], 'Resto Mewah');
      expect(json['segment_id'], 'seg-1');
      expect(json['locations'], isA<List<dynamic>>());
      final locJson = (json['locations'] as List).first as Map<String, dynamic>;
      expect(locJson['province_id'], 1);
      expect(locJson['regency_id'], 2);

      final contactJson =
          (json['contacts'] as List).first as Map<String, dynamic>;
      expect(contactJson['name'], 'Andi');
      expect(contactJson['role'], 1);
    });

    test(
      'UpdateCustomerRequestDto from input creates correct payload without code and with status',
      () {
        const input = CreateCustomerInput(
          name: 'Resto Mewah Updated',
          code: 'IMMUTABLE-CODE',
          status: 'inactive',
          segmentId: 'seg-1',
          locations: [
            CreateLocationInput(
              label: 'Main',
              address: 'Jl. Sudirman',
              provinceId: 1,
              regencyId: 2,
              districtId: 3,
              villageId: 4,
              areaSize: 100,
            ),
          ],
          contacts: [
            CreateContactInput(name: 'Andi', role: 'pic', isPrimary: true),
          ],
        );

        final requestDto = UpdateCustomerRequestDto.fromInput(input);
        final json = requestDto.toJson();

        expect(json['name'], 'Resto Mewah Updated');
        expect(json['segment_id'], 'seg-1');
        expect(json['status'], 'inactive');
        expect(json.containsKey('code'), false);
        expect(json['locations'], isA<List<dynamic>>());
        final locJson =
            (json['locations'] as List).first as Map<String, dynamic>;
        expect(locJson['province_id'], 1);
        expect(locJson['regency_id'], 2);

        final contactJson =
            (json['contacts'] as List).first as Map<String, dynamic>;
        expect(contactJson['name'], 'Andi');
        expect(contactJson['role'], 1);
      },
    );

    test('CreateCustomerResponseDto fromJson and toEntity', () {
      final json = {
        'id': 'cust-new',
        'code': 'CUST-NEW',
        'name': 'Customer New',
        'initials': 'CN',
        'segment': 'F&B',
        'status': 'active',
        'created_at': '2025-08-18T15:30:45Z',
      };

      final dto = CreateCustomerResponseDto.fromJson(json);
      final entity = dto.toEntity();
      expect(entity.id, 'cust-new');
      expect(entity.code, 'CUST-NEW');
      expect(entity.name, 'Customer New');
      expect(entity.initials, 'CN');
      expect(entity.segment, 'F&B');
      expect(entity.status, 'active');
    });

    group('CreateLocationInput SRA fields', () {
      test('toJson includes site_risk_ids and custom_risks when non-empty', () {
        const input = CreateLocationInput(
          label: 'Gudang',
          address: 'Jl. Industri No. 5',
          siteRiskIds: ['risk-1', 'risk-2'],
          customRisks: ['Slippery Floor', 'High Voltage'],
        );

        final json = input.toJson();
        expect(json['site_risk_ids'], ['risk-1', 'risk-2']);
        expect(json['custom_risks'], ['Slippery Floor', 'High Voltage']);
      });

      test('toJson omits site_risk_ids and custom_risks when empty', () {
        const input = CreateLocationInput(
          label: 'Gudang',
          address: 'Jl. Industri No. 5',
        );

        final json = input.toJson();
        expect(json.containsKey('site_risk_ids'), isFalse);
        expect(json.containsKey('custom_risks'), isFalse);
      });

      test('copyWith, equality, hashCode, and toString include SRA fields', () {
        const input1 = CreateLocationInput(
          label: 'Kantor',
          siteRiskIds: ['risk-1'],
          customRisks: ['Risk A'],
        );

        final input2 = input1.copyWith(
          siteRiskIds: ['risk-1', 'risk-2'],
          customRisks: ['Risk A', 'Risk B'],
        );

        expect(input2.siteRiskIds, ['risk-1', 'risk-2']);
        expect(input2.customRisks, ['Risk A', 'Risk B']);

        const input3 = CreateLocationInput(
          label: 'Kantor',
          siteRiskIds: ['risk-1'],
          customRisks: ['Risk A'],
        );

        expect(input1, equals(input3));
        expect(input1.hashCode, equals(input3.hashCode));
        expect(input1, isNot(equals(input2)));
        expect(input1.toString(), contains('siteRiskIds: [risk-1]'));
        expect(input1.toString(), contains('customRisks: [Risk A]'));
      });
    });

    group('CreateCustomerLocationRequestDto SRA and sanitization', () {
      test('toJson serializes siteRiskIds and customRisks when provided', () {
        const dto = CreateCustomerLocationRequestDto(
          label: 'Site A',
          siteRiskIds: ['risk-1'],
          customRisks: ['Chemical spill'],
        );

        final json = dto.toJson();
        expect(json['site_risk_ids'], ['risk-1']);
        expect(json['custom_risks'], ['Chemical spill']);
      });

      test('toJson serializes empty lists if explicitly passed', () {
        const dto = CreateCustomerLocationRequestDto(
          label: 'Site A',
          siteRiskIds: [],
          customRisks: [],
        );

        final json = dto.toJson();
        expect(json['site_risk_ids'], isEmpty);
        expect(json['custom_risks'], isEmpty);
      });

      test(
        'fromInput omits SRA keys when both siteRiskIds and customRisks are empty',
        () {
          const input = CreateLocationInput(
            label: 'Untouched Location',
            address: 'Jl. Damai',
            siteRiskIds: [],
            customRisks: [],
          );

          final dto = CreateCustomerLocationRequestDto.fromInput(input);
          expect(dto.siteRiskIds, isNull);
          expect(dto.customRisks, isNull);

          final json = dto.toJson();
          expect(json.containsKey('site_risk_ids'), isFalse);
          expect(json.containsKey('custom_risks'), isFalse);
        },
      );

      test(
        'fromInput sanitizes customRisks: trims, filters empty, and caps at 255 chars',
        () {
          final longRisk = 'a' * 300;
          final input = CreateLocationInput(
            label: 'Factory',
            siteRiskIds: const ['risk-1'],
            customRisks: ['  Trimmed Risk  ', '   ', '', longRisk],
          );

          final dto = CreateCustomerLocationRequestDto.fromInput(input);
          expect(dto.siteRiskIds, ['risk-1']);
          expect(dto.customRisks, hasLength(2));
          expect(dto.customRisks![0], 'Trimmed Risk');
          expect(dto.customRisks![1].length, 255);
          expect(dto.customRisks![1], 'a' * 255);

          final json = dto.toJson();
          expect(json['site_risk_ids'], ['risk-1']);
          expect(json['custom_risks'], ['Trimmed Risk', 'a' * 255]);
        },
      );

      test(
        'fromInput passes empty list for omitted risk field when the other has risks',
        () {
          // Only siteRiskIds provided
          const inputWithSiteOnly = CreateLocationInput(
            label: 'Site Only',
            siteRiskIds: ['risk-10'],
          );
          final dtoSiteOnly = CreateCustomerLocationRequestDto.fromInput(
            inputWithSiteOnly,
          );
          expect(dtoSiteOnly.siteRiskIds, ['risk-10']);
          expect(dtoSiteOnly.customRisks, isEmpty);

          final jsonSiteOnly = dtoSiteOnly.toJson();
          expect(jsonSiteOnly['site_risk_ids'], ['risk-10']);
          expect(jsonSiteOnly['custom_risks'], isEmpty);

          // Only customRisks provided
          const inputWithCustomOnly = CreateLocationInput(
            label: 'Custom Only',
            customRisks: ['Custom Risk 1'],
          );
          final dtoCustomOnly = CreateCustomerLocationRequestDto.fromInput(
            inputWithCustomOnly,
          );
          expect(dtoCustomOnly.siteRiskIds, isEmpty);
          expect(dtoCustomOnly.customRisks, ['Custom Risk 1']);

          final jsonCustomOnly = dtoCustomOnly.toJson();
          expect(jsonCustomOnly['site_risk_ids'], isEmpty);
          expect(jsonCustomOnly['custom_risks'], ['Custom Risk 1']);
        },
      );
    });

    group(
      'CreateCustomerRequestDto & UpdateCustomerRequestDto tax_percentage serialization',
      () {
        test(
          'CreateCustomerRequestDto serializes tax_percentage when positive',
          () {
            const input = CreateCustomerInput(
              name: 'Customer Tax Test',
              segmentId: 'seg-1',
              taxPercentage: 11.0,
              locations: [
                CreateLocationInput(
                  label: 'Main HQ',
                  siteRiskIds: ['risk-1'],
                  customRisks: ['Hazard A'],
                ),
              ],
            );

            final dto = CreateCustomerRequestDto.fromInput(input);
            final json = dto.toJson();

            expect(json['tax_percentage'], 11.0);
            final loc =
                (json['locations'] as List).first as Map<String, dynamic>;
            expect(loc['site_risk_ids'], ['risk-1']);
            expect(loc['custom_risks'], ['Hazard A']);
          },
        );

        test('CreateCustomerRequestDto omits tax_percentage when zero', () {
          const input = CreateCustomerInput(
            name: 'Customer Zero Tax',
            segmentId: 'seg-1',
            taxPercentage: 0.0,
          );

          final dto = CreateCustomerRequestDto.fromInput(input);
          final json = dto.toJson();

          expect(json.containsKey('tax_percentage'), isFalse);
        });

        test(
          'UpdateCustomerRequestDto serializes tax_percentage when positive',
          () {
            const input = CreateCustomerInput(
              name: 'Customer Tax Update',
              segmentId: 'seg-1',
              taxPercentage: 12.5,
              locations: [
                CreateLocationInput(
                  label: 'Branch 1',
                  siteRiskIds: ['risk-99'],
                ),
              ],
            );

            final dto = UpdateCustomerRequestDto.fromInput(input);
            final json = dto.toJson();

            expect(json['tax_percentage'], 12.5);
            final loc =
                (json['locations'] as List).first as Map<String, dynamic>;
            expect(loc['site_risk_ids'], ['risk-99']);
            expect(loc['custom_risks'], isEmpty);
          },
        );

        test('UpdateCustomerRequestDto omits tax_percentage when zero', () {
          const input = CreateCustomerInput(
            name: 'Customer Update Zero Tax',
            segmentId: 'seg-1',
            taxPercentage: 0.0,
          );

          final dto = UpdateCustomerRequestDto.fromInput(input);
          final json = dto.toJson();

          expect(json.containsKey('tax_percentage'), isFalse);
        });
      },
    );
  });
}
