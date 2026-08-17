import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_controller.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/modules/sales/views/pages/customer_page.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_detail_pane.dart';
import 'package:centrow_sales/modules/sales/views/widgets/customer_master_list.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/widgets/error_view.dart';

class MockCustomerRepository implements CustomerRepository {
  Result<List<Customer>> result = const Ok(mockCustomers);

  @override
  Future<Result<List<Customer>>> getCustomers({
    String? query,
    String? segment,
  }) async {
    if (result is Err) return result;
    var list = mockCustomers;
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where(
            (c) =>
                c.name.toLowerCase().contains(q) ||
                c.code.toLowerCase().contains(q) ||
                c.regency.toLowerCase().contains(q),
          )
          .toList();
    }
    if (segment != null && segment != 'all') {
      list = list.where((c) => c.segment == segment).toList();
    }
    return Ok(list);
  }

  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    return Ok(mockCustomers.firstWhere((c) => c.id == id));
  }
}

Widget wrap(Widget child) {
  return MaterialApp(home: Material(child: child));
}

void main() {
  late MockCustomerRepository mockRepo;
  late CustomerController controller;

  setUp(() {
    mockRepo = MockCustomerRepository();
    controller = CustomerController(mockRepo);
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets('CustomerPage renders master-detail view on tablet size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await controller.loadCustomers();

    await tester.pumpWidget(wrap(CustomerPage(controller: controller)));
    await tester.pump();

    // Verify Customer master list
    expect(find.byType(CustomerMasterList), findsOneWidget);
    expect(find.byType(CustomerDetailPane), findsOneWidget);

    // Verify Title & Default Selected Customer
    expect(find.text('Daftar Pelanggan'), findsOneWidget);
    expect(find.text('Villa Sari Dewi'), findsWidgets);
    expect(find.text('CRM-0012'), findsWidgets);
    expect(find.text('contact@villasaridewi.com'), findsOneWidget);
  });

  testWidgets('Tapping a customer updates the detail pane', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await controller.loadCustomers();

    await tester.pumpWidget(wrap(CustomerPage(controller: controller)));
    await tester.pump();

    // Tap on Grand Hyatt Nusa Dua
    await tester.tap(find.text('Grand Hyatt Nusa Dua').first);
    await tester.pump();

    expect(controller.selectedCustomer.value?.name, 'Grand Hyatt Nusa Dua');
    expect(find.text('procurement@grandhyattbali.com'), findsOneWidget);
  });

  testWidgets('Switching detail tabs updates tab contents', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await controller.loadCustomers();

    await tester.pumpWidget(wrap(CustomerPage(controller: controller)));
    await tester.pump();

    // Switch to Lokasi & Titik Servis tab
    await tester.tap(find.text('Lokasi & Titik Servis'));
    await tester.pump();
    expect(find.text('Villa Utama & Club House'), findsOneWidget);

    // Switch to Kontak Person & PIC tab
    await tester.tap(find.text('Kontak Person & PIC'));
    await tester.pump();
    expect(find.text('Budi Santoso'), findsOneWidget);

    // Switch to Riwayat Proposal tab
    await tester.ensureVisible(find.text('Riwayat Proposal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riwayat Proposal'));
    await tester.pumpAndSettle();
    expect(find.text('Termite Protection Plan (2 Tahun)'), findsOneWidget);
  });

  testWidgets('CustomerPage renders ErrorView on UiFailure and retries', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    mockRepo.result = const Err(ServerFailure('Koneksi terputus', 500));
    await controller.loadCustomers();

    await tester.pumpWidget(wrap(CustomerPage(controller: controller)));
    await tester.pump();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('Koneksi terputus'), findsOneWidget);

    // Tap retry
    mockRepo.result = const Ok(mockCustomers);
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerMasterList), findsOneWidget);
  });
}
