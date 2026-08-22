import 'package:centrow_sales/modules/sales/controllers/proposal_controller.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';
import 'package:centrow_sales/modules/sales/views/pages/proposal_page.dart';
import 'package:centrow_sales/modules/sales/views/widgets/proposal_detail_pane.dart';
import 'package:centrow_sales/modules/sales/views/widgets/proposal_master_list.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProposalRepo implements ProposalRepository {
  final List<Proposal> proposals;
  final bool shouldFail;

  _FakeProposalRepo({this.proposals = const [], this.shouldFail = false});

  @override
  Future<Result<List<Proposal>>> getProposals({
    String? query,
    String? status,
  }) async {
    if (shouldFail) return const Err(ServerFailure('Gagal memuat proposal'));
    return Ok(proposals);
  }

  @override
  Future<Result<Proposal>> getProposalById(String id) async {
    if (shouldFail) return const Err(ServerFailure('Gagal memuat detail'));
    final target = proposals.firstWhere((p) => p.id == id || p.code == id);
    return Ok(target);
  }

  @override
  Future<Result<Proposal>> createProposal(dynamic input) async {
    return const Err(ServerFailure('Not implemented'));
  }
}

void main() {
  const sampleProposals = [
    Proposal(
      id: 'p1',
      code: 'PRO-2026-0042',
      clientName: 'Villa Sari Dewi',
      initials: 'VS',
      serviceName: 'Termite Protection',
      status: ProposalStatus.dikirim,
      date: '12 Agt 2026',
      validUntil: '12 Sep 2026',
      location: 'Villa Utama Seminyak',
      total: 8158500.0,
      shortAmount: 'Rp 8,15jt',
      cogs: 5480000.0,
      materialCost: 3710000.0,
      laborCost: 1650000.0,
      fuelCost: 120000.0,
      markup: 1370000.0,
      markupPercent: 25.0,
      servicePrice: 6850000.0,
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
      ],
    ),
    Proposal(
      id: 'p2',
      code: 'PRO-2026-0041',
      clientName: 'Hotel Surya Kuta',
      initials: 'SK',
      serviceName: 'Pest Control Full',
      status: ProposalStatus.negosiasi,
      date: '10 Agt 2026',
      validUntil: '10 Sep 2026',
      location: 'Resort & Resto Kuta',
      total: 12500000.0,
      shortAmount: 'Rp 12,5jt',
    ),
  ];

  testWidgets('ProposalPage renders split layout on tablet viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeProposalRepo(proposals: sampleProposals);
    final controller = ProposalController(repo);

    await tester.pumpWidget(
      MaterialApp(home: ProposalPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProposalMasterList), findsOneWidget);
    expect(find.byType(ProposalDetailPane), findsOneWidget);
    expect(find.text('Villa Sari Dewi'), findsWidgets);
    expect(find.text('PRO-2026-0042 · Villa Sari Dewi'), findsOneWidget);

    // Tap on second proposal
    await tester.tap(find.text('Hotel Surya Kuta'));
    await tester.pumpAndSettle();

    expect(find.text('PRO-2026-0041 · Hotel Surya Kuta'), findsOneWidget);

    // Tap Export PDF to trigger toast
    await tester.tap(find.text('Ekspor PDF'));
    await tester.pump();
    expect(find.text('Dokumen proposal PDF siap diunduh.'), findsOneWidget);
  });

  testWidgets('ProposalPage renders only master list on mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeProposalRepo(proposals: sampleProposals);
    final controller = ProposalController(repo);

    await tester.pumpWidget(
      MaterialApp(home: ProposalPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProposalMasterList), findsOneWidget);
    expect(find.byType(ProposalDetailPane), findsNothing);
  });

  testWidgets('ProposalPage displays ErrorView on failure and retries', (
    tester,
  ) async {
    final repo = _FakeProposalRepo(shouldFail: true);
    final controller = ProposalController(repo);

    await tester.pumpWidget(
      MaterialApp(home: ProposalPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat proposal'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
