import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/sales_dashboard_controller.dart';
import 'package:centrow_sales/modules/sales/repositories/sales_dashboard_repository.dart';
import 'package:centrow_sales/modules/sales/views/pages/dashboard_page.dart';

void main() {
  group('DashboardPage', () {
    late SalesDashboardRepository repository;
    late SalesDashboardController controller;

    setUp(() {
      repository = SalesDashboardRepositoryImpl(null, true);
      controller = SalesDashboardController(repository);
    });

    Widget createTestWidget() {
      return MaterialApp(home: DashboardPage(controller: controller));
    }

    testWidgets('renders summary data in UiSuccess', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Pipeline Penjualan'), findsOneWidget);
      expect(find.text('Proposal Terbaru'), findsOneWidget);
      expect(find.text('Kontrak Jatuh Tempo'), findsOneWidget);
      expect(find.text('Pelanggan'), findsWidgets);
    });
  });
}
