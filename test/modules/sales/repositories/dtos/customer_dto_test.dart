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
  });
}
