import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';
import 'package:centrow_sales/modules/sales/views/widgets/contract_addendum_history_list.dart';

void main() {
  const sampleAddendum = ContractAddendum(
    id: 'add-1',
    contractId: 'ctr-1',
    visitDelta: 2,
    oldTotalVisits: 10,
    newTotalVisits: 12,
    oldContractValue: 10000000.0,
    newContractValue: 12000000.0,
    reason: 'Permintaan PIC untuk tambah area',
    createdBy: 'Budi Sales',
    createdAt: '2026-03-01 10:00:00',
  );

  group('ContractAddendumHistoryList', () {
    testWidgets('renders empty state when addendums list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ContractAddendumHistoryList(state: UiSuccess([])),
          ),
        ),
      );

      expect(find.text('Belum Ada Addendum'), findsOneWidget);
      expect(
        find.text(
          'Riwayat addendum kontrak akan tampil di sini setelah dibuat.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders addendum card details correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ContractAddendumHistoryList(
                state: UiSuccess([sampleAddendum]),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Addendum #1'), findsOneWidget);
      expect(find.text('+2 Kunjungan'), findsOneWidget);
      expect(find.text('10x  ➔  12x'), findsOneWidget);
      expect(find.text('Rp 10.000.000  ➔  Rp 12.000.000'), findsOneWidget);
      expect(find.text('Permintaan PIC untuk tambah area'), findsOneWidget);
      expect(find.text('Budi Sales'), findsOneWidget);
      expect(find.text('2026-03-01 10:00:00'), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ContractAddendumHistoryList(state: UiLoading())),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state and retries on button tap', (
      tester,
    ) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContractAddendumHistoryList(
              state: const UiFailure(ServerFailure('Koneksi terputus', 500)),
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Koneksi terputus'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('renders pricingId badge and document action buttons', (
      tester,
    ) async {
      const addendumWithPricing = ContractAddendum(
        id: 'add-2',
        contractId: 'ctr-1',
        pricingId: 'pricing-12345678',
        visitDelta: 1,
        oldTotalVisits: 10,
        newTotalVisits: 11,
        oldContractValue: 5000000.0,
        newContractValue: 5500000.0,
        reason: 'Penambahan kunjungan',
        createdBy: 'Sales Rep',
        createdAt: '2026-03-02 11:00:00',
      );

      ContractAddendum? openedAddendum;
      ContractAddendum? downloadedAddendum;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ContractAddendumHistoryList(
                state: const UiSuccess([addendumWithPricing]),
                onOpenDocument: (a) => openedAddendum = a,
                onDownloadPdf: (a) => downloadedAddendum = a,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pricing: pricing-'), findsOneWidget);
      expect(find.text('Dokumen Addendum'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);

      await tester.tap(find.text('Dokumen Addendum'));
      await tester.pump();
      expect(openedAddendum, equals(addendumWithPricing));

      await tester.tap(find.byIcon(Icons.picture_as_pdf_outlined));
      await tester.pump();
      expect(downloadedAddendum, equals(addendumWithPricing));
    });
  });
}
