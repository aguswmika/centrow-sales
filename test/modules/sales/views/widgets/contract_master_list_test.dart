import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/views/widgets/contract_master_list.dart';
import 'package:centrow_sales/shared/widgets/app_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleContracts = [
    Contract(
      id: 'c1',
      code: 'CTR-2026-0001',
      customerId: 'cust1',
      customerName: 'Villa Sari Dewi',
      serviceId: 'srv1',
      serviceName: 'Termite Protection',
      categoryId: 'cat1',
      categoryName: 'Pest Control',
      status: ContractStatus.draft,
      startDate: '2026-09-01',
      contractValue: 5000000.0,
      paymentType: ContractPaymentType.full,
    ),
    Contract(
      id: 'c2',
      code: 'CTR-2026-0002',
      customerId: 'cust2',
      customerName: 'Hotel Surya Kuta',
      serviceId: 'srv2',
      serviceName: 'General Pest',
      categoryId: 'cat1',
      categoryName: 'Pest Control',
      status: ContractStatus.active,
      startDate: '2026-09-02',
      contractValue: 12000000.0,
      paymentType: ContractPaymentType.monthly,
    ),
  ];

  testWidgets(
    'ContractMasterList renders header, search, segmented control, and items',
    (tester) async {
      String? selectedId;
      int? selectedStatus;
      String? searchQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: ContractMasterList(
                contracts: sampleContracts,
                selectedContractId: 'c1',
                selectedStatus: null,
                searchQuery: '',
                onSelectContract: (id) => selectedId = id,
                onStatusChanged: (status) => selectedStatus = status,
                onSearchChanged: (q) => searchQuery = q,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Daftar Kontrak'), findsOneWidget);
      expect(find.text('2 kontrak'), findsOneWidget);
      expect(find.text('Villa Sari Dewi'), findsOneWidget);
      expect(find.text('Hotel Surya Kuta'), findsOneWidget);
      expect(find.text('CTR-2026-0001'), findsOneWidget);
      expect(find.text('CTR-2026-0002'), findsOneWidget);

      // Verify segmented control is present
      expect(find.byType(AppSegmentedControl<int?>), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Draf'), findsWidgets);
      expect(find.text('Aktif'), findsWidgets);
      expect(find.text('Ditangguhkan'), findsOneWidget);

      // Tap an item
      await tester.tap(find.text('Hotel Surya Kuta'));
      expect(selectedId, 'c2');

      // Tap status segment
      await tester.tap(
        find.descendant(
          of: find.byType(AppSegmentedControl<int?>),
          matching: find.text('Aktif'),
        ),
      );
      expect(selectedStatus, 2);

      // Tap search input
      await tester.enterText(find.byType(TextField), 'Surya');
      expect(searchQuery, 'Surya');
    },
  );

  testWidgets(
    'ContractMasterList renders empty placeholder when contracts list is empty',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: ContractMasterList(
                contracts: const [],
                selectedContractId: '',
                selectedStatus: null,
                searchQuery: '',
                onSelectContract: (_) {},
                onStatusChanged: (_) {},
                onSearchChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Belum ada kontrak.'), findsOneWidget);
    },
  );
}
