import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_form/step1_identity_form.dart';
import 'package:centrow_sales/shared/result/result.dart';

class FakeCustomerRepository implements CustomerRepository {
  @override
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  }) async => const Ok([]);

  @override
  Future<Result<Customer>> getCustomerById(String id) async => const Ok(
    Customer(
      id: '1',
      code: 'CUST-001',
      name: 'Test',
      initials: 'T',
      segmentId: '1',
      segment: 'Villa',
      status: 'active',
    ),
  );

  @override
  Future<Result<Customer>> createCustomer(CreateCustomerInput input) async =>
      const Ok(
        Customer(
          id: '1',
          code: 'CUST-001',
          name: 'Test',
          initials: 'T',
          segmentId: '1',
          segment: 'Villa',
          status: 'active',
        ),
      );

  @override
  Future<Result<Customer>> updateCustomer(
    String id,
    CreateCustomerInput input,
  ) async => const Ok(
    Customer(
      id: '1',
      code: 'CUST-001',
      name: 'Test',
      initials: 'T',
      segmentId: '1',
      segment: 'Villa',
      status: 'active',
    ),
  );

  @override
  Future<Result<List<Segment>>> getSegments({
    int page = 1,
    int pageSize = 100,
    String? query,
  }) async => const Ok([Segment(id: 'seg-1', name: 'Hospitality')]);
}

void main() {
  group('Step1IdentityForm', () {
    late CustomerFormController controller;

    setUp(() {
      controller = CustomerFormController(FakeCustomerRepository());
      controller.loadSegments();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Step1IdentityForm(controller: controller),
          ),
        ),
      );
    }

    testWidgets('renders Catatan Risiko Internal label in section 3', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Catatan Risiko Internal'), findsOneWidget);
      expect(find.text('Site Risk Assessment'), findsNothing);
    });

    testWidgets(
      'Pajak Pertambahan Nilai (PPN) input updates controller.taxPercentage.value',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Pajak Pertambahan Nilai (PPN)'), findsOneWidget);
        expect(find.text('%'), findsOneWidget);

        final ppnFinder = find.descendant(
          of: find
              .ancestor(
                of: find.text('Pajak Pertambahan Nilai (PPN)'),
                matching: find.byType(Column),
              )
              .first,
          matching: find.byType(TextFormField),
        );

        await tester.enterText(ppnFinder, '11');
        await tester.pumpAndSettle();
        expect(controller.taxPercentage.value, 11.0);

        await tester.enterText(ppnFinder, '12.5');
        await tester.pumpAndSettle();
        expect(controller.taxPercentage.value, 12.5);

        await tester.enterText(ppnFinder, '0');
        await tester.pumpAndSettle();
        expect(controller.taxPercentage.value, 0.0);
      },
    );

    testWidgets('Catatan Risiko Internal binds to controller.riskNotes.value', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final riskNotesFinder = find.descendant(
        of: find
            .ancestor(
              of: find.text('Catatan Risiko Internal'),
              matching: find.byType(Column),
            )
            .first,
        matching: find.byType(TextFormField),
      );

      await tester.enterText(
        riskNotesFinder,
        'Catatan risiko pembayaran macet',
      );
      await tester.pumpAndSettle();
      expect(controller.riskNotes.value, 'Catatan risiko pembayaran macet');
    });

    testWidgets('displays initial tax percentage when non-zero', (
      tester,
    ) async {
      controller.taxPercentage.value = 12.0;
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('12'), findsOneWidget);
    });
  });
}
