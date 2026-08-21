import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_detail_pane.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_info_tab.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

void main() {
  group('CustomerDetailPane', () {
    const testCustomer = Customer(
      id: 'c1',
      code: 'CUST-001',
      name: 'Villa Bali Resort',
      initials: 'VB',
      segment: 'Hospitality',
      status: 'active',
      activeProposalsCount: 3,
      activeContractsCount: 5,
      createdAt: '2025-06-15T10:30:00Z',
      updatedAt: '2025-06-20T14:45:00Z',
    );

    testWidgets('renders active proposals and active contracts count in header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomerDetailPane(
              customer: testCustomer,
              detailState: const UiSuccess(testCustomer),
              activeTab: 0,
              onTabChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('• 3 Proposal Aktif'), findsOneWidget);
      expect(find.text('• 5 Kontrak Aktif'), findsOneWidget);
    });
  });

  group('CustomerInfoTab', () {
    testWidgets('renders Tanggal Dibuat and Terakhir Diperbarui formatted cleanly', (tester) async {
      const customer = Customer(
        id: 'c1',
        code: 'CUST-001',
        name: 'Villa Bali Resort',
        initials: 'VB',
        segment: 'Hospitality',
        status: 'active',
        createdAt: '2025-06-15T10:30:00',
        updatedAt: '2025-12-01T08:05:00',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CustomerInfoTab(customer: customer),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Tanggal Dibuat'), findsOneWidget);
      expect(find.text('15 Jun 2025, 10:30 WIB'), findsOneWidget);

      expect(find.text('Terakhir Diperbarui'), findsOneWidget);
      expect(find.text('1 Des 2025, 08:05 WIB'), findsOneWidget);
    });

    testWidgets('handles empty and fallback dates gracefully', (tester) async {
      const customer = Customer(
        id: 'c2',
        code: 'CUST-002',
        name: 'Test Customer',
        initials: 'TC',
        segment: 'Retail',
        status: 'active',
        createdAt: '',
        updatedAt: 'not-a-valid-date',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CustomerInfoTab(customer: customer),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Tanggal Dibuat'), findsOneWidget);
      expect(find.text('Terakhir Diperbarui'), findsOneWidget);
      expect(find.text('-'), findsWidgets);
      expect(find.text('not-a-valid-date'), findsOneWidget);
    });
  });
}
