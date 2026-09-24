import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/addendum_template.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum_document.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_document_controller.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_addendum_document_repository.dart';

class MockContractAddendumDocumentRepository
    implements ContractAddendumDocumentRepository {
  Future<Result<List<AddendumTemplate>>> Function()? getActiveTemplatesFn;
  Future<Result<ContractAddendumDocument>> Function(
    String addendumId, {
    String? templateId,
  })?
  getDocumentFn;
  Future<Result<ContractAddendumDocument>> Function(
    String addendumId, {
    required Map<String, dynamic> content,
    String? templateId,
  })?
  saveDocumentFn;
  Future<Result<List<int>>> Function(String addendumId, {String? templateId})?
  downloadPdfFn;

  String? lastGetAddendumId;
  String? lastGetTemplateId;
  String? lastSaveAddendumId;
  Map<String, dynamic>? lastSaveContent;
  String? lastSaveTemplateId;
  String? lastPdfAddendumId;
  String? lastPdfTemplateId;

  @override
  Future<Result<List<AddendumTemplate>>> getActiveTemplates() async {
    if (getActiveTemplatesFn != null) {
      return getActiveTemplatesFn!();
    }
    return const Ok([]);
  }

  @override
  Future<Result<ContractAddendumDocument>> getDocument(
    String addendumId, {
    String? templateId,
  }) async {
    lastGetAddendumId = addendumId;
    lastGetTemplateId = templateId;
    if (getDocumentFn != null) {
      return getDocumentFn!(addendumId, templateId: templateId);
    }
    return Ok(
      ContractAddendumDocument(
        documentId: 'doc-1',
        addendumId: addendumId,
        templateId: templateId ?? 'tmpl-1',
        title: 'Addendum Contract',
        source: 'template',
        content: const {},
      ),
    );
  }

  @override
  Future<Result<ContractAddendumDocument>> saveDocument(
    String addendumId, {
    required Map<String, dynamic> content,
    String? templateId,
  }) async {
    lastSaveAddendumId = addendumId;
    lastSaveContent = content;
    lastSaveTemplateId = templateId;
    if (saveDocumentFn != null) {
      return saveDocumentFn!(
        addendumId,
        content: content,
        templateId: templateId,
      );
    }
    return Ok(
      ContractAddendumDocument(
        documentId: 'doc-1',
        addendumId: addendumId,
        templateId: templateId ?? 'tmpl-1',
        title: 'Addendum Contract',
        source: 'document',
        content: content,
      ),
    );
  }

  @override
  Future<Result<List<int>>> downloadPdf(
    String addendumId, {
    String? templateId,
  }) async {
    lastPdfAddendumId = addendumId;
    lastPdfTemplateId = templateId;
    if (downloadPdfFn != null) {
      return downloadPdfFn!(addendumId, templateId: templateId);
    }
    return const Ok([1, 2, 3]);
  }
}

