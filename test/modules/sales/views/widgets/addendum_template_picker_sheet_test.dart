import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_document_controller.dart';
import 'package:centrow_sales/modules/sales/entities/addendum_template.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum_document.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_addendum_document_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/addendum_template_picker_sheet.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class MockContractAddendumDocumentRepository
    implements ContractAddendumDocumentRepository {
  Future<Result<List<AddendumTemplate>>> Function()? getActiveTemplatesFn;
  int getActiveTemplatesCalls = 0;

  @override
  Future<Result<List<AddendumTemplate>>> getActiveTemplates() async {
    getActiveTemplatesCalls++;
    if (getActiveTemplatesFn != null) {
      return getActiveTemplatesFn!();
    }
    return const Ok([]);
  }

  @override
  Future<Result<ContractAddendumDocument>> getDocument(
    String addendumId, {
    String? templateId,
  }) async => const Err(ServerFailure('Not implemented'));

  @override
  Future<Result<ContractAddendumDocument>> saveDocument(
    String addendumId, {
    required Map<String, dynamic> content,
    String? templateId,
  }) async => const Err(ServerFailure('Not implemented'));

  @override
  Future<Result<List<int>>> downloadPdf(
    String addendumId, {
    String? templateId,
  }) async => const Err(ServerFailure('Not implemented'));
}

void main() {
  late MockContractAddendumDocumentRepository mockRepository;
  late ContractAddendumDocumentController controller;

  setUp(() {
    mockRepository = MockContractAddendumDocumentRepository();
    controller = ContractAddendumDocumentController(mockRepository);

    if (getIt.isRegistered<ContractAddendumDocumentRepository>()) {
      getIt.unregister<ContractAddendumDocumentRepository>();
    }
    if (getIt.isRegistered<ContractAddendumDocumentController>()) {
      getIt.unregister<ContractAddendumDocumentController>();
    }

    getIt.registerSingleton<ContractAddendumDocumentRepository>(mockRepository);
    getIt.registerFactory<ContractAddendumDocumentController>(
      () => ContractAddendumDocumentController(
        getIt<ContractAddendumDocumentRepository>(),
      ),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<ContractAddendumDocumentRepository>()) {
      getIt.unregister<ContractAddendumDocumentRepository>();
    }
    if (getIt.isRegistered<ContractAddendumDocumentController>()) {
      getIt.unregister<ContractAddendumDocumentController>();
    }
    controller.dispose();
  });

  group('AddendumTemplatePickerSheet', () {
    testWidgets('renders loading state with CircularProgressIndicator', (
      tester,
    ) async {
      final completer = Completer<Result<List<AddendumTemplate>>>();
      mockRepository.getActiveTemplatesFn = () => completer.future;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddendumTemplatePickerSheet(controller: controller),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Pilih Template Addendum'), findsOneWidget);
      expect(
        find.text(
          'Pilih template dokumen untuk mengawali draf dokumen addendum ini.',
        ),
        findsOneWidget,
      );

      completer.complete(const Ok([]));
      await tester.pumpAndSettle();
    });

    testWidgets('renders failure state with error message and retry button', (
      tester,
    ) async {
      mockRepository.getActiveTemplatesFn = () async =>
          const Err(ServerFailure('Gagal memuat template addendum'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddendumTemplatePickerSheet(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat template addendum'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Verify retry calls loadActiveTemplates again
      mockRepository.getActiveTemplatesFn = () async =>
          const Ok([AddendumTemplate(id: 'tmpl-1', title: 'Template Retried')]);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Template Retried'), findsOneWidget);
    });

    testWidgets('renders empty state when no active templates are available', (
      tester,
    ) async {
      mockRepository.getActiveTemplatesFn = () async => const Ok([]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddendumTemplatePickerSheet(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Template Aktif'), findsOneWidget);
      expect(
        find.text(
          'Belum ada template addendum aktif yang tersedia. Hubungi administrator.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets(
      'renders template list and tapping one pops with selected template',
      (tester) async {
        const templates = [
          AddendumTemplate(id: 'tmpl-1', title: 'Perpanjangan Waktu Kontrak'),
          AddendumTemplate(id: 'tmpl-2', title: 'Perubahan Nilai Kontrak'),
        ];
        mockRepository.getActiveTemplatesFn = () async => const Ok(templates);

        AddendumTemplate? selectedTemplate;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      selectedTemplate = await AddendumTemplatePickerSheet.show(
                        context,
                        controller: controller,
                      );
                    },
                    child: const Text('Buka Sheet'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Buka Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('Pilih Template Addendum'), findsOneWidget);
        expect(find.text('Perpanjangan Waktu Kontrak'), findsOneWidget);
        expect(find.text('Perubahan Nilai Kontrak'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));

        // Tap the first template
        await tester.tap(find.text('Perpanjangan Waktu Kontrak'));
        await tester.pumpAndSettle();

        expect(selectedTemplate, isNotNull);
        expect(selectedTemplate!.id, 'tmpl-1');
        expect(selectedTemplate!.title, 'Perpanjangan Waktu Kontrak');
      },
    );

    testWidgets('close icon button dismisses sheet returning null', (
      tester,
    ) async {
      const templates = [
        AddendumTemplate(id: 'tmpl-1', title: 'Template Default'),
      ];
      mockRepository.getActiveTemplatesFn = () async => const Ok(templates);

      AddendumTemplate? selectedTemplate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    selectedTemplate = await AddendumTemplatePickerSheet.show(
                      context,
                      controller: controller,
                    );
                  },
                  child: const Text('Buka Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Template Addendum'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(selectedTemplate, isNull);
    });

    testWidgets('resolves controller from getIt when controller is null', (
      tester,
    ) async {
      const templates = [
        AddendumTemplate(id: 'tmpl-getit', title: 'Template dari getIt'),
      ];
      mockRepository.getActiveTemplatesFn = () async => const Ok(templates);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AddendumTemplatePickerSheet())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Template dari getIt'), findsOneWidget);
      expect(mockRepository.getActiveTemplatesCalls, 1);
    });

    testWidgets(
      'does not dispose external controller when sheet widget is unmounted',
      (tester) async {
        mockRepository.getActiveTemplatesFn = () async => const Ok([]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AddendumTemplatePickerSheet(controller: controller),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Unmount the widget by pumping another widget
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
        );
        await tester.pumpAndSettle();

        // External controller should not be disposed, can still load templates
        expect(() => controller.loadActiveTemplates(), returnsNormally);
      },
    );
  });
}
