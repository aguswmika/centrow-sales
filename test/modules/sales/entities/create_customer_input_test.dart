import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';

void main() {
  group('CreateCustomerInput Entities', () {
    test('CreateLocationInput instantiation, copyWith, and toJson', () {
      const loc = CreateLocationInput(
        label: 'Main Villa',
        address: 'Jl. Raya Pantai 123',
        provinceId: 6,
        regencyId: 3175,
        districtId: 3175008,
        villageId: 3175008001,
        regency: 'Kabupaten Badung',
        district: 'Kuta',
        village: 'Seminyak',
        areaSize: 500,
        areaUnit: 'm²',
        coords: '-8.123, 115.123',
        latitude: -8.123,
        longitude: 115.123,
        isPrimary: true,
      );

      expect(loc.label, 'Main Villa');
      expect(loc.isPrimary, true);
      expect(loc.provinceId, 6);
      expect(loc.regencyId, 3175);

      final copy = loc.copyWith(label: 'Updated Villa', isPrimary: false);
      expect(copy.label, 'Updated Villa');
      expect(copy.isPrimary, false);
      expect(copy.address, 'Jl. Raya Pantai 123');

      final json = loc.toJson();
      expect(json['label'], 'Main Villa');
      expect(json['is_primary'], true);
      expect(json['area_size'], 500.0);
      expect(json['province_id'], 6);
      expect(json['regency_id'], 3175);
      expect(json['district_id'], 3175008);
      expect(json['village_id'], 3175008001);
      expect(json['latitude'], -8.123);
      expect(json['longitude'], 115.123);
    });

    test('CreateContactInput instantiation, copyWith, and toJson', () {
      const contact = CreateContactInput(
        name: 'Budi Santoso',
        position: 'GM',
        email: 'budi@test.com',
        phone: '+62812345678',
        role: 'Pengambil Keputusan',
        roleBadge: 'brand',
        isPrimary: true,
      );

      expect(contact.name, 'Budi Santoso');
      expect(contact.isPrimary, true);
      expect(contact.roleCode, 1); // PIC

      final copy = contact.copyWith(name: 'Andi', role: 'pic_backup');
      expect(copy.name, 'Andi');
      expect(copy.position, 'GM');
      expect(copy.roleCode, 2);

      final json = contact.toJson();
      expect(json['name'], 'Budi Santoso');
      expect(json['role'], 1);
      expect(json['is_primary'], true);
    });

    test('CreateCustomerInput instantiation and toJson', () {
      const customer = CreateCustomerInput(
        name: 'Villa Sari',
        code: 'CRM-100',
        segmentId: '660e8400-e29b-41d4-a716-446655440001',
        segment: 'Villa',
        regency: 'Badung',
        status: 'Aktif',
        phone: '+6281234',
        locations: [
          CreateLocationInput(label: 'L1', address: 'A1', isPrimary: true),
        ],
        contacts: [
          CreateContactInput(name: 'C1', phone: 'P1', isPrimary: true),
        ],
      );

      expect(customer.name, 'Villa Sari');
      expect(customer.segmentId, '660e8400-e29b-41d4-a716-446655440001');
      expect(customer.locations.length, 1);
      expect(customer.contacts.length, 1);

      final json = customer.toJson();
      expect(json['name'], 'Villa Sari');
      expect(json['segment_id'], '660e8400-e29b-41d4-a716-446655440001');
      expect(json['locations'], isA<List<dynamic>>());
      expect(json['contacts'], isA<List<dynamic>>());
    });
  });
}
