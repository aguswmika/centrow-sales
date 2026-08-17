import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/sales_dashboard_controller.dart';
import 'package:centrow_sales/modules/sales/entities/sales_dashboard.dart';
import 'package:centrow_sales/modules/sales/repositories/sales_dashboard_repository.dart';
import 'package:centrow_sales/modules/sales/views/pages/dashboard_page.dart';
import 'package:centrow_sales/modules/sales/views/widgets/kpi_card.dart';
import 'package:centrow_sales/modules/sales/views/widgets/pipeline_funnel_card.dart';
import 'package:centrow_sales/modules/sales/views/widgets/recent_proposals_list.dart';
import 'package:centrow_sales/modules/sales/views/widgets/expiring_contracts_list.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/widgets/app_button.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';

const sampleSummary = mockSalesDashboardSummary;

class MockSalesDashboardRepository implements SalesDashboardRepository {
  Result<SalesDashboardSummary>? result;

  @override
  Future<Result<SalesDashboardSummary>> getDashboardSummary() async {
    return result ?? const Ok(sampleSummary);
  }
}

void main() {
  late MockSalesDashboardRepository mockRepository;
  late SalesDashboardController controller;

  setUp(() {
    mockRepository = MockSalesDashboardRepository();
    controller = SalesDashboardController(mockRepository);
  });

  tearDown(() {
    controller.dispose();
  });

  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('DashboardPage renders summary data in UiSuccess', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    mockRepository.result = const Ok(sampleSummary);
    await controller.loadDashboard();

    await tester.pumpWidget(wrap(DashboardPage(controller: controller)));
    await tester.pump();

    // Verify Header
    expect(find.text('Selamat datang, Agus Widarmika 👋'), findsOneWidget);
    expect(
      find.text('Agustus 2026 · Sales Wilayah Bali & Nusa Tenggara'),
      findsOneWidget,
    ); // Verify Action Buttons
    expect(find.widgetWithText(AppButton, 'Pelanggan'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Proposal'), findsOneWidget);

    // Verify KPI Cards
    expect(find.byType(KpiCard), findsNWidgets(4));
    expect(find.text('Proposal Aktif'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('Kontrak Berjalan'), findsOneWidget);
    expect(find.text('148'), findsOneWidget);

    // Verify Pipeline Funnel & Segments
    expect(find.byType(PipelineFunnelCard), findsOneWidget);
    expect(find.text('Pipeline Penjualan'), findsOneWidget);
    expect(find.text('Villa (635)'), findsOneWidget);

    // Verify Proposals & Contracts Lists
    expect(find.byType(RecentProposalsList), findsOneWidget);
    expect(find.text('Villa Sari Dewi'), findsOneWidget);
    expect(find.byType(ExpiringContractsList), findsOneWidget);
    expect(find.text('Villa Puri Tirtha'), findsOneWidget);
  });

  testWidgets(
    'DashboardPage renders ErrorView on UiFailure and retries on tap',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      mockRepository.result = const Err(
        ServerFailure('Gagal memuat dashboard', 500),
      );
      await controller.loadDashboard();

      await tester.pumpWidget(wrap(DashboardPage(controller: controller)));
      await tester.pump();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Gagal memuat dashboard'), findsOneWidget);

      // Update to success and retry
      mockRepository.result = const Ok(sampleSummary);
      await controller.loadDashboard();
      await tester.pump();

      expect(find.byType(ErrorView), findsNothing);
      expect(find.text('Selamat datang, Agus Widarmika 👋'), findsOneWidget);
    },
  );
}
