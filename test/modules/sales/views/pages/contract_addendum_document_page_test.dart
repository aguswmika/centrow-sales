import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_document_controller.dart';
import 'package:centrow_sales/modules/sales/entities/addendum_template.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum_document.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_addendum_document_repository.dart';
import 'package:centrow_sales/modules/sales/views/pages/contract_addendum_document_page.dart';
import 'package:centrow_sales/modules/sales/views/widgets/webview_tiptap_editor.dart';

class FakePlatformWebViewController extends PlatformWebViewController {
  FakePlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}

  @override
  Future<void> runJavaScript(String javaScript) async {}
}

class FakePlatformWebViewWidget extends PlatformWebViewWidget {
  FakePlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class FakePlatformNavigationDelegate extends PlatformNavigationDelegate {
  FakePlatformNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}
}

class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return FakePlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return FakePlatformWebViewWidget(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return FakePlatformNavigationDelegate(params);
  }
}

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
    if (getActiveTemplatesFn != null) return getActiveTemplatesFn!();
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
        content: const <String, dynamic>{'type': 'doc', 'content': <dynamic>[]},
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
  TestWidgetsFlutterBinding.ensureInitialized();
  WebViewPlatform.instance = FakeWebViewPlatform();

  late MockContractAddendumDocumentRepository mockRepo;
  late ContractAddendumDocumentController controller;

  setUp(() {
    mockRepo = MockContractAddendumDocumentRepository();
    controller = ContractAddendumDocumentController(mockRepo);
  });

  tearDown(() {
    controller.dispose();
  });

  Widget buildTestableWidget({
    String contractId = 'contract-1',
    String addendumId = 'addendum-1',
    String? initialTemplateId,
    ContractAddendumDocumentController? customController,
  }) {
    return MaterialApp(
      home: ContractAddendumDocumentPage(
        contractId: contractId,
        addendumId: addendumId,
        initialTemplateId: initialTemplateId,
        controller: customController ?? controller,
      ),
    );
  }

  testWidgets('Test loading state displays progress indicator', (tester) async {
    final completer = Completer<Result<ContractAddendumDocument>>();
    mockRepo.getDocumentFn = (id, {templateId}) => completer.future;

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Dokumen Addendum'), findsOneWidget);
  });

  testWidgets(
    'Test error state displays ErrorView and retry re-triggers loadDocument',
    (tester) async {
      var callCount = 0;
      mockRepo.getDocumentFn = (id, {templateId}) async {
        callCount++;
        return const Err(ServerFailure('Gagal memuat dokumen'));
      };

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Gagal memuat dokumen'), findsOneWidget);
      expect(callCount, 1);

      // Tap retry button in ErrorView
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(callCount, 2);
    },
  );

  testWidgets(
    'Test success state displays document editor and action buttons',
    (tester) async {
      mockRepo.getDocumentFn = (id, {templateId}) async => Ok(
        ContractAddendumDocument(
          documentId: 'doc-1',
          addendumId: id,
          templateId: templateId ?? 'tmpl-1',
          title: 'Addendum Contract',
          source: 'template',
          content: const <String, dynamic>{
            'type': 'doc',
            'content': <dynamic>[],
          },
        ),
      );

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('Dokumen Addendum'), findsOneWidget);
      expect(find.text('Unduh PDF'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
      expect(find.byType(WebviewTiptapEditor), findsOneWidget);
    },
  );

  testWidgets('Test clicking Unduh PDF invokes controller downloadPdf', (
    tester,
  ) async {
    var downloadPdfCalled = false;
    mockRepo.getDocumentFn = (id, {templateId}) async => Ok(
      ContractAddendumDocument(
        documentId: 'doc-1',
        addendumId: id,
        templateId: 'tmpl-abc',
        title: 'Addendum Contract',
        source: 'template',
        content: const <String, dynamic>{'type': 'doc', 'content': <dynamic>[]},
      ),
    );
    mockRepo.downloadPdfFn = (id, {templateId}) async {
      downloadPdfCalled = true;
      return const Ok([10, 20, 30]);
    };

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    await tester.tap(find.text('Unduh PDF'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(downloadPdfCalled, isTrue);
    expect(mockRepo.lastPdfAddendumId, 'addendum-1');
    expect(mockRepo.lastPdfTemplateId, 'tmpl-abc');
  });

  testWidgets(
    'Test clicking Simpan invokes saveDocument and shows success SnackBar',
    (tester) async {
      var saveCalled = false;
      mockRepo.getDocumentFn = (id, {templateId}) async => Ok(
        ContractAddendumDocument(
          documentId: 'doc-1',
          addendumId: id,
          templateId: 'tmpl-abc',
          title: 'Addendum Contract',
          source: 'template',
          content: const <String, dynamic>{
            'type': 'doc',
            'content': <dynamic>[],
          },
        ),
      );
      mockRepo.saveDocumentFn = (id, {required content, templateId}) async {
        saveCalled = true;
        return Ok(
          ContractAddendumDocument(
            documentId: 'doc-1',
            addendumId: id,
            templateId: templateId ?? 'tmpl-abc',
            title: 'Addendum Contract',
            source: 'document',
            content: content,
          ),
        );
      };

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      await tester.tap(find.text('Simpan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(saveCalled, isTrue);
      expect(mockRepo.lastSaveAddendumId, 'addendum-1');
      expect(mockRepo.lastSaveTemplateId, 'tmpl-abc');
      expect(find.text('Dokumen addendum berhasil disimpan'), findsOneWidget);
    },
  );

  testWidgets('Test clicking Simpan with failure displays error SnackBar', (
    tester,
  ) async {
    mockRepo.getDocumentFn = (id, {templateId}) async => Ok(
      ContractAddendumDocument(
        documentId: 'doc-1',
        addendumId: id,
        templateId: 'tmpl-abc',
        title: 'Addendum Contract',
        source: 'template',
        content: const <String, dynamic>{'type': 'doc', 'content': <dynamic>[]},
      ),
    );
    mockRepo.saveDocumentFn = (id, {required content, templateId}) async {
      return const Err(ServerFailure('Gagal menyimpan dokumen'));
    };

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    await tester.tap(find.text('Simpan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Gagal menyimpan dokumen'), findsOneWidget);
  });

  testWidgets('PDF effect displays SnackBar when pdfState is UiFailure', (
    tester,
  ) async {
    mockRepo.getDocumentFn = (id, {templateId}) async => Ok(
      ContractAddendumDocument(
        documentId: 'doc-1',
        addendumId: id,
        templateId: 'tmpl-abc',
        title: 'Addendum Contract',
        source: 'template',
        content: const <String, dynamic>{'type': 'doc', 'content': <dynamic>[]},
      ),
    );
    mockRepo.downloadPdfFn = (id, {templateId}) async =>
        const Err(ServerFailure('Gagal mengunduh PDF'));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    await tester.tap(find.text('Unduh PDF'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Gagal mengunduh PDF'), findsOneWidget);
  });

  testWidgets('Resolves controller from getIt when controller is null', (
    tester,
  ) async {
    if (getIt.isRegistered<ContractAddendumDocumentController>()) {
      getIt.unregister<ContractAddendumDocumentController>();
    }
    getIt.registerFactory<ContractAddendumDocumentController>(
      () => ContractAddendumDocumentController(mockRepo),
    );
    addTearDown(() {
      if (getIt.isRegistered<ContractAddendumDocumentController>()) {
        getIt.unregister<ContractAddendumDocumentController>();
      }
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ContractAddendumDocumentPage(
          contractId: 'c-1',
          addendumId: 'a-1',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Dokumen Addendum'), findsOneWidget);
  });
}
