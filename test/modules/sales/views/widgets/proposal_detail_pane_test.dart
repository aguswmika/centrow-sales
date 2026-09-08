import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/views/widgets/proposal_detail_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleProposal = Proposal(
    id: 'p1',
    code: 'PRO-2026-0042',
    clientName: 'Villa Sari Dewi',
    serviceName: 'Termite Protection Plan',
    status: ProposalStatus.sent,
    date: '12 Agt 2026',
    validUntil: '12 Sep 2026',
    location: 'Villa Utama Seminyak',
    hasPricing: true,
    version: '1',
    total: 8158500.0,
    shortAmount: 'Rp 8,15jt',
    cogs: 5480000.0,
    materialCost: 3710000.0,
    workerCost: 1650000.0,
    fuelCost: 120000.0,
    markup: 1370000.0,
    markupPercent: 25.0,
    servicePrice: 6850000.0,
    addon: 500000.0,
    subtotal: 7350000.0,
    tax: 808500.0,
    marginPct: 20.0,
    marginAmt: 1370000.0,
    shortMarginAmt: 'Rp 1,37jt',
    ppv: 1225000.0,
    ppm: 612500.0,
    items: [
      ProposalItem(
        id: 'item-1',
        title: 'Ficam W (25kg)',
        description: '2 kg · Biaya: Rp 380.000 / kg',
        category: ProposalItemCategory.persiapan,
        price: 760000.0,
      ),
      ProposalItem(
        id: 'item-2',
        title: 'Teknisi Senior (Lead Operator)',
        description: '6 Kunjungan · Tarif: Rp 45.000 / jam',
        category: ProposalItemCategory.teknisi,
        price: 990000.0,
      ),
      ProposalItem(
        id: 'item-3',
        title: 'Biaya Perjalanan Badung',
        description: '6 Kunjungan × Rp 20.000',
        category: ProposalItemCategory.transport,
        price: 120000.0,
      ),
    ],
  );

  testWidgets('ProposalDetailPane renders header, general info, and actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool exportPdfClicked = false;
    bool calculatorClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProposalDetailPane(
            proposal: sampleProposal,
            onExportPdf: () => exportPdfClicked = true,
            onOpenCalculator: () => calculatorClicked = true,
          ),
        ),
      ),
    );

    // Verify Header
    expect(find.text('PRO-2026-0042 · Villa Sari Dewi'), findsOneWidget);
    expect(find.text('Termite Protection Plan'), findsOneWidget);
    expect(find.text('Versi 1'), findsOneWidget);
    expect(find.text('Status: Terkirim'), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Dokumen'), findsOneWidget);
    expect(find.text('Aksi'), findsOneWidget);
    expect(find.text('Ekspor PDF'), findsNothing);

    // For sent proposal, Dokumen button icon is Icons.description_outlined
    expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    expect(find.byIcon(Icons.edit_document), findsNothing);

    // Verify General Info Tab
    expect(find.text('TANGGAL PROPOSAL'), findsOneWidget);
    expect(find.text('12 Agt 2026'), findsOneWidget);
    expect(find.text('MASA BERLAKU'), findsOneWidget);
    expect(find.text('12 Sep 2026'), findsOneWidget);
    expect(find.text('LOKASI PROPERTI'), findsOneWidget);
    expect(find.text('Villa Utama Seminyak'), findsOneWidget);
    expect(find.text('Catatan Proposal'), findsOneWidget);

    // Test Action Buttons
    await tester.tap(find.text('Aksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ekspor PDF'));
    await tester.pumpAndSettle();
    expect(exportPdfClicked, isTrue);

    await tester.tap(find.text('Pricing'));
    // With view-only pricing enabled for non-drafts with hasPricing == true, this button is now enabled
    expect(calculatorClicked, isTrue);
  });

  testWidgets(
    'ProposalDetailPane renders draft action buttons and fires callbacks',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool sendClicked = false;
      bool editClicked = false;
      bool exportPdfClicked = false;
      bool cancelClicked = false;
      bool calculatorClicked = false;

      final draftProposal = sampleProposal.copyWith(
        status: ProposalStatus.draft,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalDetailPane(
              proposal: draftProposal,
              onSendProposal: () => sendClicked = true,
              onEditProposal: () => editClicked = true,
              onExportPdf: () => exportPdfClicked = true,
              onCancelProposal: () => cancelClicked = true,
              onOpenCalculator: () => calculatorClicked = true,
            ),
          ),
        ),
      );

      // Verify the 3 buttons on the header
      expect(find.text('Pricing'), findsOneWidget);
      expect(find.text('Dokumen'), findsOneWidget);
      expect(find.text('Aksi'), findsOneWidget);

      // In draft status, Dokumen button shows Icons.edit_document
      expect(find.byIcon(Icons.edit_document), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsNothing);

      // In draft status, Pricing button is enabled
      await tester.tap(find.text('Pricing'));
      expect(calculatorClicked, isTrue);

      // Actions should not be visible directly
      expect(find.text('Kirim Proposal'), findsNothing);
      expect(find.text('Ubah Data'), findsNothing);
      expect(find.text('Ekspor PDF'), findsNothing);
      expect(find.text('Batalkan Proposal'), findsNothing);
      expect(find.text('Terima Proposal'), findsNothing);
      expect(find.text('Tolak Proposal'), findsNothing);
      expect(find.text('Revisi Proposal'), findsNothing);

      // Open popup menu and test Kirim Proposal
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();

      expect(find.text('Kirim Proposal'), findsOneWidget);
      expect(find.text('Ekspor PDF'), findsOneWidget);
      expect(find.text('Ubah Data'), findsOneWidget);
      expect(find.text('Batalkan Proposal'), findsOneWidget);

      await tester.tap(find.text('Kirim Proposal'));
      await tester.pumpAndSettle();
      expect(sendClicked, isTrue);

      // Test Ubah Data
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ubah Data'));
      await tester.pumpAndSettle();
      expect(editClicked, isTrue);

      // Test Ekspor PDF
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ekspor PDF'));
      await tester.pumpAndSettle();
      expect(exportPdfClicked, isTrue);

      // Test Batalkan Proposal
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batalkan Proposal'));
      await tester.pumpAndSettle();
      expect(cancelClicked, isTrue);
    },
  );

  testWidgets(
    'ProposalDetailPane renders sent action buttons and fires callbacks',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool acceptClicked = false;
      bool rejectClicked = false;
      bool reviseClicked = false;
      bool exportPdfClicked = false;
      bool expireClicked = false;
      bool cancelClicked = false;
      bool calculatorClicked = false;

      final sentProposal = sampleProposal.copyWith(status: ProposalStatus.sent);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalDetailPane(
              proposal: sentProposal,
              onAcceptProposal: () => acceptClicked = true,
              onRejectProposal: () => rejectClicked = true,
              onReviseProposal: () => reviseClicked = true,
              onExportPdf: () => exportPdfClicked = true,
              onExpireProposal: () => expireClicked = true,
              onCancelProposal: () => cancelClicked = true,
              onOpenCalculator: () => calculatorClicked = true,
            ),
          ),
        ),
      );

      // Verify the 3 buttons on the header
      expect(find.text('Pricing'), findsOneWidget);
      expect(find.text('Dokumen'), findsOneWidget);
      expect(find.text('Aksi'), findsOneWidget);

      // In sent status, Dokumen button shows Icons.description_outlined (read-only)
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(find.byIcon(Icons.edit_document), findsNothing);

      // In sent status with hasPricing == true, Pricing button is enabled (view-only)
      await tester.tap(find.text('Pricing'));
      expect(calculatorClicked, isTrue);

      // Actions should not be visible directly
      expect(find.text('Terima Proposal'), findsNothing);
      expect(find.text('Tolak Proposal'), findsNothing);
      expect(find.text('Revisi Proposal'), findsNothing);
      expect(find.text('Ekspor PDF'), findsNothing);
      expect(find.text('Tandai Kedaluwarsa'), findsNothing);
      expect(find.text('Batalkan Proposal'), findsNothing);
      expect(find.text('Kirim Proposal'), findsNothing);
      expect(find.text('Ubah Data'), findsNothing);

      // Open popup menu and test Terima Proposal
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();

      expect(find.text('Terima Proposal'), findsOneWidget);
      expect(find.text('Tolak Proposal'), findsOneWidget);
      expect(find.text('Revisi Proposal'), findsOneWidget);
      expect(find.text('Ekspor PDF'), findsOneWidget);
      expect(find.text('Tandai Kedaluwarsa'), findsOneWidget);
      expect(find.text('Batalkan Proposal'), findsOneWidget);

      await tester.tap(find.text('Terima Proposal'));
      await tester.pumpAndSettle();
      expect(acceptClicked, isTrue);

      // Test Tolak Proposal
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tolak Proposal'));
      await tester.pumpAndSettle();
      expect(rejectClicked, isTrue);

      // Test Revisi Proposal
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Revisi Proposal'));
      await tester.pumpAndSettle();
      expect(reviseClicked, isTrue);

      // Test Ekspor PDF
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ekspor PDF'));
      await tester.pumpAndSettle();
      expect(exportPdfClicked, isTrue);

      // Test Tandai Kedaluwarsa
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tandai Kedaluwarsa'));
      await tester.pumpAndSettle();
      expect(expireClicked, isTrue);

      // Test Batalkan Proposal
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batalkan Proposal'));
      await tester.pumpAndSettle();
      expect(cancelClicked, isTrue);
    },
  );

  testWidgets('ProposalDetailPane displays rejection reason when rejected', (
    tester,
  ) async {
    final rejectedProposal = sampleProposal.copyWith(
      status: ProposalStatus.rejected,
      rejectionReason: 'Anggaran klien tidak mencukupi',
      decidedAt: '15 Agt 2026',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProposalDetailPane(proposal: rejectedProposal)),
      ),
    );

    expect(find.text('ALASAN PENOLAKAN'), findsOneWidget);
    expect(find.text('Anggaran klien tidak mencukupi'), findsOneWidget);
    expect(find.text('DIPUTUSKAN PADA'), findsOneWidget);
    expect(find.text('15 Agt 2026'), findsOneWidget);
  });

  testWidgets(
    'ProposalDetailPane shows empty placeholder when proposal is null',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProposalDetailPane(proposal: null)),
        ),
      );

      expect(
        find.text('Pilih proposal dari daftar di sebelah kiri'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'ProposalDetailPane shows loading indicator on Aksi button when isActionLoading is true',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProposalDetailPane(
              proposal: sampleProposal,
              isActionLoading: true,
            ),
          ),
        ),
      );

      expect(find.text('Aksi'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'ProposalDetailPane shows loading indicator on Aksi button when isExportingPdf is true',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProposalDetailPane(
              proposal: sampleProposal,
              isExportingPdf: true,
            ),
          ),
        ),
      );

      expect(find.text('Aksi'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('ProposalDetailPane triggers onOpenDocument callback', (
    tester,
  ) async {
    bool docClicked = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProposalDetailPane(
            proposal: sampleProposal,
            onOpenDocument: () => docClicked = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Dokumen'));
    expect(docClicked, isTrue);
  });

  testWidgets(
    'ProposalDetailPane renders Buat Kontrak button for accepted proposal and triggers callback',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool contractClicked = false;
      final acceptedProposal = sampleProposal.copyWith(
        status: ProposalStatus.accepted,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalDetailPane(
              proposal: acceptedProposal,
              onCreateContract: () => contractClicked = true,
            ),
          ),
        ),
      );

      // "Buat Kontrak" button is visible in header actions
      expect(find.text('Buat Kontrak'), findsOneWidget);

      // Tap "Buat Kontrak" button
      await tester.tap(find.text('Buat Kontrak'));
      expect(contractClicked, isTrue);
    },
  );

  testWidgets(
    'ProposalDetailPane disables Pricing button for non-draft proposal with hasPricing: false',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool calculatorClicked = false;
      final proposal = sampleProposal.copyWith(
        status: ProposalStatus.sent,
        hasPricing: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalDetailPane(
              proposal: proposal,
              onOpenCalculator: () => calculatorClicked = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pricing'));
      expect(calculatorClicked, isFalse);
    },
  );

  testWidgets(
    'ProposalDetailPane enables Pricing button for draft proposal with hasPricing: false',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool calculatorClicked = false;
      final proposal = sampleProposal.copyWith(
        status: ProposalStatus.draft,
        hasPricing: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProposalDetailPane(
              proposal: proposal,
              onOpenCalculator: () => calculatorClicked = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pricing'));
      expect(calculatorClicked, isTrue);
    },
  );
}
