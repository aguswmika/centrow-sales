import 'dart:async';
import 'package:dio/dio.dart';
import 'package:centrow_sales/shared/network/auth_token_holder.dart';
import 'package:centrow_sales/shared/config/app_config.dart';
import 'package:centrow_sales/shared/error/failure.dart';

Dio createDio([String? baseUrl]) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-App-Client': 'sales',
        'X-Version': AppConfig.appVersion,
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AuthTokenHolder.instance.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final path = error.requestOptions.path;
          final isLogin =
              path == '/v1/auth/login' || path.endsWith('/v1/auth/login');
          if (!isLogin) {
            final refreshToken = AuthTokenHolder.instance.refreshToken;
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                // Create a basic Dio without interceptors to avoid loops
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: AppConfig.apiBaseUrl,
                    headers: {
                      'Accept': 'application/json',
                      'Content-Type': 'application/json',
                    },
                  ),
                );

                final refreshResponse = await refreshDio.post<dynamic>(
                  '/v1/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );

                if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
                  final data = refreshResponse.data['data'] as Map<String, dynamic>? ?? refreshResponse.data;
                  final newToken = data['token']?.toString() ?? '';
                  final newRefreshToken = data['refresh_token']?.toString() ?? '';

                  if (newToken.isNotEmpty) {
                    await AuthTokenHolder.instance.saveToken(
                      newToken,
                      newRefreshToken: newRefreshToken.isNotEmpty ? newRefreshToken : null,
                    );

                    // Retry original request
                    error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                    final retryResponse = await dio.fetch<dynamic>(error.requestOptions);
                    return handler.resolve(retryResponse);
                  }
                }
              } catch (_) {
                // Refresh failed
              }
            }

            unawaited(AuthTokenHolder.instance.handleSessionExpired());
          }
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}

Failure mapDioException(DioException error) {
  final statusCode = error.response?.statusCode;
  final dynamic data = error.response?.data;
  String? serverMessage;

  if (data is Map<String, dynamic>) {
    serverMessage = (data['message'] ?? data['error'])?.toString();
  } else if (data is String && data.isNotEmpty) {
    serverMessage = data;
  }

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => NetworkFailure(
      serverMessage ??
          'Koneksi internet bermasalah. Silakan periksa koneksi Anda.',
      statusCode,
    ),
    DioExceptionType.badResponse => ServerFailure(
      serverMessage ?? 'Terjadi kesalahan pada server (${statusCode ?? 500}).',
      statusCode,
    ),
    DioExceptionType.cancel => const NetworkFailure('Permintaan dibatalkan.'),
    _ => UnknownFailure(
      serverMessage ??
          error.message ??
          'Terjadi kesalahan yang tidak diketahui.',
    ),
  };
}
