import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';
import 'package:centrow_sales/shared/network/auth_token_holder.dart';
import 'package:centrow_sales/shared/network/dio_client.dart';
import 'package:centrow_sales/shared/storage/local_storage.dart';

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

class FakeLocalStorage implements LocalStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}

void main() {
  group('AuthTokenHolder', () {
    late FakeLocalStorage storage;

    setUp(() {
      storage = FakeLocalStorage();
      AuthTokenHolder.instance.clear();
      AuthTokenHolder.instance.initFromStorage(storage);
    });

    tearDown(() {
      AuthTokenHolder.instance.clear();
    });

    test('singleton holds, saves, and clears token with storage', () async {
      expect(AuthTokenHolder.instance.token, isNull);
      expect(AuthTokenHolder.instance.hasToken, false);

      await AuthTokenHolder.instance.saveToken('sample-jwt-token');
      expect(AuthTokenHolder.instance.token, 'sample-jwt-token');
      expect(AuthTokenHolder.instance.hasToken, true);
      expect(
        storage.getString(AuthTokenHolder.tokenStorageKey),
        'sample-jwt-token',
      );

      // Test restoring into new holder instance initialization
      AuthTokenHolder.instance.initFromStorage(storage);
      expect(AuthTokenHolder.instance.token, 'sample-jwt-token');

      await AuthTokenHolder.instance.clear();
      expect(AuthTokenHolder.instance.token, isNull);
      expect(AuthTokenHolder.instance.hasToken, false);
      expect(storage.getString(AuthTokenHolder.tokenStorageKey), isNull);
    });

    test('manages currentUser and resolves initials correctly', () async {
      expect(AuthTokenHolder.instance.currentUser, isNull);
      expect(AuthTokenHolder.instance.user, isNull);
      expect(AuthTokenHolder.instance.getInitials(), '');
      expect(AuthTokenHolder.instance.userInitials, '');

      const user = User(
        id: 'user_123',
        tenantId: 'tenant_456',
        name: 'Jane Doe',
        email: 'jane@example.com',
        roles: ['sales'],
        position: 'Sales Executive',
        department: 'Sales',
        token: 'sample-jwt-token',
      );

      AuthTokenHolder.instance.currentUser = user;
      expect(AuthTokenHolder.instance.currentUser, user);
      expect(AuthTokenHolder.instance.user, user);
      expect(AuthTokenHolder.instance.getInitials(), 'JD');
      expect(AuthTokenHolder.instance.userInitials, 'JD');

      // Test clear clears currentUser too
      await AuthTokenHolder.instance.clear();
      expect(AuthTokenHolder.instance.currentUser, isNull);
      expect(AuthTokenHolder.instance.user, isNull);
      expect(AuthTokenHolder.instance.userInitials, '');
    });

    test(
      'handleSessionExpired clears token, currentUser, storage, and calls onSessionExpired',
      () async {
        await AuthTokenHolder.instance.saveToken('valid-token');
        AuthTokenHolder.instance.currentUser = const User(
          id: 'u1',
          name: 'Test User',
          email: 'test@example.com',
          role: 'Sales',
          branch: 'Bali',
          token: 'valid-token',
        );

        var expiredCallCount = 0;
        AuthTokenHolder.instance.onSessionExpired = () {
          expiredCallCount++;
        };

        await AuthTokenHolder.instance.handleSessionExpired();

        expect(expiredCallCount, 1);
        expect(AuthTokenHolder.instance.token, isNull);
        expect(AuthTokenHolder.instance.currentUser, isNull);
        expect(AuthTokenHolder.instance.hasToken, false);
        expect(storage.getString(AuthTokenHolder.tokenStorageKey), isNull);
      },
    );

    test(
      'handleSessionExpired does not trigger callback when no session is active',
      () async {
        var expiredCallCount = 0;
        AuthTokenHolder.instance.onSessionExpired = () {
          expiredCallCount++;
        };

        expect(AuthTokenHolder.instance.hasToken, false);
        expect(AuthTokenHolder.instance.currentUser, isNull);

        await AuthTokenHolder.instance.handleSessionExpired();
        expect(expiredCallCount, 0);
      },
    );

    test('handleSessionExpired debounces concurrent and rapid calls', () async {
      await AuthTokenHolder.instance.saveToken('valid-token');
      var expiredCallCount = 0;
      AuthTokenHolder.instance.onSessionExpired = () {
        expiredCallCount++;
      };

      // Call handleSessionExpired concurrently
      await Future.wait([
        AuthTokenHolder.instance.handleSessionExpired(),
        AuthTokenHolder.instance.handleSessionExpired(),
        AuthTokenHolder.instance.handleSessionExpired(),
      ]);

      expect(expiredCallCount, 1);

      // Subsequent call when already cleared should also be a no-op
      await AuthTokenHolder.instance.handleSessionExpired();
      expect(expiredCallCount, 1);
    });
  });

  group('DioClient Auth Interceptor', () {
    late Dio dio;
    late MockAdapter adapter;
    late FakeLocalStorage storage;

    setUp(() {
      storage = FakeLocalStorage();
      AuthTokenHolder.instance.clear();
      AuthTokenHolder.instance.initFromStorage(storage);
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

    test(
      'triggers handleSessionExpired on 401 for protected endpoint',
      () async {
        await AuthTokenHolder.instance.saveToken('expired-token');
        var expiredCallCount = 0;
        AuthTokenHolder.instance.onSessionExpired = () {
          expiredCallCount++;
        };

        adapter.handler = (options) {
          return ResponseBody.fromString(
            '{"message":"Unauthorized"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        try {
          await dio.get<dynamic>('/v1/customers');
        } on DioException catch (e) {
          expect(e.response?.statusCode, 401);
        }

        // Wait a microtask turn for unawaited async handleSessionExpired
        await Future<void>.delayed(Duration.zero);

        expect(expiredCallCount, 1);
        expect(AuthTokenHolder.instance.token, isNull);
        expect(AuthTokenHolder.instance.hasToken, false);
        expect(storage.getString(AuthTokenHolder.tokenStorageKey), isNull);
      },
    );

    test(
      'does NOT trigger handleSessionExpired on 401 for /v1/auth/login',
      () async {
        await AuthTokenHolder.instance.saveToken('existing-token');
        var expiredCallCount = 0;
        AuthTokenHolder.instance.onSessionExpired = () {
          expiredCallCount++;
        };

        adapter.handler = (options) {
          return ResponseBody.fromString(
            '{"message":"Invalid credentials"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        try {
          await dio.post<dynamic>('/v1/auth/login', data: {'email': 'test'});
        } on DioException catch (e) {
          expect(e.response?.statusCode, 401);
        }

        await Future<void>.delayed(Duration.zero);

        expect(expiredCallCount, 0);
        expect(AuthTokenHolder.instance.token, 'existing-token');
        expect(AuthTokenHolder.instance.hasToken, true);
        expect(
          storage.getString(AuthTokenHolder.tokenStorageKey),
          'existing-token',
        );
      },
    );

    test(
      'handles concurrent 401 responses on protected endpoints triggering onSessionExpired once',
      () async {
        await AuthTokenHolder.instance.saveToken('expired-token');
        var expiredCallCount = 0;
        AuthTokenHolder.instance.onSessionExpired = () {
          expiredCallCount++;
        };

        adapter.handler = (options) {
          return ResponseBody.fromString(
            '{"message":"Unauthorized"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        await Future.wait([
          dio
              .get<dynamic>('/v1/customers')
              .catchError(
                (_) => Response<dynamic>(requestOptions: RequestOptions()),
              ),
          dio
              .get<dynamic>('/v1/contracts')
              .catchError(
                (_) => Response<dynamic>(requestOptions: RequestOptions()),
              ),
          dio
              .get<dynamic>('/v1/auth/me')
              .catchError(
                (_) => Response<dynamic>(requestOptions: RequestOptions()),
              ),
        ]);

        await Future<void>.delayed(Duration.zero);

        expect(expiredCallCount, 1);
        expect(AuthTokenHolder.instance.token, isNull);
        expect(AuthTokenHolder.instance.hasToken, false);
      },
    );
  });
}
