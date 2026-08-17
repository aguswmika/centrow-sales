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
import 'package:centrow_sales/shared/widgets/error_view.dart';
import 'package:centrow_sales/shared/widgets/nav_rail_shell.dart';

const sampleSummary = SalesDashboardSummary(
  userName: 'Agus',
  branchName: 'Bali & Nusa Tenggara',
  kpis: [
    KpiMetric(
      label: 'Proposal Aktif',
      value: '24',
      subText: '↑ 3 bulan ini',
      isPositive: true,
      isWarning: false,
    ),
    KpiMetric(
      label: 'Kontrak Berjalan',
      value: '148',
      subText: '3 jatuh tempo',
      isWarning: true,
    ),
    KpiMetric(
      label: 'Nilai Pipeline',
      value: 'Rp 84,5jt',
      subText: '↑ 12% vs bulan lalu',
      isPositive: true,
      isWarning: false,
    ),
    KpiMetric(
      label: 'Margin Rata-rata',
      value: '31,2%',
      subText: '↓ 0.8% target 32,0%',
      isPositive: false,
      isWarning: false,
    ),
  ],
  pipelineStages: [
    PipelineStage(name: 'Draft', count: 6, percentage: 1.0, colorHex: 0xFF93C5FD),
    PipelineStage(name: 'Dikirim', count: 8, percentage: 0.75, colorHex: 0xFF60A5FA),
    PipelineStage(name: 'Negosiasi', count: 5, percentage: 0.48, colorHex: 0xFF3B82F6),
    PipelineStage(name: 'Disetujui', count: 3, percentage: 0.28, colorHex: 0xFF1E40AF),
  ],
  clientSegments: [
    ClientSegment(name: 'Villa', count: 635, badgeType: 'brand'),
    ClientSegment(name: 'Hotel & Resort', count: 84, badgeType: 'info'),
    ClientSegment(name: 'Residensial', count: 76, badgeType: 'neutral'),
    ClientSegment(name: 'F&B / Resto', count: 60, badgeType: 'ok'),
  ],
  recentProposals: [
    RecentProposal(
      id: 'p1',
      code: 'PRO-2026-0042',
      clientName: 'Villa Sari Dewi',
      serviceName: 'Termite Protection',
      region: 'Badung',
      status: 'Dikirim',
      amount: 'Rp 4,8jt',
    ),
    RecentProposal(
      id: 'p2',
      code: 'PRO-2026-0041',
      clientName: 'Hotel Surya Kuta',
      serviceName: 'Pest Control Bulanan',
      region: 'Badung',
      status: 'Negosiasi',
      amount: 'Rp 12,5jt',
    ),
  ],
  expiringContracts: [
    ExpiringContract(
      id: 'c1',
      code: 'KON-2024-0112',
      clientName: 'Villa Puri Tirtha',
      packageName: 'Termite 2 Thn',
      region: 'Gianyar',
      dueDate: '28 Agt 2026',
      amount: 'Rp 9,6jt',
      isCritical: true,
    ),
  ],
);

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

  testWidgets('DashboardPage renders summary data in UiSuccess', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    mockRepository.result = const Ok(sampleSummary);

    await tester.pumpWidget(wrap(DashboardPage(controller: controller)));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify NavRailShell and Header
    expect(find.byType(NavRailShell), findsOneWidget);
    expect(find.text('Selamat datang, Agus 👋'), findsOneWidget);
    expect(find.text('Agustus 2026 · Sales Wilayah Bali & Nusa Tenggara'), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('+ Pelanggan'), findsOneWidget);
    expect(find.text('Buat Proposal'), findsOneWidget);

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

  testWidgets('DashboardPage renders ErrorView on UiFailure and retries on tap', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    mockRepository.result = const Err(ServerFailure('Gagal memuat dashboard', 500));

    await tester.pumpWidget(wrap(DashboardPage(controller: controller)));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Gagal memuat dashboard'), findsOneWidget);

    // Update to success and tap retry
    mockRepository.result = const Ok(sampleSummary);
    await tester.tap(find.text('Coba Lagi'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsNothing);
    expect(find.text('Selamat datang, Agus 👋'), findsOneWidget);
  });
}
