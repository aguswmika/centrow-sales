import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/pc/repositories/product_mapping_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

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
  late ProductMappingRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.centrow.id/api'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = ProductMappingRepositoryImpl(dio);
  });

  group('ProductMappingRepositoryImpl', () {
    test(
      'getProductMappings fetches all mappings without query param',
      () async {
        mockAdapter.handler = (options) {
          expect(options.path, '/v1/pc/product-mappings');
          expect(options.queryParameters.isEmpty, isTrue);

          final body = jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'pm-1',
                'product_id': 'p-1',
                'product_name': 'Termiticide A',
                'pest_id': 'pest-1',
                'pest_name': 'Subterranean Termite',
                'treatment_method_id': 'tm-1',
                'treatment_method_code': 'INJ',
                'dose_min_limit': 2.5,
                'dose_max_limit': 5.0,
                'dose_unit_id': 'du-1',
                'dose_unit_code': 'ML',
                'unit_price': 85000,
              },
            ],
          });

          return ResponseBody.fromString(
            body,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getProductMappings();
        expect(result, isA<Ok<dynamic>>());
        final mappings = (result as Ok).value;
        expect(mappings.length, 1);
        expect(mappings[0].id, 'pm-1');
        expect(mappings[0].productName, 'Termiticide A');
        expect(mappings[0].treatmentMethodCode, 'INJ');
        expect(mappings[0].doseMinLimit, 2.5);
        expect(mappings[0].unitPrice, 85000.0);
      },
    );

    test(
      'getProductMappings passes treatment_method_id and keyword query params when specified',
      () async {
        mockAdapter.handler = (options) {
          expect(options.path, '/v1/pc/product-mappings');
          expect(options.queryParameters['treatment_method_id'], 'tm-123');
          expect(options.queryParameters['keyword'], 'Bait');

          final body = jsonEncode({
            'data': [
              {
                'id': 'pm-2',
                'product_id': 'p-123',
                'product_name': 'Gel Bait B',
                'pest_id': 'pest-2',
                'pest_name': 'German Cockroach',
                'treatment_method_id': 'tm-123',
                'treatment_method_code': 'BAIT',
                'dose_min_limit': 1.0,
                'dose_max_limit': 2.0,
                'dose_unit_id': 'du-2',
                'dose_unit_code': 'DOT',
              },
            ],
          });

          return ResponseBody.fromString(
            body,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getProductMappings(
          treatmentMethodId: 'tm-123',
          keyword: 'Bait',
        );
        expect(result, isA<Ok<dynamic>>());
        final mappings = (result as Ok).value;
        expect(mappings.length, 1);
        expect(mappings[0].productId, 'p-123');
        expect(mappings[0].treatmentMethodId, 'tm-123');
        expect(mappings[0].treatmentMethodCode, 'BAIT');
      },
    );

    test('getProductMappings returns Err on DioException failure', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Server Error'}),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getProductMappings();
      expect(result, isA<Err<dynamic>>());
      final failure = (result as Err).failure;
      expect(failure, isA<ServerFailure>());
    });
  });
}
