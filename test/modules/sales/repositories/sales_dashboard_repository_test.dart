import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/sales_dashboard_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/sales_dashboard.dart';

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
  late SalesDashboardRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.centrow.id'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = SalesDashboardRepositoryImpl(dio);
  });

  test('getDashboardSummary returns Ok when API call is successful', () async {
    mockAdapter.handler = (options) {
      expect(options.path, '/v1/sales/dashboard');
      final body = jsonEncode({
        'data': {
          'kpis': <dynamic>[],
          'pipeline_stages': <dynamic>[],
          'client_segments': <dynamic>[],
          'recent_proposals': <dynamic>[],
          'expiring_contracts': <dynamic>[],
          'user_name': 'User',
          'branch_name': 'Branch',
        },
      });
      return ResponseBody.fromString(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    };

    final result = await repository.getDashboardSummary();
    expect(result, isA<Ok<SalesDashboardSummary>>());
  });

  test(
    'getDashboardSummary returns NetworkFailure on connection error',
    () async {
      mockAdapter.handler = (options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      };

      final result = await repository.getDashboardSummary();
      expect(result, isA<Err<SalesDashboardSummary>>());
      final failure = (result as Err<SalesDashboardSummary>).failure;
      expect(failure, isA<NetworkFailure>());
    },
  );
}
