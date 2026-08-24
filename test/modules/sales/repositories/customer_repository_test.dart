import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';

class MockAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler != null) {
      return handler!(options);
    }
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      error: 'No handler set',
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late MockAdapter mockAdapter;
  late CustomerRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.centrow.id/api'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = CustomerRepositoryImpl(dio);
  });

  group('CustomerRepository - getCustomers', () {
    test('getCustomers successfully parses list and pagination', () async {
      mockAdapter.handler = (options) {
        expect(options.path, '/v1/sales/customers');
        expect(options.queryParameters['page'], 1);
        expect(options.queryParameters['page_size'], 20);

        final jsonResponse = {
          'data': {
            'items': [
              {
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
              },
            ],
            'pagination': {'total': 42, 'total_page': 3, 'has_next': true},
          },
          'is_error': false,
          'http_status': 200,
        };

        return ResponseBody.fromString(
          jsonEncode(jsonResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getCustomers();
      expect(result.isOk, true);
      final customers = result.valueOrNull!;
      expect(customers.length, 1);
      final cust = customers.first;
      expect(cust.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(cust.code, 'CUST-001');
      expect(cust.name, 'Villa Bali Resort');
      expect(cust.initials, 'VB');
      expect(cust.segmentId, '660e8400-e29b-41d4-a716-446655440001');
      expect(cust.segment, 'Hospitality');
      expect(cust.status, 'active');
      expect(cust.activeProposalsCount, 2);
      expect(cust.activeContractsCount, 0);
    });

    test('getCustomers correctly passes query parameters', () async {
      mockAdapter.handler = (options) {
        expect(options.queryParameters['page'], 2);
        expect(options.queryParameters['page_size'], 10);
        expect(options.queryParameters['q'], 'Bali');
        expect(options.queryParameters['segment_id'], 'seg-123');
        expect(options.queryParameters['status'], 'active');

        final jsonResponse = {
          'data': {
            'items': <dynamic>[],
            'pagination': {'total': 0, 'total_page': 0, 'has_next': false},
          },
          'is_error': false,
          'http_status': 200,
        };

        return ResponseBody.fromString(
          jsonEncode(jsonResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getCustomers(
        page: 2,
        pageSize: 10,
        query: 'Bali',
        segmentId: 'seg-123',
        status: 'active',
      );
      expect(result.isOk, true);
      expect(result.valueOrNull, isEmpty);
    });

    test('getCustomers returns ServerFailure on 400', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 400,
          'message': 'Parameter tidak valid',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getCustomers();
      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.message, 'Parameter tidak valid');
      expect(result.failureOrNull?.statusCode, 400);
    });

    test('getCustomers returns ServerFailure on 500', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 500,
          'message': 'Internal server error',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getCustomers();
      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.statusCode, 500);
    });

    test('getCustomers returns NetworkFailure on connection timeout', () async {
      mockAdapter.handler = (options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      };

      final result = await repository.getCustomers();
      expect(result.isErr, true);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });

  group('CustomerRepository - getCustomerById', () {
    test(
      'getCustomerById returns full customer detail with locations, contacts, proposals',
      () async {
        const customerId = '550e8400-e29b-41d4-a716-446655440000';

        mockAdapter.handler = (options) {
          expect(options.path, '/v1/sales/customers/$customerId');

          final jsonResponse = {
            'data': {
              'id': customerId,
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
              'risk_notes': 'Monitor payment patterns closely',
              'notes': 'Preferred vendor for group bookings',
              'active_proposals_count': 2,
              'active_contracts_count': 0,
              'created_at': '2025-06-15T10:30:00Z',
              'updated_at': '2025-08-18T14:22:30Z',
              'locations': [
                {
                  'id': '880e8400-e29b-41d4-a716-446655440003',
                  'customer_id': customerId,
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
                },
              ],
              'contacts': [
                {
                  'id': 'aa0e8400-e29b-41d4-a716-446655440005',
                  'customer_id': customerId,
                  'name': 'Budi Santoso',
                  'position': 'General Manager',
                  'email': 'budi@villabali.example.com',
                  'phone': '+62-361-123-4567',
                  'role': 'pic',
                  'is_primary': true,
                },
              ],
              'proposals': [
                {
                  'id': 'dd0e8400-e29b-41d4-a716-446655440008',
                  'customer_id': customerId,
                  'code': 'PROP-2025-001',
                  'service': {
                    'id': 'ee0e8400-e29b-41d4-a716-446655440009',
                    'name': 'Pest Control Monthly',
                  },
                  'proposal_date': '2025-08-10',
                  'valid_until': '2025-09-10',
                  'total_amount': 5000000.00,
                  'status': 'sent',
                },
              ],
            },
            'is_error': false,
            'http_status': 200,
          };

          return ResponseBody.fromString(
            jsonEncode(jsonResponse),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getCustomerById(customerId);
        expect(result.isOk, true);
        final customer = result.valueOrNull!;
        expect(customer.id, customerId);
        expect(customer.name, 'Villa Bali Resort');
        expect(customer.phoneAlt, '+62-361-123-4568');
        expect(customer.riskNotes, 'Monitor payment patterns closely');
        expect(customer.notes, 'Preferred vendor for group bookings');

        // Locations
        expect(customer.locations.length, 1);
        final loc = customer.locations.first;
        expect(loc.label, 'Main Resort');
        expect(loc.addressLine, 'Jalan Pantai Kuta, Kuta, Bali');
        expect(loc.address, 'Jalan Pantai Kuta, Kuta, Bali');
        expect(loc.isPrimary, true);
        expect(loc.areaSize, 25000.5);
        expect(loc.latitude, -8.6500);
        expect(loc.longitude, 115.1700);

        // Contacts
        expect(customer.contacts.length, 1);
        final contact = customer.contacts.first;
        expect(contact.name, 'Budi Santoso');
        expect(contact.initials, 'BS');
        expect(contact.role, 'pic');
        expect(contact.roleBadge, 'brand');
        expect(contact.isPrimary, true);

        // Proposals
        expect(customer.proposals.length, 1);
        final prop = customer.proposals.first;
        expect(prop.code, 'PROP-2025-001');
        expect(prop.title, 'Pest Control Monthly');
        expect(prop.totalAmount, 5000000.0);
        expect(prop.badgeType, 'info');
      },
    );

    test('getCustomerById returns 404 failure when not found', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 404,
          'message': 'Data tidak ditemukan',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getCustomerById('non-existent-id');
      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.message, 'Data tidak ditemukan');
      expect(result.failureOrNull?.statusCode, 404);
    });
  });

  group('CustomerRepository - createCustomer', () {
    test(
      'createCustomer sends matching contract body and receives basic customer entity',
      () async {
        mockAdapter.handler = (options) {
          expect(options.path, '/v1/sales/customers');
          expect(options.method, 'POST');

          final body = options.data is String
              ? jsonDecode(options.data as String)
              : options.data as Map<String, dynamic>;

          expect(body['name'], 'Restoran Mewah Jakarta');
          expect(body['segment_id'], '660e8400-e29b-41d4-a716-446655440012');
          expect(body['email'], 'reservasi@mewahjakarta.example.com');
          expect(body['phone'], '+62-21-555-9999');

          final locations = body['locations'] as List<dynamic>;
          expect(locations.length, 1);
          expect(locations.first['label'], 'Main Location');
          expect(
            locations.first['address_line'],
            'Jl. Menteng Raya No. 42, Jakarta Pusat',
          );
          expect(locations.first['province_id'], 6);
          expect(locations.first['regency_id'], 3175);
          expect(locations.first['area_size'], 1500.0);

          final contacts = body['contacts'] as List<dynamic>;
          expect(contacts.length, 2);
          expect(contacts[0]['name'], 'Eko Prasetyo');
          expect(contacts[0]['role'], 1); // PIC int
          expect(contacts[0]['is_primary'], true);
          expect(contacts[1]['name'], 'Dwi Hastono');
          expect(contacts[1]['role'], 2); // PIC Backup int
          expect(contacts[1]['is_primary'], false);

          final jsonResponse = {
            'data': {
              'id': '11e8400-e29b-41d4-a716-446655440013',
              'code': 'CUST-003',
              'name': 'Restoran Mewah Jakarta',
              'initials': 'RM',
              'segment': 'Food & Beverage',
              'status': 'active',
              'created_at': '2025-08-18T15:30:45Z',
            },
            'is_error': false,
            'http_status': 200,
          };

          return ResponseBody.fromString(
            jsonEncode(jsonResponse),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        const input = CreateCustomerInput(
          code: 'CUST-003',
          name: 'Restoran Mewah Jakarta',
          segmentId: '660e8400-e29b-41d4-a716-446655440012',
          segment: 'Food & Beverage',
          npwp: '98.765.432.1-654.321',
          email: 'reservasi@mewahjakarta.example.com',
          phone: '+62-21-555-9999',
          phoneAlt: '+62-21-555-8888',
          notes: 'New high-value restaurant account',
          locations: [
            CreateLocationInput(
              label: 'Main Location',
              address: 'Jl. Menteng Raya No. 42, Jakarta Pusat',
              provinceId: 6,
              regencyId: 3175,
              districtId: 3175008,
              villageId: 3175008001,
              areaSize: 1500.0,
              latitude: -6.2088,
              longitude: 106.8271,
            ),
          ],
          contacts: [
            CreateContactInput(
              name: 'Eko Prasetyo',
              position: 'Owner',
              email: 'eko@mewahjakarta.example.com',
              phone: '+62-21-555-9999',
              role: 'pic',
              isPrimary: true,
            ),
            CreateContactInput(
              name: 'Dwi Hastono',
              position: 'Manager',
              email: 'dwi@mewahjakarta.example.com',
              phone: '+62-21-555-9998',
              role: 'pic_backup',
              isPrimary: false,
            ),
          ],
        );

        final result = await repository.createCustomer(input);
        expect(result.isOk, true);
        final customer = result.valueOrNull!;
        expect(customer.id, '11e8400-e29b-41d4-a716-446655440013');
        expect(customer.code, 'CUST-003');
        expect(customer.name, 'Restoran Mewah Jakarta');
        expect(customer.initials, 'RM');
        expect(customer.segment, 'Food & Beverage');
        expect(customer.status, 'active');
        expect(customer.createdAt, '2025-08-18T15:30:45Z');
      },
    );

    test('createCustomer returns 400 failure on invalid input', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 400,
          'message': 'Nama pelanggan wajib diisi',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      const input = CreateCustomerInput(name: '');
      final result = await repository.createCustomer(input);
      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.message, 'Nama pelanggan wajib diisi');
      expect(result.failureOrNull?.statusCode, 400);
    });
  });

  group('CustomerRepository - updateCustomer', () {
    const customerId = '11e8400-e29b-41d4-a716-446655440013';

    test(
      'updateCustomer sends PUT request and returns updated Customer entity',
      () async {
        mockAdapter.handler = (options) {
          expect(options.path, '/v1/sales/customers/$customerId');
          expect(options.method, 'PUT');

          final body = options.data is String
              ? jsonDecode(options.data as String)
              : options.data as Map<String, dynamic>;

          expect(body['name'], 'Restoran Mewah Jakarta Updated');
          expect(body['segment_id'], '660e8400-e29b-41d4-a716-446655440012');
          expect(body['status'], 'active');
          expect(body.containsKey('code'), false);

          final jsonResponse = {
            'data': {
              'id': customerId,
              'code': 'CUST-003',
              'name': 'Restoran Mewah Jakarta Updated',
              'initials': 'RM',
              'segment': 'Food & Beverage',
              'status': 'active',
              'created_at': '2025-08-18T15:30:45Z',
            },
            'is_error': false,
            'http_status': 200,
          };

          return ResponseBody.fromString(
            jsonEncode(jsonResponse),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        const input = CreateCustomerInput(
          code: 'CUST-003',
          name: 'Restoran Mewah Jakarta Updated',
          segmentId: '660e8400-e29b-41d4-a716-446655440012',
          segment: 'Food & Beverage',
        );

        final result = await repository.updateCustomer(customerId, input);
        expect(result.isOk, true);
        final customer = result.valueOrNull!;
        expect(customer.id, customerId);
        expect(customer.name, 'Restoran Mewah Jakarta Updated');
      },
    );

    test('updateCustomer returns 404 failure when not found', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 404,
          'message': 'Pelanggan tidak ditemukan',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      const input = CreateCustomerInput(name: 'Updated Name');
      final result = await repository.updateCustomer('non-existent-id', input);
      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.message, 'Pelanggan tidak ditemukan');
      expect(result.failureOrNull?.statusCode, 404);
    });
  });

  group('CustomerRepository - getSegments', () {
    test(
      'getSegments successfully parses items list and returns Ok(List<Segment>)',
      () async {
        mockAdapter.handler = (options) {
          expect(options.path, '/v1/sales/segments');
          expect(options.queryParameters['page'], 1);
          expect(options.queryParameters['page_size'], 100);

          final jsonResponse = {
            'data': {
              'items': [
                {
                  'id': '660e8400-e29b-41d4-a716-446655440001',
                  'name': 'Hospitality',
                  'created_at': '2025-06-15T10:30:00Z',
                },
                {
                  'id': '660e8400-e29b-41d4-a716-446655440002',
                  'name': 'Food & Beverage',
                  'created_at': '2025-06-16T11:00:00Z',
                },
              ],
              'pagination': {'total': 2, 'total_page': 1, 'has_next': false},
            },
            'is_error': false,
            'http_status': 200,
          };

          return ResponseBody.fromString(
            jsonEncode(jsonResponse),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getSegments();
        expect(result.isOk, true);
        final segments = result.valueOrNull!;
        expect(segments.length, 2);
        expect(segments.first, isA<Segment>());
        expect(segments[0].id, '660e8400-e29b-41d4-a716-446655440001');
        expect(segments[0].name, 'Hospitality');
        expect(segments[0].createdAt, '2025-06-15T10:30:00Z');
        expect(segments[1].id, '660e8400-e29b-41d4-a716-446655440002');
        expect(segments[1].name, 'Food & Beverage');
        expect(segments[1].createdAt, '2025-06-16T11:00:00Z');
      },
    );

    test('getSegments correctly passes custom query parameters', () async {
      mockAdapter.handler = (options) {
        expect(options.queryParameters['page'], 2);
        expect(options.queryParameters['page_size'], 50);
        expect(options.queryParameters['q'], 'Hosp');

        final jsonResponse = {
          'data': {
            'items': <dynamic>[],
            'pagination': {'total': 0, 'total_page': 0, 'has_next': false},
          },
          'is_error': false,
          'http_status': 200,
        };

        return ResponseBody.fromString(
          jsonEncode(jsonResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getSegments(
        page: 2,
        pageSize: 50,
        query: 'Hosp',
      );
      expect(result.isOk, true);
      expect(result.valueOrNull, isEmpty);
    });

    test('getSegments returns ServerFailure on 400', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 400,
          'message': 'Parameter segmen tidak valid',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getSegments();
      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.message, 'Parameter segmen tidak valid');
      expect(result.failureOrNull?.statusCode, 400);
    });

    test('getSegments returns ServerFailure on 500', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 500,
          'message': 'Internal server error',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getSegments();
      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.statusCode, 500);
    });

    test('getSegments returns NetworkFailure on connection timeout', () async {
      mockAdapter.handler = (options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      };

      final result = await repository.getSegments();
      expect(result.isErr, true);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });
}
