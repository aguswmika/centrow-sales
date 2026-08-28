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
    status: ProposalStatus.dikirim,
    date: '12 Agt 2026',
    validUntil: '12 Sep 2026',
    location: 'Villa Utama Seminyak',
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

  testWidgets(
    'ProposalDetailPane renders header, metadata bar, pricing list, and sidebar',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int currentTab = 0;
      bool exportPdfClicked = false;
      bool calculatorClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ProposalDetailPane(
                  proposal: sampleProposal,
                  activeTab: currentTab,
                  onTabChanged: (tab) => setState(() => currentTab = tab),
                  onExportPdf: () => exportPdfClicked = true,
                  onOpenCalculator: () => calculatorClicked = true,
                );
              },
            ),
          ),
        ),
      );

      // Verify Header
      expect(find.text('PRO-2026-0042 · Villa Sari Dewi'), findsOneWidget);
      expect(find.text('Termite Protection Plan'), findsOneWidget);
      expect(find.text('Versi 1'), findsOneWidget);
      expect(find.text('Status: Dikirim'), findsOneWidget);
      expect(find.text('Ekspor PDF'), findsOneWidget);
      expect(find.text('Buka di Kalkulator'), findsOneWidget);

      // Verify Metadata Bar
      expect(find.text('TANGGAL PROPOSAL'), findsOneWidget);
      expect(find.text('12 Agt 2026'), findsOneWidget);
      expect(find.text('MASA BERLAKU'), findsOneWidget);
      expect(find.text('12 Sep 2026'), findsOneWidget);
      expect(find.text('LOKASI PROPERTI'), findsOneWidget);
      expect(find.text('Villa Utama Seminyak'), findsOneWidget);

      // Verify Pricing Breakdown Tab 0 (Persiapan)
      expect(find.text('Ficam W (25kg)'), findsOneWidget);
      expect(find.text('Rp 760.000'), findsOneWidget);

      // Verify Financial Summary Sidebar
      expect(find.text('TOTAL NILAI PROPOSAL'), findsWidgets);
      expect(find.text('Rp 8.158.500'), findsWidgets);
      expect(find.text('Rincian Finansial Proposal'), findsOneWidget);
      expect(find.text('Total Biaya Modal (COGS)'), findsOneWidget);
      expect(find.text('Rp 5.480.000'), findsOneWidget);
      expect(find.text('Metrik Profitabilitas'), findsOneWidget);
      expect(find.text('20.0%'), findsOneWidget);
      expect(find.text('Rp 1,37jt'), findsOneWidget);

      // Test tab change to Teknisi
      await tester.tap(find.text('2. Tenaga Kerja'));
      await tester.pumpAndSettle();
      expect(find.text('Teknisi Senior (Lead Operator)'), findsOneWidget);
      expect(find.text('Rp 990.000'), findsOneWidget);

      // Test Action Buttons
      await tester.tap(find.text('Ekspor PDF'));
      expect(exportPdfClicked, isTrue);

      await tester.tap(find.text('Buka di Kalkulator'));
      expect(calculatorClicked, isTrue);
    },
  );

  testWidgets(
    'ProposalDetailPane shows empty placeholder when proposal is null',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProposalDetailPane(
              proposal: null,
              activeTab: 0,
              onTabChanged: _noop,
            ),
          ),
        ),
      );

      expect(
        find.text('Pilih proposal dari daftar di sebelah kiri'),
        findsOneWidget,
      );
    },
  );
}

void _noop(int _) {}
