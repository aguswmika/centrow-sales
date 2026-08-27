import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/product_repository.dart';
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
  late ProductRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.centrow.id'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = ProductRepositoryImpl(dio);
  });

  test(
    'getProducts passes kind query param and maps requestedKind to Entity',
    () async {
      mockAdapter.handler = (options) {
        expect(options.path, '/v1/products');
        expect(options.queryParameters['kind'], 1);
        final body = jsonEncode({
          'data': [
            {
              'id': 'p1',
              'code': 'PRD-01',
              'name': 'Chemical Alpha',
              'uom_id': 'u1',
              'uom_code': 'BTL',
              'cogs': 25000.0,
              'is_active': true,
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

      final result = await repository.getProducts(kind: 1);
      expect(result, isA<Ok<dynamic>>());
      final products = (result as Ok<dynamic>).value;
      expect(products[0].kind, 1);
    },
  );
}
