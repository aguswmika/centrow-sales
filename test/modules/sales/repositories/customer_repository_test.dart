import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

void main() {
  late CustomerRepository repository;

  setUp(() {
    repository = CustomerRepositoryImpl(Dio(), useMock: true);
  });

  group('CustomerRepositoryImpl', () {
    test(
      'getCustomers returns all 7 mock customers when no filters applied',
      () async {
        final result = await repository.getCustomers();
        expect(result.isOk, isTrue);
        final customers = (result as Ok<List<Customer>>).value;
        expect(customers.length, 7);
        expect(customers.first.name, 'Villa Sari Dewi');
        expect(customers.first.code, 'CRM-0012');
      },
    );

    test(
      'getCustomers filters by search query matching name, code, or regency',
      () async {
        final resultByName = await repository.getCustomers(query: 'Hyatt');
        expect(resultByName.isOk, isTrue);
        final list = (resultByName as Ok<List<Customer>>).value;
        expect(list.length, 1);
        expect(list.first.code, 'CRM-0084');

        final resultByCode = await repository.getCustomers(query: 'CRM-0512');
        expect(resultByCode.isOk, isTrue);
        expect(
          (resultByCode as Ok<List<Customer>>).value.first.name,
          'Puri Bali Residence',
        );

        final resultByRegency = await repository.getCustomers(
          query: 'Denpasar',
        );
        expect(resultByRegency.isOk, isTrue);
        expect((resultByRegency as Ok<List<Customer>>).value.length, 2);
      },
    );

    test('getCustomers filters by segment correctly', () async {
      final result = await repository.getCustomers(segment: 'Villa');
      expect(result.isOk, isTrue);
      final list = (result as Ok<List<Customer>>).value;
      expect(list.length, 2);
      expect(list.every((c) => c.segment == 'Villa'), isTrue);
    });

    test('getCustomerById returns customer on valid ID', () async {
      final result = await repository.getCustomerById('c1');
      expect(result.isOk, isTrue);
      final customer = (result as Ok<Customer>).value;
      expect(customer.name, 'Villa Sari Dewi');
      expect(customer.locations.length, 2);
      expect(customer.contacts.length, 3);
      expect(customer.proposals.length, 2);
    });

    test('getCustomerById returns ServerFailure (404) on invalid ID', () async {
      final result = await repository.getCustomerById('c999');
      expect(result.isErr, isTrue);
      final failure = (result as Err<Customer>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.statusCode, 404);
    });
  });
}
