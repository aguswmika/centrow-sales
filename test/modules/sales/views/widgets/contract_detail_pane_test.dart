import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';
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

  testWidgets(
    'ContractDetailPane renders TANGGAL INVOICE PERTAMA when firstInvoiceDate is present',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const contractWithInvoiceDate = Contract(
        id: 'c-3',
        code: 'CTR-2026-0003',
        customerId: 'cust-3',
        customerName: 'PT Sukses Selalu',
        serviceId: 'srv-1',
        serviceName: 'General Pest Control',
        categoryId: 'cat-1',
        categoryName: 'Commercial',
        status: ContractStatus.draft,
        startDate: '2026-01-01',
        endDate: '2026-12-31',
        firstInvoiceDate: '2026-02-01',
        contractValue: 10000000.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContractDetailPane(contract: contractWithInvoiceDate),
          ),
        ),
      );

      expect(find.text('TANGGAL INVOICE PERTAMA'), findsOneWidget);
      expect(find.text('2026-02-01'), findsOneWidget);
    },
  );

  testWidgets(
    'ContractDetailPane omits TANGGAL INVOICE PERTAMA when firstInvoiceDate is null or empty',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContractDetailPane(contract: sampleDraftContract),
          ),
        ),
      );

      expect(find.text('TANGGAL INVOICE PERTAMA'), findsNothing);
    },
  );

  testWidgets(
    'ContractDetailPane renders monthly schedule cycle visit frequency label and unit',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const contract = Contract(
        id: 'c-monthly',
        code: 'CTR-2026-0004',
        customerId: 'cust-1',
        serviceId: 'srv-1',
        categoryId: 'cat-1',
        status: ContractStatus.active,
        startDate: '2026-01-01',
        totalVisits: 12,
        scheduleCycle: ContractScheduleCycle.monthly,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ContractDetailPane(contract: contract)),
        ),
      );

      expect(find.text('FREK. KUNJUNGAN (BULANAN)'), findsOneWidget);
      expect(find.text('12 x / bulan'), findsOneWidget);
    },
  );

  testWidgets(
    'ContractDetailPane renders yearly schedule cycle visit frequency label and unit',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const contract = Contract(
        id: 'c-yearly',
        code: 'CTR-2026-0005',
        customerId: 'cust-1',
        serviceId: 'srv-1',
        categoryId: 'cat-1',
        status: ContractStatus.active,
        startDate: '2026-01-01',
        totalVisits: 12,
        scheduleCycle: ContractScheduleCycle.yearly,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ContractDetailPane(contract: contract)),
        ),
      );

      expect(find.text('FREK. KUNJUNGAN (TAHUNAN)'), findsOneWidget);
      expect(find.text('12 x / tahun'), findsOneWidget);
    },
  );

  testWidgets(
    'ContractDetailPane renders fallback TOTAL KUNJUNGAN when scheduleCycle is null',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const contract = Contract(
        id: 'c-fallback',
        code: 'CTR-2026-0006',
        customerId: 'cust-1',
        serviceId: 'srv-1',
        categoryId: 'cat-1',
        status: ContractStatus.active,
        startDate: '2026-01-01',
        totalVisits: 12,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ContractDetailPane(contract: contract)),
        ),
      );

      expect(find.text('TOTAL KUNJUNGAN'), findsOneWidget);
      expect(find.text('12x'), findsOneWidget);
    },
  );

  testWidgets(
    'ContractDetailPane renders Buat Addendum button and triggers callback when active',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool addAddendumCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContractDetailPane(
              contract: sampleActiveContract,
              onAddAddendum: () => addAddendumCalled = true,
            ),
          ),
        ),
      );

      // Verify "Buat Addendum" buttons exist
      expect(find.text('Buat Addendum'), findsNWidgets(2));
      expect(find.text('Riwayat Addendum'), findsOneWidget);

      await tester.tap(find.text('Buat Addendum').first);
      await tester.pumpAndSettle();
      expect(addAddendumCalled, isTrue);
    },
  );

  testWidgets(
    'ContractDetailPane displays past addendums in Riwayat Addendum section',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const addendum = ContractAddendum(
        id: 'add-1',
        contractId: 'c-2',
        visitDelta: 3,
        oldTotalVisits: 12,
        newTotalVisits: 15,
        oldContractValue: 15000000.0,
        newContractValue: 18000000.0,
        reason: 'Penambahan frekuensi',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContractDetailPane(
              contract: sampleActiveContract,
              addendumsState: UiSuccess([addendum]),
            ),
          ),
        ),
      );

      expect(find.text('Riwayat Addendum'), findsOneWidget);
      expect(find.text('+3 Kunjungan'), findsOneWidget);
      expect(find.text('12x  ➔  15x'), findsOneWidget);
      expect(find.text('Penambahan frekuensi'), findsOneWidget);
    },
  );
}
