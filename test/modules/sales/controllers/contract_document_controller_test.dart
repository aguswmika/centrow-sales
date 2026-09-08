import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_document_controller.dart';
import 'package:centrow_sales/modules/sales/entities/contract_document.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_document_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class FakeContractDocumentRepository implements ContractDocumentRepository {
  Future<Result<ContractDocument>> Function(
    String contractId, {
    bool fromTemplate,
  })?
  getDocumentFn;
  Future<Result<ContractDocument>> Function(
    String contractId,
    Map<String, dynamic> content,
  )?
  saveDocumentFn;
  Future<Result<List<int>>> Function(String contractId)? downloadPdfFn;

  Map<String, dynamic>? lastSavedContent;

  @override
  Future<Result<ContractDocument>> getDocument(
    String contractId, {
    bool fromTemplate = false,
  }) async {
    if (getDocumentFn != null) {
      return getDocumentFn!(contractId, fromTemplate: fromTemplate);
    }
    return Ok(
      ContractDocument(
        documentId: 'doc-1',
        contractId: contractId,
        title: 'Kontrak Layanan',
        source: 'template',
        content: const {},
        placeholders: const [],
      ),
    );
  }

  @override
  Future<Result<ContractDocument>> saveDocument(
    String contractId,
    Map<String, dynamic> content,
  ) async {
    lastSavedContent = content;
    if (saveDocumentFn != null) {
      return saveDocumentFn!(contractId, content);
    }
    return Ok(
      ContractDocument(
        documentId: 'doc-1',
        contractId: contractId,
        title: 'Kontrak Layanan',
        source: 'custom',
        content: content,
        placeholders: const [],
      ),
    );
  }

  @override
  Future<Result<List<int>>> downloadPdf(String contractId) async {
    if (downloadPdfFn != null) {
      return downloadPdfFn!(contractId);
    }
    return const Ok([1, 2, 3]);
  }
}

void main() {
  late FakeContractDocumentRepository fakeRepository;
  late ContractDocumentController controller;

  setUp(() {
    fakeRepository = FakeContractDocumentRepository();
    controller = ContractDocumentController(fakeRepository);
  });

  tearDown(() {
    controller.dispose();
  });

  const sampleDocument = ContractDocument(
    documentId: 'doc-1',
    contractId: 'c1',
    title: 'Perjanjian Kerjasama',
    source: 'template',
    content: {'type': 'doc'},
    placeholders: [],
  );

  group('ContractDocumentController.loadDocument', () {
    test('transitions from UiInitial -> UiLoading -> UiSuccess', () async {
      final completer = Completer<Result<ContractDocument>>();
      fakeRepository.getDocumentFn = (id, {fromTemplate = false}) =>
          completer.future;

      expect(controller.state.value, isA<UiInitial<ContractDocument>>());

      final future = controller.loadDocument('c1');
      expect(controller.state.value, isA<UiLoading<ContractDocument>>());

      completer.complete(const Ok(sampleDocument));
      await future;

      expect(controller.state.value, isA<UiSuccess<ContractDocument>>());
      final success = controller.state.value as UiSuccess<ContractDocument>;
      expect(success.data.contractId, 'c1');
    });

    test('transitions from UiInitial -> UiLoading -> UiFailure', () async {
      final completer = Completer<Result<ContractDocument>>();
      fakeRepository.getDocumentFn = (id, {fromTemplate = false}) =>
          completer.future;

      expect(controller.state.value, isA<UiInitial<ContractDocument>>());

      final future = controller.loadDocument('c1');
      expect(controller.state.value, isA<UiLoading<ContractDocument>>());

      completer.complete(const Err(ServerFailure('Gagal memuat dokumen')));
      await future;

      expect(controller.state.value, isA<UiFailure<ContractDocument>>());
      final failure = controller.state.value as UiFailure<ContractDocument>;
      expect(failure.failure.message, 'Gagal memuat dokumen');
    });
  });

  group('ContractDocumentController.saveDocument', () {
    test('returns true on Ok', () async {
      fakeRepository.saveDocumentFn = (id, content) async =>
          const Ok(sampleDocument);

      final result = await controller.saveDocument('c1', {'key': 'value'});

      expect(result, isTrue);
      expect(fakeRepository.lastSavedContent, {'key': 'value'});
    });

    test('returns false on Err', () async {
      fakeRepository.saveDocumentFn = (id, content) async =>
          const Err(ServerFailure('Gagal menyimpan'));

      final result = await controller.saveDocument('c1', {'key': 'value'});

      expect(result, isFalse);
    });
  });

  group('ContractDocumentController.downloadPdf', () {
    test('transitions from UiInitial -> UiLoading -> UiSuccess', () async {
      final completer = Completer<Result<List<int>>>();
      fakeRepository.downloadPdfFn = (id) => completer.future;

      expect(controller.pdfState.value, isA<UiInitial<List<int>>>());

      final future = controller.downloadPdf('c1');
      expect(controller.pdfState.value, isA<UiLoading<List<int>>>());

      completer.complete(const Ok([1, 2, 3]));
      await future;

      expect(controller.pdfState.value, isA<UiSuccess<List<int>>>());
      final success = controller.pdfState.value as UiSuccess<List<int>>;
      expect(success.data, [1, 2, 3]);
    });

    test('transitions from UiInitial -> UiLoading -> UiFailure', () async {
      final completer = Completer<Result<List<int>>>();
      fakeRepository.downloadPdfFn = (id) => completer.future;

      expect(controller.pdfState.value, isA<UiInitial<List<int>>>());

      final future = controller.downloadPdf('c1');
      expect(controller.pdfState.value, isA<UiLoading<List<int>>>());

      completer.complete(const Err(ServerFailure('Download error')));
      await future;

      expect(controller.pdfState.value, isA<UiFailure<List<int>>>());
      final failure = controller.pdfState.value as UiFailure<List<int>>;
      expect(failure.failure.message, 'Download error');
    });
  });

  group('ContractDocumentController.resetPdfState', () {
    test('resets pdfState back to UiInitial', () async {
      fakeRepository.downloadPdfFn = (id) async => const Ok([1, 2, 3]);
      await controller.downloadPdf('c1');
      expect(controller.pdfState.value, isA<UiSuccess<List<int>>>());

      controller.resetPdfState();
      expect(controller.pdfState.value, isA<UiInitial<List<int>>>());
    });
  });

  group('ContractDocumentController.dispose', () {
    test('disposes signals without throwing', () {
      final ctrl = ContractDocumentController(fakeRepository);
      expect(() => ctrl.dispose(), returnsNormally);
    });
  });
}
