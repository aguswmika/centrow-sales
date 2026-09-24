import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_controller.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_addendum_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/contract_addendum_form_sheet.dart';

class MockContractAddendumRepository implements ContractAddendumRepository {
  Result<ContractAddendum>? createResult;
  int? createdDelta;
  String? createdReason;

  @override
  Future<Result<List<ContractAddendum>>> getAddendums(String contractId) async {
    return const Ok([]);
  }

  @override
  Future<Result<ContractAddendum>> createAddendum(
    String contractId, {
    required int visitDelta,
    String? reason,
  }) async {
    createdDelta = visitDelta;
    createdReason = reason;
    return createResult ??
        Ok(
          ContractAddendum(
            id: 'new-id',
            contractId: contractId,
            visitDelta: visitDelta,
            oldTotalVisits: 12,
            newTotalVisits: 12 + visitDelta,
            oldContractValue: 12000000.0,
            newContractValue: 13000000.0,
            reason: reason,
          ),
        );
  }
}

void main() {
  const sampleContract = Contract(
    id: 'ctr-100',
    code: 'CTR-2026-0100',
    customerId: 'cust-1',
    customerName: 'PT Sukses Mandiri',
    serviceId: 'srv-1',
    serviceName: 'General Pest Control',
    categoryId: 'cat-1',
    categoryName: 'Commercial',
    status: ContractStatus.active,
    startDate: '2026-01-01',
    totalVisits: 12,
  );

  late MockContractAddendumRepository mockRepo;
  late ContractAddendumController controller;

  setUp(() {
    mockRepo = MockContractAddendumRepository();
    controller = ContractAddendumController(mockRepo);
  });

  tearDown(() {
    controller.dispose();
  });

  group('ContractAddendumFormSheet', () {
    testWidgets('renders contract details and initial zero state calculation', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContractAddendumFormSheet(
              contract: sampleContract,
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Buat Addendum Kontrak'), findsOneWidget);
      expect(find.text('CTR-2026-0100 · PT Sukses Mandiri'), findsOneWidget);
      expect(
        find.text('12 kunjungan'),
        findsNWidgets(2),
      ); // current and initial new
    });

    testWidgets('adjusts delta and calculates new total visits with buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContractAddendumFormSheet(
              contract: sampleContract,
              controller: controller,
            ),
          ),
        ),
      );

      // Tap '+1' quick button
      await tester.tap(find.text('+1'));
      await tester.pump();

      expect(find.text('+1 kunjungan'), findsOneWidget);
      expect(find.text('13 kunjungan'), findsOneWidget); // 12 + 1 = 13

      // Tap '+5' quick button
      await tester.tap(find.text('+5'));
      await tester.pump();

      expect(find.text('+6 kunjungan'), findsOneWidget);
      expect(find.text('18 kunjungan'), findsOneWidget); // 12 + 6 = 18
    });

    testWidgets('validates zero delta and shows error on submit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContractAddendumFormSheet(
              contract: sampleContract,
              controller: controller,
            ),
          ),
        ),
      );

      // Submit without adjusting delta
      await tester.tap(find.text('Simpan Addendum'));
      await tester.pump();

      expect(find.text('Perubahan kunjungan tidak boleh 0'), findsOneWidget);
      expect(mockRepo.createdDelta, isNull);
    });

    testWidgets('validates total visits <= 0 and shows error', (tester) async {
      tester.view.physicalSize = const Size(1000, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContractAddendumFormSheet(
              contract: sampleContract,
              controller: controller,
            ),
          ),
        ),
      );

      // Enter -15 to make new total visits 12 + (-15) = -3 <= 0
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '-15');
      await tester.pump();

      expect(
        find.text('Total kunjungan baru harus lebih dari 0'),
        findsOneWidget,
      );

      await tester.tap(find.text('Simpan Addendum'));
      await tester.pump();

      expect(mockRepo.createdDelta, isNull);
    });

    testWidgets('submits addendum successfully and calls controller', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContractAddendumFormSheet(
              contract: sampleContract,
              controller: controller,
            ),
          ),
        ),
      );

      // Adjust delta by +2
      await tester.tap(find.widgetWithText(InkWell, '+1'));
      await tester.pump();
      await tester.tap(find.widgetWithText(InkWell, '+1'));
      await tester.pump();

      // Enter reason in the second textfield
      final reasonField = find.byType(TextField).last;
      await tester.enterText(reasonField, 'Penambahan lantai 3');
      await tester.pump();

      // Submit
      await tester.tap(find.text('Simpan Addendum'));
      await tester.pumpAndSettle();

      expect(mockRepo.createdDelta, 2);
      expect(mockRepo.createdReason, 'Penambahan lantai 3');
    });

    testWidgets('shows server error message when submission fails', (
      tester,
    ) async {
      mockRepo.createResult = const Err(
        ServerFailure('Total visits cannot drop below scheduled count', 400),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContractAddendumFormSheet(
              contract: sampleContract,
              controller: controller,
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(InkWell, '-1'));
      await tester.pump();

      await tester.tap(find.text('Simpan Addendum'));
      await tester.pump();

      expect(
        find.text('Total visits cannot drop below scheduled count'),
        findsAtLeastNWidgets(1),
      );
    });
  });
}
