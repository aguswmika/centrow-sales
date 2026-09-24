import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/addendum_template.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum_document.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_addendum_document_repository.dart';
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
  late ContractAddendumDocumentRepositoryImpl repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.centrow.id'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    repository = ContractAddendumDocumentRepositoryImpl(dio);
  });

  const addendumId = 'add-123';
  const templateId = 'tpl-456';

  final validDocumentJson = {
    'document_id': 'doc-789',
    'addendum_id': addendumId,
    'template_id': templateId,
    'title': 'Addendum Perjanjian Kerjasama',
    'source': 'template',
    'content': {
      'type': 'doc',
      'content': [
        {
          'type': 'paragraph',
          'content': [
            {'type': 'text', 'text': 'Isi addendum kontrak'},
          ],
        },
      ],
    },
    'updated_at': '2026-09-22T10:00:00.000Z',
  };

  group('ContractAddendumDocumentRepositoryImpl.getActiveTemplates', () {
    test('returns Ok<List<AddendumTemplate>> on 200 with data list', () async {
      mockAdapter.handler = (options) {
        expect(options.method, 'GET');
        expect(options.path, '/v1/sales/addendum-templates/active');

        return ResponseBody.fromString(
          jsonEncode({
            'data': [
              {'id': 'tpl-1', 'title': 'Template Perpanjangan'},
              {'id': 'tpl-2', 'title': 'Template Perubahan Biaya'},
            ],
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getActiveTemplates();

      expect(result, isA<Ok<List<AddendumTemplate>>>());
      final templates = (result as Ok<List<AddendumTemplate>>).value;
      expect(templates.length, 2);
      expect(templates[0].id, 'tpl-1');
      expect(templates[0].title, 'Template Perpanjangan');
      expect(templates[1].id, 'tpl-2');
      expect(templates[1].title, 'Template Perubahan Biaya');
    });

    test(
      'returns Ok<List<AddendumTemplate>> on 200 with direct list',
      () async {
        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            jsonEncode([
              {'id': 'tpl-3', 'title': 'Template Tambahan Item'},
            ]),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getActiveTemplates();

        expect(result, isA<Ok<List<AddendumTemplate>>>());
        final templates = (result as Ok<List<AddendumTemplate>>).value;
        expect(templates.length, 1);
        expect(templates.first.id, 'tpl-3');
        expect(templates.first.title, 'Template Tambahan Item');
      },
    );

    test(
      'returns Ok<List<AddendumTemplate>> on 200 with items in data map',
      () async {
        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            jsonEncode({
              'data': {
                'items': [
                  {'id': 'tpl-4', 'title': 'Template Pindah Lokasi'},
                ],
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getActiveTemplates();

        expect(result, isA<Ok<List<AddendumTemplate>>>());
        final templates = (result as Ok<List<AddendumTemplate>>).value;
        expect(templates.length, 1);
        expect(templates.first.id, 'tpl-4');
      },
    );

    test(
      'returns Err<ServerFailure> on invalid server response format',
      () async {
        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            jsonEncode({'data': 'not a list'}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getActiveTemplates();

        expect(result, isA<Err<List<AddendumTemplate>>>());
        final failure = (result as Err<List<AddendumTemplate>>).failure;
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Format respon dari server tidak valid.');
      },
    );

    test(
      'returns Err<ServerFailure> on 400 DioException with error message',
      () async {
        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            jsonEncode({'message': 'Tidak ada template aktif'}),
            400,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getActiveTemplates();

        expect(result, isA<Err<List<AddendumTemplate>>>());
        final failure = (result as Err<List<AddendumTemplate>>).failure;
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Tidak ada template aktif');
      },
    );

    test('returns Err on connection failure', () async {
      mockAdapter.handler = (options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      };

      final result = await repository.getActiveTemplates();

      expect(result, isA<Err<List<AddendumTemplate>>>());
      final failure = (result as Err<List<AddendumTemplate>>).failure;
      expect(failure, isA<NetworkFailure>());
    });
  });

  group('ContractAddendumDocumentRepositoryImpl.getDocument', () {
    test(
      'returns Ok<ContractAddendumDocument> on 200 without templateId',
      () async {
        mockAdapter.handler = (options) {
          expect(options.method, 'GET');
          expect(
            options.path,
            '/v1/sales/contract-addendums/$addendumId/document',
          );
          expect(options.queryParameters.containsKey('template_id'), isFalse);

          return ResponseBody.fromString(
            jsonEncode({'data': validDocumentJson}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getDocument(addendumId);

        expect(result, isA<Ok<ContractAddendumDocument>>());
        final doc = (result as Ok<ContractAddendumDocument>).value;
        expect(doc.addendumId, addendumId);
        expect(doc.documentId, 'doc-789');
        expect(doc.templateId, templateId);
        expect(doc.title, 'Addendum Perjanjian Kerjasama');
        expect(doc.source, 'template');
        expect(doc.content['type'], 'doc');
        expect(doc.updatedAt, '2026-09-22T10:00:00.000Z');
      },
    );

    test(
      'passes template_id query parameter when templateId is provided',
      () async {
        bool capturedTemplateId = false;

        mockAdapter.handler = (options) {
          capturedTemplateId =
              options.queryParameters['template_id'] == 'tpl-custom';
          return ResponseBody.fromString(
            jsonEncode({'data': validDocumentJson}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getDocument(
          addendumId,
          templateId: 'tpl-custom',
        );

        expect(capturedTemplateId, isTrue);
        expect(result, isA<Ok<ContractAddendumDocument>>());
      },
    );

    test(
      'does not pass template_id query parameter when templateId is empty',
      () async {
        bool capturedTemplateId = false;

        mockAdapter.handler = (options) {
          capturedTemplateId = options.queryParameters.containsKey(
            'template_id',
          );
          return ResponseBody.fromString(
            jsonEncode({'data': validDocumentJson}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getDocument(addendumId, templateId: '');

        expect(capturedTemplateId, isFalse);
        expect(result, isA<Ok<ContractAddendumDocument>>());
      },
    );

    test('returns Err<ServerFailure> on invalid response format', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode('invalid'),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getDocument(addendumId);

      expect(result, isA<Err<ContractAddendumDocument>>());
      final failure = (result as Err<ContractAddendumDocument>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Format respon dari server tidak valid.');
    });

    test(
      'returns Err<ServerFailure> on 404 DioException with error message',
      () async {
        mockAdapter.handler = (options) {
          return ResponseBody.fromString(
            jsonEncode({'message': 'Dokumen addendum tidak ditemukan'}),
            404,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getDocument(addendumId);

        expect(result, isA<Err<ContractAddendumDocument>>());
        final failure = (result as Err<ContractAddendumDocument>).failure;
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Dokumen addendum tidak ditemukan');
      },
    );
  });

  group('ContractAddendumDocumentRepositoryImpl.saveDocument', () {
    final newContent = {
      'type': 'doc',
      'content': [
        {
          'type': 'paragraph',
          'content': [
            {'type': 'text', 'text': 'Konten dokumen disimpan'},
          ],
        },
      ],
    };

    test(
      'returns Ok<ContractAddendumDocument> on 200 without templateId',
      () async {
        mockAdapter.handler = (options) {
          expect(options.method, 'PUT');
          expect(
            options.path,
            '/v1/sales/contract-addendums/$addendumId/document',
          );
          expect(options.data, {'content': newContent});

          final responseJson = Map<String, dynamic>.from(validDocumentJson);
          responseJson['content'] = newContent;
          responseJson['source'] = 'document';

          return ResponseBody.fromString(
            jsonEncode({'data': responseJson}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.saveDocument(
          addendumId,
          content: newContent,
        );

        expect(result, isA<Ok<ContractAddendumDocument>>());
        final doc = (result as Ok<ContractAddendumDocument>).value;
        expect(doc.source, 'document');
        expect(doc.content, newContent);
      },
    );

    test('passes template_id in payload when templateId is provided', () async {
      mockAdapter.handler = (options) {
        expect(options.method, 'PUT');
        final data = options.data as Map<String, dynamic>;
        expect(data['content'], newContent);
        expect(data['template_id'], 'tpl-new');

        return ResponseBody.fromString(
          jsonEncode({'data': validDocumentJson}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.saveDocument(
        addendumId,
        content: newContent,
        templateId: 'tpl-new',
      );

      expect(result, isA<Ok<ContractAddendumDocument>>());
    });

    test('does not pass template_id when templateId is empty', () async {
      mockAdapter.handler = (options) {
        final data = options.data as Map<String, dynamic>;
        expect(data.containsKey('template_id'), isFalse);

        return ResponseBody.fromString(
          jsonEncode({'data': validDocumentJson}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.saveDocument(
        addendumId,
        content: newContent,
        templateId: '',
      );

      expect(result, isA<Ok<ContractAddendumDocument>>());
    });

    test('returns Err<ServerFailure> on 400 DioException', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Konten dokumen addendum tidak valid'}),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.saveDocument(
        addendumId,
        content: {'invalid': true},
      );

      expect(result, isA<Err<ContractAddendumDocument>>());
      final failure = (result as Err<ContractAddendumDocument>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Konten dokumen addendum tidak valid');
    });

    test('returns Err<ServerFailure> on invalid response format', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode('invalid'),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.saveDocument(
        addendumId,
        content: newContent,
      );

      expect(result, isA<Err<ContractAddendumDocument>>());
      final failure = (result as Err<ContractAddendumDocument>).failure;
      expect(failure, isA<ServerFailure>());
    });
  });

  group('ContractAddendumDocumentRepositoryImpl.downloadPdf', () {
    final pdfBytes = [0x25, 0x50, 0x44, 0x46, 0x2D]; // %PDF-

    test(
      'returns Ok<List<int>> when bytes returned without templateId',
      () async {
        mockAdapter.handler = (options) {
          expect(options.method, 'GET');
          expect(
            options.path,
            '/v1/sales/contract-addendums/$addendumId/document/pdf',
          );
          expect(options.responseType, ResponseType.bytes);
          expect(options.queryParameters.containsKey('template_id'), isFalse);

          return ResponseBody.fromBytes(
            Uint8List.fromList(pdfBytes),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/pdf'],
            },
          );
        };

        final result = await repository.downloadPdf(addendumId);

        expect(result, isA<Ok<List<int>>>());
        final bytes = (result as Ok<List<int>>).value;
        expect(bytes, pdfBytes);
      },
    );

    test(
      'passes template_id query parameter when templateId is provided',
      () async {
        bool capturedTemplateId = false;

        mockAdapter.handler = (options) {
          capturedTemplateId =
              options.queryParameters['template_id'] == 'tpl-pdf';
          return ResponseBody.fromBytes(
            Uint8List.fromList(pdfBytes),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/pdf'],
            },
          );
        };

        final result = await repository.downloadPdf(
          addendumId,
          templateId: 'tpl-pdf',
        );

        expect(capturedTemplateId, isTrue);
        expect(result, isA<Ok<List<int>>>());
      },
    );

    test('returns Err<ServerFailure> when bytes returned are empty', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromBytes(
          Uint8List.fromList([]),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/pdf'],
          },
        );
      };

      final result = await repository.downloadPdf(addendumId);

      expect(result, isA<Err<List<int>>>());
      final failure = (result as Err<List<int>>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'File PDF kosong atau tidak valid.');
    });

    test(
      'handles DioException and extracts error message from JSON in byte response',
      () async {
        final errorPayload = jsonEncode({'message': 'PDF addendum belum siap'});
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

        final result = await repository.downloadPdf(addendumId);

        expect(result, isA<Err<List<int>>>());
        final failure = (result as Err<List<int>>).failure;
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'PDF addendum belum siap');
      },
    );

    test('handles DioException with map data', () async {
      mockAdapter.handler = (options) {
        throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 500,
            data: {'message': 'Gagal men-generate PDF'},
          ),
          type: DioExceptionType.badResponse,
        );
      };

      final result = await repository.downloadPdf(addendumId);

      expect(result, isA<Err<List<int>>>());
      final failure = (result as Err<List<int>>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Gagal men-generate PDF');
    });
  });
}
