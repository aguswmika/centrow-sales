import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/customer_form_topbar.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class FakeCustomerRepository implements CustomerRepository {
  @override
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  }) async =>
      const Ok([]);

  @override
  Future<Result<Customer>> getCustomerById(String id) async =>
      const Err(ServerFailure('Not found', 404));

  @override
  Future<Result<Customer>> createCustomer(CreateCustomerInput input) async =>
      const Err(ServerFailure('Not implemented', 500));

  @override
  Future<Result<Customer>> updateCustomer(
    String id,
    CreateCustomerInput input,
  ) async =>
      const Err(ServerFailure('Not implemented', 500));

  @override
  Future<Result<List<Segment>>> getSegments({
    int page = 1,
    int pageSize = 100,
    String? query,
  }) async =>
      const Ok([]);
}

void main() {
  group('CustomerFormTopbar', () {
    late CustomerFormController controller;

    setUp(() {
      controller = CustomerFormController(FakeCustomerRepository());
    });

    Widget buildTopbar({
      required WidgetTester tester,
      required int currentStep,
      bool isEditMode = false,
      VoidCallback? onNext,
      VoidCallback? onPrev,
      VoidCallback? onCancel,
      VoidCallback? onSubmit,
      Size size = const Size(1200, 800),
    }) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      return MaterialApp(
        home: Scaffold(
          body: CustomerFormTopbar(
            controller: controller,
            currentStep: currentStep,
            isEditMode: isEditMode,
            onStepChanged: (_) {},
            onCancel: onCancel ?? () {},
            onNext: onNext ?? () {},
            onPrev: onPrev,
            onSubmit: onSubmit,
          ),
        ),
      );
    }

    group('Create mode (isEditMode == false)', () {
      testWidgets('step 1: shows only Selanjutnya button', (tester) async {
        var nextCalled = false;
        await tester.pumpWidget(
          buildTopbar(
            tester: tester,
            currentStep: 1,
            isEditMode: false,
            onNext: () => nextCalled = true,
          ),
        );

        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.text('Simpan'), findsNothing);
        expect(find.byIcon(Icons.chevron_left), findsNothing);

        await tester.tap(find.byIcon(Icons.chevron_right));
        expect(nextCalled, isTrue);
      });

      testWidgets('step 2: shows Sebelumnya and Selanjutnya buttons', (tester) async {
        var prevCalled = false;
        var nextCalled = false;
        await tester.pumpWidget(
          buildTopbar(
            tester: tester,
            currentStep: 2,
            isEditMode: false,
            onPrev: () => prevCalled = true,
            onNext: () => nextCalled = true,
          ),
        );

        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.text('Simpan'), findsNothing);

        await tester.tap(find.byIcon(Icons.chevron_left));
        expect(prevCalled, isTrue);

        await tester.tap(find.byIcon(Icons.chevron_right));
        expect(nextCalled, isTrue);
      });

      testWidgets('step 3: shows Sebelumnya and Simpan (calling onNext) buttons', (tester) async {
        var nextCalled = false;
        await tester.pumpWidget(
          buildTopbar(
            tester: tester,
            currentStep: 3,
            isEditMode: false,
            onNext: () => nextCalled = true,
          ),
        );

        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.text('Simpan'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsNothing);

        await tester.tap(find.text('Simpan'));
        expect(nextCalled, isTrue);
      });
    });

    group('Edit mode (isEditMode == true)', () {
      testWidgets('step 1: shows Selanjutnya and Simpan buttons on far right', (tester) async {
        var nextCalled = false;
        var submitCalled = false;
        await tester.pumpWidget(
          buildTopbar(
            tester: tester,
            currentStep: 1,
            isEditMode: true,
            onNext: () => nextCalled = true,
            onSubmit: () => submitCalled = true,
          ),
        );

        expect(find.byIcon(Icons.chevron_left), findsNothing);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.text('Simpan'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.chevron_right));
        expect(nextCalled, isTrue);

        await tester.tap(find.text('Simpan'));
        expect(submitCalled, isTrue);
      });

      testWidgets('step 2: shows Sebelumnya, Selanjutnya, and Simpan buttons', (tester) async {
        var prevCalled = false;
        var nextCalled = false;
        var submitCalled = false;
        await tester.pumpWidget(
          buildTopbar(
            tester: tester,
            currentStep: 2,
            isEditMode: true,
            onPrev: () => prevCalled = true,
            onNext: () => nextCalled = true,
            onSubmit: () => submitCalled = true,
          ),
        );

        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.text('Simpan'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.chevron_left));
        expect(prevCalled, isTrue);

        await tester.tap(find.byIcon(Icons.chevron_right));
        expect(nextCalled, isTrue);

        await tester.tap(find.text('Simpan'));
        expect(submitCalled, isTrue);
      });

      testWidgets('step 3: shows Sebelumnya and Simpan buttons (calls onSubmit), no Selanjutnya', (tester) async {
        var prevCalled = false;
        var submitCalled = false;
        await tester.pumpWidget(
          buildTopbar(
            tester: tester,
            currentStep: 3,
            isEditMode: true,
            onPrev: () => prevCalled = true,
            onSubmit: () => submitCalled = true,
          ),
        );

        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.text('Simpan'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsNothing);

        await tester.tap(find.byIcon(Icons.chevron_left));
        expect(prevCalled, isTrue);

        await tester.tap(find.text('Simpan'));
        expect(submitCalled, isTrue);
      });
    });
  });
}
