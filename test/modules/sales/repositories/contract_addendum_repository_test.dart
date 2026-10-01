import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_addendum_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_addendum_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';

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
  late ContractAddendumRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://erp.nohama.id/api'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = ContractAddendumRepositoryImpl(dio);
  });

  group('ContractAddendumRepository', () {
    const contractId = 'ctr-123';

    test('getAddendums parses list response successfully', () async {
      final mockData = {
        'data': [
          {
            'id': 'add-1',
            'contract_id': contractId,
            'visit_delta': 2,
            'old_total_visits': 10,
            'new_total_visits': 12,
            'old_contract_value': 10000000.0,
            'new_contract_value': 12000000.0,
            'reason': 'Klien meminta penambahan',
            'created_by': 'Admin',
            'created_at': '2026-03-01 10:00:00',
          },
        ],
      };

      mockAdapter.handler = (options) {
        expect(options.path, '/v1/sales/contracts/$contractId/addendums');
        expect(options.method, 'GET');
        return ResponseBody.fromString(
          jsonEncode(mockData),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getAddendums(contractId);
      expect(result, isA<Ok<List<ContractAddendum>>>());
      final list = (result as Ok<List<ContractAddendum>>).value;
      expect(list.length, 1);
      expect(list.first.id, 'add-1');
      expect(list.first.visitDelta, 2);
    });

    const sampleRequest = CreateContractAddendumRequestDto(
      contractMonths: 12,
      visitFrequency: 2,
      totalVisits: 24,
      markupType: 1,
      markupValue: 10.0,
      discountAmount: 500000.0,
      taxPercentage: 11.0,
      scheduleWorkOrderType: 2,
      supplies: [
        PricingSupplyDto(
          supplyType: 1,
          name: 'Chemical A',
          uomCode: 'BTL',
          frequency: 24,
        ),
      ],
      workers: [
        PricingWorkerDto(
          productId: 'p-1',
          firstVisitMinutes: 60,
          routineMinutes: 45,
        ),
      ],
      items: [
        PricingItemDto(
          itemType: 1,
          name: 'Equipment',
          qty: 2,
          frequency: 1,
          unitPrice: 100000,
        ),
      ],
      reason: 'Perluasan gedung',
    );

    test('createAddendum sends payload and parses created addendum', () async {
      final mockCreated = {
        'data': {
          'id': 'add-new',
          'contract_id': contractId,
          'visit_delta': 3,
          'old_total_visits': 12,
          'new_total_visits': 15,
          'old_contract_value': 12000000.0,
          'new_contract_value': 15000000.0,
          'reason': 'Perluasan gedung',
          'created_by': 'Sales Rep',
          'created_at': '2026-03-02 11:00:00',
        },
      };

      mockAdapter.handler = (options) {
        expect(options.path, '/v1/sales/contracts/$contractId/addendums');
        expect(options.method, 'POST');
        final body = options.data as Map<String, dynamic>;
        expect(body['contract_months'], 12);
        expect(body['visit_frequency'], 2);
        expect(body['total_visits'], 24);
        expect(body['markup_type'], 1);
        expect(body['markup_value'], 10.0);
        expect(body['discount_amount'], 500000.0);
        expect(body['tax_percentage'], 11.0);
        expect(body['schedule_work_order_type'], 2);
        expect(body['supplies'], isNotEmpty);
        expect(body['workers'], isNotEmpty);
        expect(body['items'], isNotEmpty);
        expect(body['reason'], 'Perluasan gedung');

        return ResponseBody.fromString(
          jsonEncode(mockCreated),
          201,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.createAddendum(contractId, sampleRequest);

      expect(result, isA<Ok<ContractAddendum>>());
      final addendum = (result as Ok<ContractAddendum>).value;
      expect(addendum.id, 'add-new');
      expect(addendum.visitDelta, 3);
      expect(addendum.newTotalVisits, 15);
    });

    test(
      'fromPricingRequest propagates scheduleWorkOrderType from pricing DTO',
      () {
        const pricingRequest = CreatePricingRequestDto(
          contractMonths: 6,
          visitFrequency: 1,
          totalVisits: 6,
          markupType: 1,
          markupValue: 0.0,
          discountAmount: 0.0,
          taxPercentage: 0.0,
          scheduleWorkOrderType: 2,
          supplies: [],
          workers: [],
          items: [],
        );

        final addendumDto = CreateContractAddendumRequestDto.fromPricingRequest(
          pricingRequest,
          reason: 'Test reason',
        );

        expect(addendumDto.scheduleWorkOrderType, 2);
        expect(addendumDto.toJson()['schedule_work_order_type'], 2);
      },
    );

    test(
      'createAddendum maps HTTP 409 concurrency conflict error with custom message',
      () async {
        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            jsonEncode({'message': 'Contract version conflict'}),
            409,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.createAddendum(
          contractId,
          sampleRequest,
        );

        expect(result, isA<Err<ContractAddendum>>());
        final failure = (result as Err<ContractAddendum>).failure;
        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).statusCode, 409);
        expect(failure.message, contains('Contract version conflict'));
      },
    );

    test(
      'createAddendum maps HTTP 409 concurrency conflict error with default message',
      () async {
        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            jsonEncode({}),
            409,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.createAddendum(
          contractId,
          sampleRequest,
        );

        expect(result, isA<Err<ContractAddendum>>());
        final failure = (result as Err<ContractAddendum>).failure;
        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).statusCode, 409);
        expect(
          failure.message,
          'Kontrak telah diubah oleh pengguna lain. Silakan muat ulang dan coba lagi',
        );
      },
    );

    test('createAddendum maps HTTP 400 validation error', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Total visits must be greater than zero'}),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.createAddendum(contractId, sampleRequest);

      expect(result, isA<Err<ContractAddendum>>());
      final failure = (result as Err<ContractAddendum>).failure;
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 400);
      expect(failure.message, 'Total visits must be greater than zero');
    });
  });
}
