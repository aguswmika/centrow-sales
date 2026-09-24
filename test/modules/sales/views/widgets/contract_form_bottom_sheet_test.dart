import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/app/di.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/entities/contract_category.dart';
import 'package:centrow_sales/modules/sales/entities/contract_template_option.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_category_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/contract_form_bottom_sheet.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/widgets/app_searchable_selector.dart';

class FakeContractCategoryRepository implements ContractCategoryRepository {
  List<ContractCategory> categories = [];

  @override
  Future<Result<List<ContractCategory>>> getContractCategories({
    String? query,
  }) async {
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      return Ok(
        categories.where((c) => c.name.toLowerCase().contains(q)).toList(),
      );
    }
    return Ok(categories);
  }
}

class FakeContractRepository implements ContractRepository {
  @override
  Future<Result<List<Contract>>> getContracts({
    String? query,
    int? status,
  }) async => const Ok([]);

  @override
  Future<Result<Contract>> getContractById(String id) async =>
      const Err(ServerFailure('Not implemented'));

  @override
  Future<Result<Contract>> createContractFromProposal(
    String proposalId,
    ContractFormInput input,
  ) async => const Err(ServerFailure('Not implemented'));

  @override
  Future<Result<ContractStatusResult>> updateContract(
    String id,
    ContractFormInput input,
  ) async => Ok(ContractStatusResult(id: id, status: ContractStatus.draft));

  @override
  Future<Result<void>> deleteContract(String id) async => const Ok(null);

  @override
  Future<Result<ContractStatusResult>> activateContract(String id) async =>
      Ok(ContractStatusResult(id: id, status: ContractStatus.active));

  @override
  Future<Result<ContractStatusResult>> suspendContract(String id) async =>
      Ok(ContractStatusResult(id: id, status: ContractStatus.suspended));

  @override
  Future<Result<ContractStatusResult>> terminateContract(
    String id,
    String reason,
  ) async =>
      Ok(ContractStatusResult(id: id, status: ContractStatus.terminated));

  @override
  Future<Result<ContractStatusResult>> cancelContract(String id) async =>
      Ok(ContractStatusResult(id: id, status: ContractStatus.cancelled));
}

void main() {
  late FakeContractCategoryRepository mockCategoryRepo;
  late FakeContractRepository mockContractRepo;

  const monthlyCategory = ContractCategory(
    id: 'cat-monthly',
    name: 'Pest Control Monthly',
    scheduleCycle: ContractScheduleCycle.monthly,
    templates: [
      ContractTemplateOption(
        id: 'tmpl-1',
        label: 'Monthly Template',
        isDefault: true,
      ),
    ],
  );

  const yearlyCategory = ContractCategory(
    id: 'cat-yearly',
    name: 'Termite Control Yearly',
    scheduleCycle: ContractScheduleCycle.yearly,
    templates: [
      ContractTemplateOption(
        id: 'tmpl-2',
        label: 'Yearly Template',
        isDefault: true,
      ),
    ],
  );

  setUp(() {
    mockCategoryRepo = FakeContractCategoryRepository();
    mockContractRepo = FakeContractRepository();

    mockCategoryRepo.categories = [monthlyCategory, yearlyCategory];

    if (getIt.isRegistered<ContractCategoryRepository>()) {
      getIt.unregister<ContractCategoryRepository>();
    }
    if (getIt.isRegistered<ContractRepository>()) {
      getIt.unregister<ContractRepository>();
    }
    if (getIt.isRegistered<ContractFormController>()) {
      getIt.unregister<ContractFormController>();
    }

    getIt.registerSingleton<ContractCategoryRepository>(mockCategoryRepo);
    getIt.registerSingleton<ContractRepository>(mockContractRepo);
    getIt.registerFactory<ContractFormController>(
      () => ContractFormController(
        getIt<ContractRepository>(),
        getIt<ContractCategoryRepository>(),
      ),
    );
  });

  tearDown(() {
    if (getIt.isRegistered<ContractCategoryRepository>()) {
      getIt.unregister<ContractCategoryRepository>();
    }
    if (getIt.isRegistered<ContractRepository>()) {
      getIt.unregister<ContractRepository>();
    }
    if (getIt.isRegistered<ContractFormController>()) {
      getIt.unregister<ContractFormController>();
    }
  });

  Widget buildTestWidget({Contract? initialContract}) {
    return MaterialApp(
      home: Scaffold(
        body: ContractFormBottomSheet(
          proposalId: 'prop-1',
          proposalCode: 'PROP-001',
          customerName: 'PT Maju Terus',
          serviceName: 'General Pest Control',
          initialContract: initialContract,
        ),
      ),
    );
  }

  testWidgets(
    'Category selector formats item with (\${cat.scheduleCycle.displayName}) and selecting displays cycle guidance for monthly',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // No cycle guidance displayed yet when category is null
      expect(find.textContaining('Siklus kuota kunjungan:'), findsNothing);

      // Tap category selector to open modal
      await tester.tap(find.byType(AppSearchableSelector<ContractCategory>));
      await tester.pumpAndSettle();

      // Verify categories formatted with (${cat.scheduleCycle.displayName})
      expect(find.text('Pest Control Monthly (Bulanan)'), findsOneWidget);
      expect(find.text('Termite Control Yearly (Tahunan)'), findsOneWidget);

      // Select monthly category
      await tester.tap(find.text('Pest Control Monthly (Bulanan)'));
      await tester.pumpAndSettle();

      // Category selector input field now displays the selected item formatted with cycle
      expect(find.text('Pest Control Monthly (Bulanan)'), findsOneWidget);

      // Cycle guidance banner / caption is visible for monthly
      expect(
        find.text('Siklus kuota kunjungan: Bulanan (diperbarui setiap bulan)'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Selecting yearly category displays cycle guidance for yearly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap category selector to open modal
    await tester.tap(find.byType(AppSearchableSelector<ContractCategory>));
    await tester.pumpAndSettle();

    // Select yearly category
    await tester.tap(find.text('Termite Control Yearly (Tahunan)'));
    await tester.pumpAndSettle();

    // Cycle guidance banner / caption is visible for yearly
    expect(
      find.text('Siklus kuota kunjungan: Tahunan (total masa kontrak)'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Initial contract with monthly scheduleCycle pre-renders cycle guidance',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const contract = Contract(
        id: 'c-100',
        code: 'CTR-100',
        customerId: 'cust-1',
        customerName: 'PT Maju Terus',
        serviceId: 'srv-1',
        serviceName: 'General Pest Control',
        categoryId: 'cat-monthly',
        categoryName: 'Pest Control Monthly',
        scheduleCycle: ContractScheduleCycle.monthly,
        status: ContractStatus.draft,
        startDate: '2026-01-01',
      );

      await tester.pumpWidget(buildTestWidget(initialContract: contract));
      await tester.pumpAndSettle();

      expect(find.text('Pest Control Monthly (Bulanan)'), findsOneWidget);
      expect(
        find.text('Siklus kuota kunjungan: Bulanan (diperbarui setiap bulan)'),
        findsOneWidget,
      );
    },
  );
}
