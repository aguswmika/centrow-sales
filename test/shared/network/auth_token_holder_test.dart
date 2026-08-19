import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/shared/network/auth_token_holder.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';

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
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AuthTokenHolder', () {
    setUp(() {
      AuthTokenHolder.instance.clear();
    });

    tearDown(() {
      AuthTokenHolder.instance.clear();
    });

    test('singleton holds and clears token', () {
      expect(AuthTokenHolder.instance.token, isNull);
      expect(AuthTokenHolder.instance.hasToken, false);

      AuthTokenHolder.instance.token = 'sample-jwt-token';
      expect(AuthTokenHolder.instance.token, 'sample-jwt-token');
      expect(AuthTokenHolder.instance.hasToken, true);

      AuthTokenHolder.instance.clear();
      expect(AuthTokenHolder.instance.token, isNull);
      expect(AuthTokenHolder.instance.hasToken, false);
    });
  });

  group('DioClient Auth Interceptor', () {
    late Dio dio;
    late MockAdapter adapter;

    setUp(() {
      AuthTokenHolder.instance.clear();
      dio = createDio('https://api.centrow.id/api');
      adapter = MockAdapter();
      dio.httpClientAdapter = adapter;
    });

    tearDown(() {
      AuthTokenHolder.instance.clear();
    });

    test('does not inject Authorization header when token is null', () async {
      RequestOptions? capturedOptions;
      adapter.handler = (options) {
        capturedOptions = options;
        return ResponseBody.fromString('{}', 200);
      };

      await dio.get<dynamic>('/test');
      expect(capturedOptions?.headers['Authorization'], isNull);
    });

    test('injects Bearer token when AuthTokenHolder has a token', () async {
      AuthTokenHolder.instance.token = 'test-token-12345';

      RequestOptions? capturedOptions;
      adapter.handler = (options) {
        capturedOptions = options;
        return ResponseBody.fromString('{}', 200);
      };

      await dio.get<dynamic>('/test');
      expect(
        capturedOptions?.headers['Authorization'],
        'Bearer test-token-12345',
      );
    });
  });
}
