import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';
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
  late ProposalRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.centrow.id'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = ProposalRepositoryImpl(dio);
  });

  final baseProposalJson = {
    'id': 'prop-1',
    'code': 'PROP-2026-0001',
    'customer_id': 'cust-1',
    'customer_name': 'Villa Sari Dewi',
    'service_id': 'srv-1',
    'service_name': 'Termite Protection',
    'version': 1,
    'proposal_date': '2026-09-01',
    'valid_until': '2026-09-30',
    'total_amount': 0.0,
    'status': 'sent',
    'status_label': 'Terkirim',
    'created_at': '2026-09-01T08:00:00Z',
    'address_label': 'Villa Seminyak',
    'address_line': 'Jl. Sunset Road',
  };

  group('ProposalRepositoryImpl.getProposalById', () {
    test(
      'returns Proposal parsed directly from /v1/sales/proposals/\$id response without secondary request to /pricing',
      () async {
        final requestedPaths = <String>[];

        mockAdapter.handler = (options) {
          requestedPaths.add(options.path);
          if (options.path == '/v1/sales/proposals/prop-1') {
            final data = Map<String, dynamic>.from(baseProposalJson);
            data['has_pricing'] = true;
            data['total_amount'] = 5000000.0;
            return ResponseBody.fromString(
              jsonEncode({'data': data}),
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            message: 'Unexpected route: ${options.path}',
          );
        };

        final result = await repository.getProposalById('prop-1');

        expect(result, isA<Ok<Proposal>>());
        final proposal = (result as Ok<Proposal>).value;
        expect(proposal.id, 'prop-1');
        expect(proposal.code, 'PROP-2026-0001');
        expect(proposal.clientName, 'Villa Sari Dewi');
        expect(proposal.serviceName, 'Termite Protection');
        expect(proposal.hasPricing, isTrue);
        expect(proposal.total, 5000000.0);
        // Verify only the single proposal GET request was made, no /pricing call
        expect(requestedPaths, ['/v1/sales/proposals/prop-1']);
      },
    );

    test('returns ServerFailure when proposal is not found (404)', () async {
      mockAdapter.handler = (options) {
        throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 404,
            data: {'message': 'Proposal tidak ditemukan.'},
          ),
          type: DioExceptionType.badResponse,
        );
      };

      final result = await repository.getProposalById('unknown-id');

      expect(result, isA<Err<Proposal>>());
      final failure = (result as Err<Proposal>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Proposal tidak ditemukan.');
    });

    test('returns ServerFailure when response format is invalid', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode('not-a-map'),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getProposalById('prop-1');

      expect(result, isA<Err<Proposal>>());
      final failure = (result as Err<Proposal>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Format respon dari server tidak valid.');
    });
  });
}
