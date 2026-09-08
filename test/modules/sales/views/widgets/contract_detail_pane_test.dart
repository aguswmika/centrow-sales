import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/views/widgets/contract_detail_pane.dart';

void main() {
  const sampleDraftContract = Contract(
    id: 'c-1',
    code: 'CTR-2026-0001',
    customerId: 'cust-1',
    customerName: 'PT Maju Terus',
    serviceId: 'srv-1',
    serviceName: 'General Pest Control',
    categoryId: 'cat-1',
    categoryName: 'Commercial',
    status: ContractStatus.draft,
    startDate: '2026-01-01',
    endDate: '2026-12-31',
    contractValue: 12000000.0,
  );

  const sampleActiveContract = Contract(
    id: 'c-2',
    code: 'CTR-2026-0002',
    customerId: 'cust-2',
    customerName: 'CV Berkah Bersama',
    serviceId: 'srv-1',
    serviceName: 'General Pest Control',
    categoryId: 'cat-1',
    categoryName: 'Commercial',
    status: ContractStatus.active,
    startDate: '2026-01-01',
    endDate: '2026-12-31',
    contractValue: 15000000.0,
  );

  testWidgets(
    'ContractDetailPane renders draft header, buttons, and triggers callbacks',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool openDocCalled = false;
      bool activateCalled = false;
      bool pdfCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContractDetailPane(
              contract: sampleDraftContract,
              onOpenDocument: () => openDocCalled = true,
              onActivate: () => activateCalled = true,
              onEdit: () {},
              onExportPdf: () => pdfCalled = true,
              onCancel: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify Header Identity
      expect(find.text('CTR-2026-0001 · PT Maju Terus'), findsOneWidget);
      expect(find.text('General Pest Control'), findsNWidgets(2));
      expect(find.text('Commercial'), findsNWidgets(2));
      expect(find.text('Status: Draf'), findsOneWidget);

      // Verify Dokumen button (editable for draft)
      expect(find.text('Dokumen'), findsOneWidget);
      expect(find.byIcon(Icons.edit_document), findsOneWidget);

      await tester.tap(find.text('Dokumen'));
      await tester.pumpAndSettle();
      expect(openDocCalled, isTrue);

      // Verify Aktifkan button (draft can activate)
      expect(find.text('Aktifkan'), findsOneWidget);
      await tester.tap(find.text('Aktifkan'));
      await tester.pumpAndSettle();
      expect(activateCalled, isTrue);

      // Verify PopupMenu 'Aksi'
      expect(find.text('Aksi'), findsOneWidget);
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();

      expect(find.text('Ubah Kontrak'), findsOneWidget);
      expect(find.text('Unduh PDF'), findsOneWidget);
      expect(find.text('Batalkan Kontrak'), findsOneWidget);
      expect(find.text('Hapus Draf'), findsOneWidget);

      await tester.tap(find.text('Unduh PDF'));
      await tester.pumpAndSettle();
      expect(pdfCalled, isTrue);
    },
  );

  testWidgets(
    'ContractDetailPane renders active status without Aktifkan, and with description icon',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool suspendCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContractDetailPane(
              contract: sampleActiveContract,
              onExportPdf: () {},
              onSuspend: () => suspendCalled = true,
              onTerminate: () {},
            ),
          ),
        ),
      );

      // Active status cannot activate
      expect(find.text('Aktifkan'), findsNothing);

      // Dokumen button shows description_outlined
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.byIcon(Icons.edit_document), findsNothing);

      // Open Aksi menu
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();

      expect(find.text('Unduh PDF'), findsOneWidget);
      expect(find.text('Tangguhkan Kontrak'), findsOneWidget);
      expect(find.text('Terminasi Kontrak'), findsOneWidget);
      expect(find.text('Ubah Kontrak'), findsNothing);
      expect(find.text('Hapus Draf'), findsNothing);

      await tester.tap(find.text('Tangguhkan Kontrak'));
      await tester.pumpAndSettle();
      expect(suspendCalled, isTrue);
    },
  );
}