void main() {
  late MockContractAddendumDocumentRepository mockRepo;
  late ContractAddendumDocumentController controller;

  setUp(() {
    mockRepo = MockContractAddendumDocumentRepository();
    controller = ContractAddendumDocumentController(mockRepo);
  });

  tearDown(() {
    controller.dispose();
  });

  const sampleTemplate = AddendumTemplate(
    id: 'tmpl-1',
    title: 'Template Standar Addendum',
  );

  const sampleDocument = ContractAddendumDocument(
    documentId: 'doc-1',
    addendumId: 'add-1',
    templateId: 'tmpl-1',
    title: 'Addendum #1',
    source: 'template',
    content: {'clause': '1'},
  );

  group('ContractAddendumDocumentController initial states', () {
    test('all states are UiInitial', () {
      expect(
        controller.templatesState.value,
        isA<UiInitial<List<AddendumTemplate>>>(),
      );
      expect(
        controller.state.value,
        isA<UiInitial<ContractAddendumDocument>>(),
      );
      expect(
        controller.saveState.value,
        isA<UiInitial<ContractAddendumDocument>>(),
      );
      expect(controller.pdfState.value, isA<UiInitial<List<int>>>());
    });
  });

  group('ContractAddendumDocumentController.loadActiveTemplates', () {
    test('transitions from UiInitial -> UiLoading -> UiSuccess', () async {
      final completer = Completer<Result<List<AddendumTemplate>>>();
      mockRepo.getActiveTemplatesFn = () => completer.future;

      expect(
        controller.templatesState.value,
        isA<UiInitial<List<AddendumTemplate>>>(),
      );

      final future = controller.loadActiveTemplates();
      expect(
        controller.templatesState.value,
        isA<UiLoading<List<AddendumTemplate>>>(),
      );

      completer.complete(const Ok([sampleTemplate]));
      await future;

      expect(
        controller.templatesState.value,
        isA<UiSuccess<List<AddendumTemplate>>>(),
      );
      final data =
          (controller.templatesState.value as UiSuccess<List<AddendumTemplate>>)
              .data;
      expect(data.length, 1);
      expect(data.first.id, 'tmpl-1');
    });

    test('transitions from UiInitial -> UiLoading -> UiFailure', () async {
      final completer = Completer<Result<List<AddendumTemplate>>>();
      mockRepo.getActiveTemplatesFn = () => completer.future;

      final future = controller.loadActiveTemplates();
      expect(
        controller.templatesState.value,
        isA<UiLoading<List<AddendumTemplate>>>(),
      );

      completer.complete(
        const Err(ServerFailure('Gagal memuat template addendum')),
      );
      await future;

      expect(
        controller.templatesState.value,
        isA<UiFailure<List<AddendumTemplate>>>(),
      );
      final failure =
          (controller.templatesState.value as UiFailure<List<AddendumTemplate>>)
              .failure;
      expect(failure.message, 'Gagal memuat template addendum');
    });

    test('does not update state if disposed before completion', () async {
      final completer = Completer<Result<List<AddendumTemplate>>>();
      mockRepo.getActiveTemplatesFn = () => completer.future;

      final future = controller.loadActiveTemplates();
      controller.dispose();

      completer.complete(const Ok([sampleTemplate]));
      await future;
      // No exception should be thrown
    });
  });

  group('ContractAddendumDocumentController.loadDocument', () {
    test(
      'transitions from UiInitial -> UiLoading -> UiSuccess with templateId',
      () async {
        final completer = Completer<Result<ContractAddendumDocument>>();
        mockRepo.getDocumentFn = (addendumId, {templateId}) => completer.future;

        expect(
          controller.state.value,
          isA<UiInitial<ContractAddendumDocument>>(),
        );

        final future = controller.loadDocument('add-1', templateId: 'tmpl-1');
        expect(
          controller.state.value,
          isA<UiLoading<ContractAddendumDocument>>(),
        );

        completer.complete(const Ok(sampleDocument));
        await future;

        expect(mockRepo.lastGetAddendumId, 'add-1');
        expect(mockRepo.lastGetTemplateId, 'tmpl-1');
        expect(
          controller.state.value,
          isA<UiSuccess<ContractAddendumDocument>>(),
        );
        final doc =
            (controller.state.value as UiSuccess<ContractAddendumDocument>)
                .data;
        expect(doc.addendumId, 'add-1');
        expect(doc.title, 'Addendum #1');
      },
    );

    test('transitions from UiInitial -> UiLoading -> UiFailure', () async {
      final completer = Completer<Result<ContractAddendumDocument>>();
      mockRepo.getDocumentFn = (addendumId, {templateId}) => completer.future;

      final future = controller.loadDocument('add-1');
      expect(
        controller.state.value,
        isA<UiLoading<ContractAddendumDocument>>(),
      );

      completer.complete(const Err(ServerFailure('Gagal memuat dokumen')));
      await future;

      expect(
        controller.state.value,
        isA<UiFailure<ContractAddendumDocument>>(),
      );
      final failure =
          (controller.state.value as UiFailure<ContractAddendumDocument>)
              .failure;
      expect(failure.message, 'Gagal memuat dokumen');
    });

    test('does not update state if disposed before completion', () async {
      final completer = Completer<Result<ContractAddendumDocument>>();
      mockRepo.getDocumentFn = (addendumId, {templateId}) => completer.future;

      final future = controller.loadDocument('add-1');
      controller.dispose();

      completer.complete(const Ok(sampleDocument));
      await future;
      // No exception should be thrown
    });
  });

  group('ContractAddendumDocumentController.saveDocument', () {
    const savedDoc = ContractAddendumDocument(
      documentId: 'doc-saved-1',
      addendumId: 'add-1',
      templateId: 'tmpl-1',
      title: 'Addendum #1',
      source: 'document',
      content: {'clause': '1', 'updated': true},
    );

    test('success updates both saveState and state, returns Ok', () async {
      final completer = Completer<Result<ContractAddendumDocument>>();
      mockRepo.saveDocumentFn = (addendumId, {required content, templateId}) =>
          completer.future;

      expect(
        controller.saveState.value,
        isA<UiInitial<ContractAddendumDocument>>(),
      );
      expect(
        controller.state.value,
        isA<UiInitial<ContractAddendumDocument>>(),
      );

      final future = controller.saveDocument(
        'add-1',
        content: {'clause': '1', 'updated': true},
        templateId: 'tmpl-1',
      );

      expect(
        controller.saveState.value,
        isA<UiLoading<ContractAddendumDocument>>(),
      );
      // state should not change to loading
      expect(
        controller.state.value,
        isA<UiInitial<ContractAddendumDocument>>(),
      );

      completer.complete(const Ok(savedDoc));
      final result = await future;

      expect(mockRepo.lastSaveAddendumId, 'add-1');
      expect(mockRepo.lastSaveContent, {'clause': '1', 'updated': true});
      expect(mockRepo.lastSaveTemplateId, 'tmpl-1');

      expect(result, isA<Ok<ContractAddendumDocument>>());
      expect(
        controller.saveState.value,
        isA<UiSuccess<ContractAddendumDocument>>(),
      );
      expect(
        controller.state.value,
        isA<UiSuccess<ContractAddendumDocument>>(),
      );
      final successSave =
          controller.saveState.value as UiSuccess<ContractAddendumDocument>;
      expect(successSave.data.documentId, 'doc-saved-1');

      final successState =
          controller.state.value as UiSuccess<ContractAddendumDocument>;
      expect(successState.data.documentId, 'doc-saved-1');
    });

    test('failure updates saveState to UiFailure and returns Err', () async {
      final completer = Completer<Result<ContractAddendumDocument>>();
      mockRepo.saveDocumentFn = (addendumId, {required content, templateId}) =>
          completer.future;

      final future = controller.saveDocument('add-1', content: {'clause': '1'});

      expect(
        controller.saveState.value,
        isA<UiLoading<ContractAddendumDocument>>(),
      );

      completer.complete(const Err(ServerFailure('Gagal menyimpan dokumen')));
      final result = await future;

      expect(result, isA<Err<ContractAddendumDocument>>());
      expect(
        controller.saveState.value,
        isA<UiFailure<ContractAddendumDocument>>(),
      );
      final failure =
          (controller.saveState.value as UiFailure<ContractAddendumDocument>)
              .failure;
      expect(failure.message, 'Gagal menyimpan dokumen');

      // state remains UiInitial
      expect(
        controller.state.value,
        isA<UiInitial<ContractAddendumDocument>>(),
      );
    });

    test('returns result and does not crash if disposed during call', () async {
      final completer = Completer<Result<ContractAddendumDocument>>();
      mockRepo.saveDocumentFn = (addendumId, {required content, templateId}) =>
          completer.future;

      final future = controller.saveDocument('add-1', content: {'clause': '1'});
      controller.dispose();

      completer.complete(const Ok(savedDoc));
      final result = await future;

      expect(result, isA<Ok<ContractAddendumDocument>>());
    });
  });

  group('ContractAddendumDocumentController.downloadPdf', () {
    test('transitions from UiInitial -> UiLoading -> UiSuccess', () async {
      final completer = Completer<Result<List<int>>>();
      mockRepo.downloadPdfFn = (addendumId, {templateId}) => completer.future;

      expect(controller.pdfState.value, isA<UiInitial<List<int>>>());

      final future = controller.downloadPdf('add-1', templateId: 'tmpl-1');
      expect(controller.pdfState.value, isA<UiLoading<List<int>>>());

      completer.complete(const Ok([10, 20, 30]));
      final result = await future;

      expect(mockRepo.lastPdfAddendumId, 'add-1');
      expect(mockRepo.lastPdfTemplateId, 'tmpl-1');
      expect(result, isA<Ok<List<int>>>());
      expect(controller.pdfState.value, isA<UiSuccess<List<int>>>());
      final success = controller.pdfState.value as UiSuccess<List<int>>;
      expect(success.data, [10, 20, 30]);
    });

    test('transitions from UiInitial -> UiLoading -> UiFailure', () async {
      final completer = Completer<Result<List<int>>>();
      mockRepo.downloadPdfFn = (addendumId, {templateId}) => completer.future;

      final future = controller.downloadPdf('add-1');
      expect(controller.pdfState.value, isA<UiLoading<List<int>>>());

      completer.complete(const Err(ServerFailure('Gagal mendownload PDF')));
      final result = await future;

      expect(result, isA<Err<List<int>>>());
      expect(controller.pdfState.value, isA<UiFailure<List<int>>>());
      final failure = controller.pdfState.value as UiFailure<List<int>>;
      expect(failure.failure.message, 'Gagal mendownload PDF');
    });

    test('returns result and does not crash if disposed during call', () async {
      final completer = Completer<Result<List<int>>>();
      mockRepo.downloadPdfFn = (addendumId, {templateId}) => completer.future;

      final future = controller.downloadPdf('add-1');
      controller.dispose();

      completer.complete(const Ok([1, 2]));
      final result = await future;

      expect(result, isA<Ok<List<int>>>());
    });
  });

  group('resetSaveState and resetPdfState', () {
    test('resetSaveState resets saveState back to UiInitial', () async {
      mockRepo.saveDocumentFn =
          (addendumId, {required content, templateId}) async =>
              const Ok(sampleDocument);

      await controller.saveDocument('add-1', content: const {});
      expect(
        controller.saveState.value,
        isA<UiSuccess<ContractAddendumDocument>>(),
      );

      controller.resetSaveState();
      expect(
        controller.saveState.value,
        isA<UiInitial<ContractAddendumDocument>>(),
      );
    });

    test('resetPdfState resets pdfState back to UiInitial', () async {
      mockRepo.downloadPdfFn = (addendumId, {templateId}) async =>
          const Ok([1, 2, 3]);

      await controller.downloadPdf('add-1');
      expect(controller.pdfState.value, isA<UiSuccess<List<int>>>());

      controller.resetPdfState();
      expect(controller.pdfState.value, isA<UiInitial<List<int>>>());
    });

    test('reset states when disposed does not throw', () {
      controller.dispose();
      expect(() => controller.resetSaveState(), returnsNormally);
      expect(() => controller.resetPdfState(), returnsNormally);
    });
  });

  group('dispose', () {
    test('disposes signals without throwing', () {
      final ctrl = ContractAddendumDocumentController(mockRepo);
      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
