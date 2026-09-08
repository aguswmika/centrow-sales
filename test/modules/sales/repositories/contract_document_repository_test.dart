import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/contract_document.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_document_repository.dart';
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
  late ContractDocumentRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.centrow.id'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = ContractDocumentRepositoryImpl(dio);
  });

  const contractId = 'c1';

  final validDocumentJson = {
    'document_id': 'doc-123',
    'contract_id': contractId,
    'template_id': 'tpl-456',
    'title': 'Perjanjian Kerjasama',
    'source': 'template',
    'content': {
      'type': 'doc',
      'content': [
        {
          'type': 'paragraph',
          'content': [
            {'type': 'text', 'text': 'Isi kontrak'},
          ],
        },
      ],
    },
    'theme': 1,
    'placeholders': [
      {'tag': '{{CUSTOMER_NAME}}', 'label': 'Nama Pelanggan'},
    ],
    'updated_at': '2026-09-07T10:00:00.000Z',
  };

  group('ContractDocumentRepositoryImpl.getDocument', () {
    test('returns Ok<ContractDocument> on 200 with valid data', () async {
      mockAdapter.handler = (options) {
        expect(options.method, 'GET');
        expect(options.path, '/v1/sales/contracts/$contractId/document');
        expect(options.queryParameters.containsKey('from_template'), isFalse);

        return ResponseBody.fromString(
          jsonEncode({'data': validDocumentJson}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getDocument(contractId);

      expect(result, isA<Ok<ContractDocument>>());
      final doc = (result as Ok<ContractDocument>).value;
      expect(doc.contractId, contractId);
      expect(doc.documentId, 'doc-123');
      expect(doc.templateId, 'tpl-456');
      expect(doc.title, 'Perjanjian Kerjasama');
      expect(doc.source, 'template');
      expect(doc.theme, 1);
      expect(doc.content['type'], 'doc');
      expect(doc.placeholders.length, 1);
      expect(doc.placeholders.first.tag, '{{CUSTOMER_NAME}}');
      expect(doc.placeholders.first.label, 'Nama Pelanggan');
      expect(doc.updatedAt, isNotNull);
    });

    test('returns Err<ServerFailure> on 400 with API error message', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Template kontrak belum dikonfigurasi'}),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getDocument(contractId);

      expect(result, isA<Err<ContractDocument>>());
      final failure = (result as Err<ContractDocument>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Template kontrak belum dikonfigurasi');
    });

    test('passes from_template query parameter when true', () async {
      bool capturedFromTemplate = false;
      mockAdapter.handler = (options) {
        capturedFromTemplate = options.queryParameters['from_template'] == true;
        return ResponseBody.fromString(
          jsonEncode({'data': validDocumentJson}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getDocument(
        contractId,
        fromTemplate: true,
      );

      expect(capturedFromTemplate, isTrue);
      expect(result, isA<Ok<ContractDocument>>());
    });
  });

  group('ContractDocumentRepositoryImpl.saveDocument', () {
    test('returns Ok<ContractDocument> on 200', () async {
      final updatedContent = {
        'type': 'doc',
        'content': [
          {
            'type': 'paragraph',
            'content': [
              {'type': 'text', 'text': 'Kontrak yang telah diedit'},
            ],
          },
        ],
      };

      mockAdapter.handler = (options) {
        expect(options.method, 'PUT');
        expect(options.path, '/v1/sales/contracts/$contractId/document');
        expect(options.data, {'content': updatedContent});

        final responseJson = Map<String, dynamic>.from(validDocumentJson);
        responseJson['content'] = updatedContent;
        responseJson['source'] = 'custom';

        return ResponseBody.fromString(
          jsonEncode({'data': responseJson}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.saveDocument(contractId, updatedContent);

      expect(result, isA<Ok<ContractDocument>>());
      final doc = (result as Ok<ContractDocument>).value;
      expect(doc.source, 'custom');
      expect(doc.content, updatedContent);
    });

    test('returns Err<ServerFailure> on 400', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Konten dokumen tidak valid'}),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.saveDocument(contractId, {
        'invalid': true,
      });

      expect(result, isA<Err<ContractDocument>>());
      final failure = (result as Err<ContractDocument>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Konten dokumen tidak valid');
    });
  });

  group('ContractDocumentRepositoryImpl.downloadPdf', () {
    test('returns Ok<List<int>> when bytes returned', () async {
      final pdfBytes = [0x25, 0x50, 0x44, 0x46, 0x2D]; // %PDF-

      mockAdapter.handler = (options) {
        expect(options.method, 'GET');
        expect(options.path, '/v1/sales/contracts/$contractId/document/pdf');
        expect(options.responseType, ResponseType.bytes);

        return ResponseBody.fromBytes(
          Uint8List.fromList(pdfBytes),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/pdf'],
          },
        );
      };

      final result = await repository.downloadPdf(contractId);

      expect(result, isA<Ok<List<int>>>());
      final bytes = (result as Ok<List<int>>).value;
      expect(bytes, pdfBytes);
    });

    test('handles DioException and extracts error message', () async {
      final errorPayload = jsonEncode({'message': 'PDF belum siap'});
      final errorBytes = utf8.encode(errorPayload);

      mockAdapter.handler = (options) {
        return ResponseBody.fromBytes(
          Uint8List.fromList(errorBytes),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.downloadPdf(contractId);

      expect(result, isA<Err<List<int>>>());
      final failure = (result as Err<List<int>>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'PDF belum siap');
    });
  });
}
