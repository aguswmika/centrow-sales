import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/entities/tenant.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';
import 'package:centrow_sales/modules/core/repositories/auth_repository.dart';
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
  late AuthRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.centrow.id'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = AuthRepositoryImpl(dio);
  });

  group('AuthRepositoryImpl - getPublicTenants', () {
    test('returns List<Tenant> on 200 OK', () async {
      mockAdapter.handler = (options) {
        expect(options.path, '/v1/tenants/public');
        final body = jsonEncode({
          'data': [
            {
              'id': '8e4c1393-cdfb-4987-b842-a6653875435c',
              'name': 'Main Branch',
              'slug': 'main-branch',
            },
            {
              'id': '04b541f8-6f4c-4053-92f8-6cbb68be4a7f',
              'name': 'Bandung Branch',
              'slug': 'bandung-branch',
            },
          ],
          'is_error': false,
          'http_status': 200,
        });
        return ResponseBody.fromString(
          body,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getPublicTenants();
      expect(result, isA<Ok<List<Tenant>>>());
      final tenants = (result as Ok<List<Tenant>>).value;
      expect(tenants.length, 2);
      expect(tenants[0].name, 'Main Branch');
      expect(tenants[1].slug, 'bandung-branch');
    });

    test('returns NetworkFailure on connection error', () async {
      mockAdapter.handler = (options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      };

      final result = await repository.getPublicTenants();
      expect(result, isA<Err<List<Tenant>>>());
      final failure = (result as Err<List<Tenant>>).failure;
      expect(failure, isA<NetworkFailure>());
    });
  });

  group('AuthRepositoryImpl - login', () {
    const email = 'sales@example.com';
    const password = 'secretPassword123';
    const tenantId = '8e4c1393-cdfb-4987-b842-a6653875435c';

    test('returns User on 200 OK', () async {
      mockAdapter.handler = (options) {
        expect(options.path, '/v1/auth/login');
        expect(options.data, {
          'email': email,
          'password': password,
          'tenant_id': tenantId,
        });

        final body = jsonEncode({
          'data': {
            'user': {
              'id': '5d3611bb-d413-4d03-95dc-57f1d1de572a',
              'name': 'Jane Doe',
              'email': email,
              'role': 'sales',
              'branch': 'Main Branch',
            },
            'token': 'jwt_access_token_123',
            'expiresIn': 86400,
          },
          'is_error': false,
          'http_status': 200,
        });
        return ResponseBody.fromString(
          body,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.login(
        email: email,
        password: password,
        tenantId: tenantId,
      );

      expect(result, isA<Ok<User>>());
      final user = (result as Ok<User>).value;
      expect(user.id, '5d3611bb-d413-4d03-95dc-57f1d1de572a');
      expect(user.name, 'Jane Doe');
      expect(user.email, email);
      expect(user.role, 'sales');
      expect(user.branch, 'Main Branch');
      expect(user.token, 'jwt_access_token_123');
    });

    test('returns ServerFailure on 400 Bad Request', () async {
      mockAdapter.handler = (options) {
        final body = jsonEncode({
          'data': null,
          'is_error': true,
          'http_status': 400,
          'message': 'Invalid email format',
        });
        return ResponseBody.fromString(
          body,
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.login(
        email: 'invalid-email',
        password: password,
        tenantId: tenantId,
      );

      expect(result, isA<Err<User>>());
      final failure = (result as Err<User>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.statusCode, 400);
      expect(failure.message, 'Invalid email format');
    });

    test('returns ServerFailure on 401 Unauthorized', () async {
      mockAdapter.handler = (options) {
        final body = jsonEncode({
          'data': null,
          'is_error': true,
          'http_status': 401,
          'message': 'Invalid email or password',
        });
        return ResponseBody.fromString(
          body,
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.login(
        email: email,
        password: 'wrongpassword',
        tenantId: tenantId,
      );

      expect(result, isA<Err<User>>());
      final failure = (result as Err<User>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.statusCode, 401);
      expect(failure.message, 'Invalid email or password');
    });

    test('returns ServerFailure on 403 Forbidden (ErrAppNotAllowed)', () async {
      mockAdapter.handler = (options) {
        final body = jsonEncode({
          'data': null,
          'is_error': true,
          'http_status': 403,
          'message': 'Akun ini tidak memiliki akses ke aplikasi ini',
        });
        return ResponseBody.fromString(
          body,
          403,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.login(
        email: 'admin@example.com',
        password: password,
        tenantId: tenantId,
      );

      expect(result, isA<Err<User>>());
      final failure = (result as Err<User>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.statusCode, 403);
      expect(failure.message, 'Akun ini tidak memiliki akses ke aplikasi ini.');
    });

    test('returns ServerFailure on 500 Server Error', () async {
      mockAdapter.handler = (options) {
        final body = jsonEncode({
          'data': null,
          'is_error': true,
          'http_status': 500,
          'message': 'Internal database error',
        });
        return ResponseBody.fromString(
          body,
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.login(
        email: email,
        password: password,
        tenantId: tenantId,
      );

      expect(result, isA<Err<User>>());
      final failure = (result as Err<User>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.statusCode, 500);
      expect(failure.message, 'Internal database error');
    });
  });
}
