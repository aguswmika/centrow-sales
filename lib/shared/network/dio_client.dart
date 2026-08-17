import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../error/failure.dart';

Dio createDio([String? baseUrl]) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Interceptor hook for auth token or custom headers if needed
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
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
