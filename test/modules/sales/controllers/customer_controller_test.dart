import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_controller.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class MockCustomerRepository implements CustomerRepository {
  Result<List<Customer>>? customersResult;
  Result<Customer>? customerByIdResult;

  @override
  Future<Result<List<Customer>>> getCustomers({
    String? query,
    String? segment,
  }) async {
    if (customersResult != null) return customersResult!;
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
    return customerByIdResult ??
        Ok(mockCustomers.firstWhere((c) => c.id == id));
  }
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

  group('CustomerController', () {
    test('loadCustomers sets UiSuccess with customer list', () async {
      await controller.loadCustomers();
      expect(controller.customersState.value, isA<UiSuccess<List<Customer>>>());
      expect(controller.filteredCustomers.value.length, 7);
      expect(controller.selectedCustomer.value?.name, 'Villa Sari Dewi');
    });

    test('loadCustomers sets UiFailure on repository error', () async {
      mockRepo.customersResult = const Err(
        ServerFailure('Gagal memuat pelanggan', 500),
      );
      await controller.loadCustomers();
      expect(controller.customersState.value, isA<UiFailure<List<Customer>>>());
      expect(controller.filteredCustomers.value, isEmpty);
      expect(controller.selectedCustomer.value, isNull);
    });

    test('setSearchQuery filters customers reactively', () async {
      await controller.loadCustomers();
      controller.setSearchQuery('Starbucks');
      expect(controller.searchQuery.value, 'Starbucks');
      expect(controller.filteredCustomers.value.length, 1);
      expect(controller.selectedCustomer.value?.code, 'CRM-0633');
    });

    test('selectSegment filters customers by category', () async {
      await controller.loadCustomers();
      controller.selectSegment('Hotel');
      expect(controller.selectedSegment.value, 'Hotel');
      expect(controller.filteredCustomers.value.length, 1);
      expect(controller.selectedCustomer.value?.name, 'Grand Hyatt Nusa Dua');
    });

    test('selectCustomer updates selectedCustomer computed signal', () async {
      await controller.loadCustomers();
      controller.selectCustomer('c3');
      expect(controller.selectedCustomerId.value, 'c3');
      expect(controller.selectedCustomer.value?.name, 'Resto Warung Bumi');
    });

    test('setDetailTab updates activeDetailTab signal', () {
      expect(controller.activeDetailTab.value, 0);
      controller.setDetailTab(2);
      expect(controller.activeDetailTab.value, 2);
    });
  });
}
