import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/repositories/pricing_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';
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
  late PricingRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.centrow.id'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = PricingRepositoryImpl(dio);
  });

  const requestDto = CreatePricingRequestDto(
    contractMonths: 12,
    visitFrequency: 4,
    markupType: 1,
    markupValue: 25.0,
    discountAmount: 0.0,
    taxPercentage: 11.0,
    materials: [
      PricingMaterialDto(
        supplyType: 1,
        productMappingId: 'pm-1',
        name: 'Material 1',
        uomCode: 'KG',
        doseUsage: 2.5,
        doseUnitId: 'uom-1',
        applicationVolume: 2.0,
        applicationVolumeUnitId: 'uom-2',
        frequency: 2,
      ),
    ],
    workers: [
      PricingWorkerDto(
        productId: 'prod-operator',
        firstVisitHours: 3.0,
        routineHours: 2.0,
      ),
    ],
    items: [
      PricingItemDto(
        itemType: 2,
        productId: 'prod-2',
        name: 'Item 2',
        qty: 1.0,
        frequency: 1,
        unitPrice: 25000.0,
      ),
    ],
  );

  test('savePricing returns Ok(null) on 200/201 response', () async {
    mockAdapter.handler = (options) {
      expect(options.path, '/v1/sales/proposals/prop-123/pricing');
      expect(options.method, 'POST');
      final body = jsonEncode({'message': 'Success'});
      return ResponseBody.fromString(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    };

    final result = await repository.savePricing('prop-123', requestDto);
    expect(result, isA<Ok<void>>());
  });

  test('savePricing returns ServerFailure on DioException', () async {
    mockAdapter.handler = (options) {
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 400,
          data: {'message': 'Bad Request'},
        ),
        type: DioExceptionType.badResponse,
        message: 'Request failed with status code 400',
      );
    };

    final result = await repository.savePricing('prop-123', requestDto);
    expect(result, isA<Err<void>>());
    final failure = (result as Err<void>).failure;
    expect(failure, isA<ServerFailure>());
  });
}
