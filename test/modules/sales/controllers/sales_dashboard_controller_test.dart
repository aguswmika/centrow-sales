import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/sales_dashboard_controller.dart';
import 'package:centrow_sales/modules/sales/repositories/sales_dashboard_repository.dart';
import 'package:centrow_sales/modules/sales/entities/sales_dashboard.dart'
    as entity;
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/error/failure.dart';

class FakeSalesDashboardRepository implements SalesDashboardRepository {
  Result<entity.SalesDashboardSummary>? result;
  @override
  Future<Result<entity.SalesDashboardSummary>> getDashboardSummary() async {
    return result!;
  }
}

void main() {
  late FakeSalesDashboardRepository fakeRepository;
  late SalesDashboardController controller;

  setUp(() {
    fakeRepository = FakeSalesDashboardRepository();
    controller = SalesDashboardController(fakeRepository);
  });

  tearDown(() {
    controller.dispose();
  });

  test('loadDashboard sets UiSuccess when repo returns Ok', () async {
    const summary = entity.SalesDashboardSummary(
      kpis: [],
      pipelineStages: [],
      clientSegments: [],
      recentProposals: [],
      expiringContracts: [],
      userName: 'User',
      branchName: 'Branch',
    );
    fakeRepository.result = const Ok(summary);

    await controller.loadDashboard();

    expect(
      controller.state.value,
      isA<UiSuccess<entity.SalesDashboardSummary>>(),
    );
    expect(
      (controller.state.value as UiSuccess<entity.SalesDashboardSummary>).data,
      summary,
    );
  });

  test('loadDashboard sets UiFailure when repo returns Err', () async {
    const failure = UnknownFailure('Error');
    fakeRepository.result = const Err(failure);

    await controller.loadDashboard();

    expect(
      controller.state.value,
      isA<UiFailure<entity.SalesDashboardSummary>>(),
    );
    expect(
      (controller.state.value as UiFailure<entity.SalesDashboardSummary>)
          .failure,
      failure,
    );
  });
}
