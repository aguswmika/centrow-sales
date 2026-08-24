import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/views/widgets/proposal_master_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('ProposalMasterList renders header, search, chips, and items', (
    tester,
  ) async {
    String? selectedId;
    String? selectedStatus;
    String? searchQuery;
    bool createClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: ProposalMasterList(
              proposals: sampleProposals,
              selectedProposalId: 'p1',
              selectedStatus: 'all',
              searchQuery: '',
              onSelectProposal: (id) => selectedId = id,
              onSelectStatus: (status) => selectedStatus = status,
              onSearchChanged: (q) => searchQuery = q,
              onCreateProposal: () => createClicked = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Daftar Proposal'), findsOneWidget);
    expect(
      find.text('2 proposal aktif dalam pipeline penawaran'),
      findsOneWidget,
    );
    expect(find.text('Villa Sari Dewi'), findsOneWidget);
    expect(find.text('Hotel Surya Kuta'), findsOneWidget);
    expect(find.text('Dikirim'), findsWidgets);
    expect(find.text('Negosiasi'), findsOneWidget);
    expect(find.text('Rp 8,15jt'), findsOneWidget);
    expect(find.text('Rp 12,5jt'), findsOneWidget);

    // Test tap item
    await tester.tap(find.text('Hotel Surya Kuta'));
    expect(selectedId, 'p2');

    // Test tap segment
    await tester.tap(find.text('Draft'));
    expect(selectedStatus, 'Draft');

    // Test typing search
    await tester.enterText(find.byType(TextField), 'Villa');
    expect(searchQuery, 'Villa');

    // Test add/create button
    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(createClicked, isTrue);
  });

  testWidgets(
    'ProposalMasterList renders empty placeholder when proposals list is empty',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: ProposalMasterList(
                proposals: const [],
                selectedProposalId: '',
                selectedStatus: 'all',
                searchQuery: '',
                onSelectProposal: (_) {},
                onSelectStatus: (_) {},
                onSearchChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tidak ada proposal yang ditemukan'), findsOneWidget);
    },
  );
}
