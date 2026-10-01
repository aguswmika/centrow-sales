import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/site_risk_repository.dart';
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
  late SiteRiskRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.centrow.id/api'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = SiteRiskRepositoryImpl(dio);
  });

  group('SiteRiskRepository - getSiteRiskMasters', () {
    test('returns 200 success with list of SiteRiskMaster', () async {
      mockAdapter.handler = (options) {
        expect(options.path, '/v1/sales/site-risks');
        expect(options.method, 'GET');

        final jsonResponse = {
          'data': {
            'items': [
              {
                'id': '0192a3c4-1111-7000-8000-000000000001',
                'name': 'Area kerja terdapat lalu-lalang kendaraan/orang',
              },
              {
                'id': '0192a3c4-1111-7000-8000-000000000002',
                'name': 'Bekerja di area ketinggian',
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

      final result = await repository.getSiteRiskMasters();

      expect(result.isOk, true);
      final masters = result.valueOrNull!;
      expect(masters.length, 2);
      expect(masters[0].id, '0192a3c4-1111-7000-8000-000000000001');
      expect(
        masters[0].name,
        'Area kerja terdapat lalu-lalang kendaraan/orang',
      );
      expect(masters[1].id, '0192a3c4-1111-7000-8000-000000000002');
      expect(masters[1].name, 'Bekerja di area ketinggian');
    });

    test('returns 403 forbidden error', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 403,
          'message': 'Akses ditolak',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          403,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getSiteRiskMasters();

      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.message, 'Akses ditolak');
      expect(result.failureOrNull?.statusCode, 403);
    });

    test('returns 500 internal server error', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 500,
          'message': 'Terjadi kesalahan internal pada server',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getSiteRiskMasters();

      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(
        result.failureOrNull?.message,
        'Terjadi kesalahan internal pada server',
      );
      expect(result.failureOrNull?.statusCode, 500);
    });
  });

  group('SiteRiskRepository - getAddressRisks', () {
    const customerId = 'cust-uuid-123';
    const addressId = 'addr-uuid-456';

    test('returns 200 success with list of CustomerAddressRisk', () async {
      mockAdapter.handler = (options) {
        expect(
          options.path,
          '/v1/sales/customers/$customerId/addresses/$addressId/risks',
        );
        expect(options.method, 'GET');

        final jsonResponse = {
          'data': {
            'items': [
              {
                'id': '0192a3c4-2222-7000-8000-000000000001',
                'site_risk_id': '0192a3c4-1111-7000-8000-000000000001',
                'name': 'Area kerja terdapat lalu-lalang kendaraan/orang',
                'is_custom': false,
              },
              {
                'id': '0192a3c4-2222-7000-8000-000000000002',
                'site_risk_id': null,
                'name': 'Anjing penjaga di halaman belakang',
                'is_custom': true,
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

      final result = await repository.getAddressRisks(
        customerId: customerId,
        addressId: addressId,
      );

      expect(result.isOk, true);
      final risks = result.valueOrNull!;
      expect(risks.length, 2);
      expect(risks[0].id, '0192a3c4-2222-7000-8000-000000000001');
      expect(risks[0].siteRiskId, '0192a3c4-1111-7000-8000-000000000001');
      expect(risks[0].name, 'Area kerja terdapat lalu-lalang kendaraan/orang');
      expect(risks[0].isCustom, false);

      expect(risks[1].id, '0192a3c4-2222-7000-8000-000000000002');
      expect(risks[1].siteRiskId, isNull);
      expect(risks[1].name, 'Anjing penjaga di halaman belakang');
      expect(risks[1].isCustom, true);
    });

    test('returns 200 success with empty list', () async {
      mockAdapter.handler = (options) {
        expect(
          options.path,
          '/v1/sales/customers/$customerId/addresses/$addressId/risks',
        );
        expect(options.method, 'GET');

        final jsonResponse = {
          'data': {'items': <dynamic>[]},
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

      final result = await repository.getAddressRisks(
        customerId: customerId,
        addressId: addressId,
      );

      expect(result.isOk, true);
      expect(result.valueOrNull, isEmpty);
    });

    test('returns 404 error when address not found', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 404,
          'message': 'Alamat pelanggan tidak ditemukan',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getAddressRisks(
        customerId: customerId,
        addressId: addressId,
      );

      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.message, 'Alamat pelanggan tidak ditemukan');
      expect(result.failureOrNull?.statusCode, 404);
    });
  });

  group('SiteRiskRepository - updateAddressRisks', () {
    const customerId = 'cust-uuid-123';
    const addressId = 'addr-uuid-456';
    const siteRiskIds = [
      '0192a3c4-1111-7000-8000-000000000001',
      '0192a3c4-1111-7000-8000-000000000002',
    ];
    const customRisks = ['Anjing galak di pekarangan'];

    test(
      'sends PUT request with verified payload and returns updated risks',
      () async {
        mockAdapter.handler = (options) {
          expect(
            options.path,
            '/v1/sales/customers/$customerId/addresses/$addressId/risks',
          );
          expect(options.method, 'PUT');

          final dynamic rawBody = options.data;
          final Map<String, dynamic> body = rawBody is String
              ? jsonDecode(rawBody) as Map<String, dynamic>
              : (rawBody as Map).cast<String, dynamic>();

          expect(body['site_risk_ids'], siteRiskIds);
          expect(body['custom_risks'], customRisks);

          final jsonResponse = {
            'data': {
              'items': [
                {
                  'id': '0192a3c4-2222-7000-8000-000000000001',
                  'site_risk_id': '0192a3c4-1111-7000-8000-000000000001',
                  'name': 'Area kerja terdapat lalu-lalang kendaraan/orang',
                  'is_custom': false,
                },
                {
                  'id': '0192a3c4-2222-7000-8000-000000000002',
                  'site_risk_id': '0192a3c4-1111-7000-8000-000000000002',
                  'name': 'Bekerja di area ketinggian',
                  'is_custom': false,
                },
                {
                  'id': '0192a3c4-2222-7000-8000-000000000003',
                  'site_risk_id': null,
                  'name': 'Anjing galak di pekarangan',
                  'is_custom': true,
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

        final result = await repository.updateAddressRisks(
          customerId: customerId,
          addressId: addressId,
          siteRiskIds: siteRiskIds,
          customRisks: customRisks,
        );

        expect(result.isOk, true);
        final risks = result.valueOrNull!;
        expect(risks.length, 3);
        expect(risks[0].id, '0192a3c4-2222-7000-8000-000000000001');
        expect(risks[0].siteRiskId, '0192a3c4-1111-7000-8000-000000000001');
        expect(risks[0].isCustom, false);

        expect(risks[1].id, '0192a3c4-2222-7000-8000-000000000002');
        expect(risks[1].siteRiskId, '0192a3c4-1111-7000-8000-000000000002');
        expect(risks[1].isCustom, false);

        expect(risks[2].id, '0192a3c4-2222-7000-8000-000000000003');
        expect(risks[2].siteRiskId, isNull);
        expect(risks[2].name, 'Anjing galak di pekarangan');
        expect(risks[2].isCustom, true);
      },
    );

    test('returns 400 validation error', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 400,
          'message': 'Format data risiko tidak valid',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.updateAddressRisks(
        customerId: customerId,
        addressId: addressId,
        siteRiskIds: siteRiskIds,
        customRisks: customRisks,
      );

      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(result.failureOrNull?.message, 'Format data risiko tidak valid');
      expect(result.failureOrNull?.statusCode, 400);
    });

    test('returns 403 forbidden error', () async {
      mockAdapter.handler = (options) {
        final errorResponse = {
          'data': null,
          'is_error': true,
          'http_status': 403,
          'message':
              'Anda tidak memiliki hak akses untuk mengubah risiko lokasi',
        };
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          403,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.updateAddressRisks(
        customerId: customerId,
        addressId: addressId,
        siteRiskIds: siteRiskIds,
        customRisks: customRisks,
      );

      expect(result.isErr, true);
      expect(result.failureOrNull, isA<ServerFailure>());
      expect(
        result.failureOrNull?.message,
        'Anda tidak memiliki hak akses untuk mengubah risiko lokasi',
      );
      expect(result.failureOrNull?.statusCode, 403);
    });
  });
}
