import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/customer_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_customer_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/segment.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';

class FakeCustomerRepository implements CustomerRepository {
  List<Customer> customers;
  bool shouldFailGetCustomers = false;
  bool shouldFailGetCustomerById = false;
  List<Segment> initialSegments;
  bool failSegments;

  FakeCustomerRepository({
    List<Customer>? initialCustomers,
    List<Segment>? initialSegments,
    this.failSegments = false,
  })  : customers = initialCustomers ??
            [
              const Customer(
                id: 'c1',
                code: 'CRM-0012',
                name: 'Villa Sari Dewi',
                initials: 'VS',
                segmentId: 'seg-villa',
                segment: 'Villa',
                status: 'active',
                regency: 'Kabupaten Badung',
                npwp: '12.345.678.9-567.000',
                phone: '+62 812-3456-7890',
                locations: [
                  CustomerLocation(
                    id: 'loc-1',
                    isPrimary: true,
                    label: 'Villa Utama',
                    addressLine: 'Jl. Raya Seminyak No. 88',
                    regency: 'Kabupaten Badung',
                  ),
                ],
                contacts: [
                  CustomerContact(
                    id: 'con-1',
                    name: 'Budi Santoso',
                    position: 'General Manager',
                    role: 'pic',
                    isPrimary: true,
                  ),
                ],
                proposals: [
                  CustomerProposalSummary(
                    id: 'prop-1',
                    code: 'PRO-2026-0042',
                    serviceName: 'Termite Protection',
                    proposalDate: '12 Agt 2026',
                    totalAmount: 8158500,
                    status: 'sent',
                  ),
                ],
              ),
              const Customer(
                id: 'c2',
                code: 'CRM-0084',
                name: 'Grand Hyatt Nusa Dua',
                initials: 'GH',
                segmentId: 'seg-hotel',
                segment: 'Hotel',
                status: 'active',
                regency: 'Kabupaten Badung',
                locations: [
                  CustomerLocation(
                    id: 'loc-2',
                    isPrimary: true,
                    label: 'Resort Main',
                    addressLine: 'Kawasan BTDC Nusa Dua',
                    regency: 'Kabupaten Badung',
                  ),
                ],
                contacts: [
                  CustomerContact(
                    id: 'con-2',
                    name: 'Sari Dewi',
                    position: 'Operations Manager',
                    role: 'pic',
                    isPrimary: true,
                  ),
                ],
              ),
              const Customer(
                id: 'c3',
                code: 'CRM-0099',
                name: 'Warung Made Sanur',
                initials: 'WM',
                segmentId: 'seg-restoran',
                segment: 'Restoran',
                status: 'inactive',
                regency: 'Kota Denpasar',
              ),
            ],
        initialSegments = initialSegments ?? [];

  @override
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  }) async {
    if (shouldFailGetCustomers) {
      return const Err(ServerFailure('Gagal memuat pelanggan'));
    }
    var list = customers;
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q) ||
              c.regency.toLowerCase().contains(q))
          .toList();
    }
    if (segmentId != null && segmentId != 'all') {
      list = list
          .where((c) =>
              c.segmentId == segmentId ||
              c.segment.toLowerCase() == segmentId.toLowerCase())
          .toList();
    }
    if (status != null && status != 'all') {
      list = list
          .where((c) => c.status.toLowerCase() == status.toLowerCase())
          .toList();
    }
    return Ok(list);
  }

  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    if (shouldFailGetCustomerById) {
      return const Err(ServerFailure('Gagal memuat detail'));
    }
    try {
      final found = customers.firstWhere((c) => c.id == id);
      return Ok(found);
    } catch (_) {
      return const Err(ServerFailure('Data tidak ditemukan', 404));
    }
  }

  @override
  Future<Result<Customer>> createCustomer(CreateCustomerInput input) async {
    final created = Customer(
      id: 'c${customers.length + 1}',
      code: input.code.isNotEmpty ? input.code : 'CRM-0901',
      name: input.name,
      initials: input.name.isNotEmpty
          ? input.name.substring(0, 2).toUpperCase()
          : 'CP',
      segmentId: input.segmentId,
      segment: input.segment.isNotEmpty ? input.segment : 'Villa',
      status: 'active',
      phone: input.phone,
      email: input.email,
    );
    customers.add(created);
    return Ok(created);
  }

  @override
  Future<Result<Customer>> updateCustomer(
    String id,
    CreateCustomerInput input,
  ) async {
    return createCustomer(input);
  }

  @override
  Future<Result<List<Segment>>> getSegments({
    int page = 1,
    int pageSize = 100,
    String? query,
  }) async {
    if (failSegments) {
      return const Err(ServerFailure('Segment load failed', 500));
    }
    return Ok(initialSegments);
  }
}

void main() {
  group('CustomerController', () {
    late FakeCustomerRepository repository;
    late CustomerController controller;

    setUp(() {
      repository = FakeCustomerRepository();
      controller = CustomerController(repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is properly configured', () {
      expect(controller.segmentsState.value, isA<UiInitial<List<Segment>>>());
      expect(controller.customersState.value, isA<UiInitial<List<Customer>>>());
      expect(controller.customerDetailState.value, isA<UiInitial<Customer>>());
      expect(controller.selectedCustomerId.value, '');
      expect(controller.searchQuery.value, '');
      expect(controller.selectedSegment.value, 'all');
      expect(controller.selectedStatus.value, 'all');
      expect(controller.activeDetailTab.value, 0);
      expect(controller.filteredCustomers.value, isEmpty);
      expect(controller.selectedCustomer.value, isNull);
    });

    test('loadCustomers populates list, defaults selection, and loads full detail', () async {
      await controller.loadCustomers();

      expect(controller.customersState.value, isA<UiSuccess<List<Customer>>>());
      final list = controller.filteredCustomers.value;
      expect(list.length, 3);

      expect(controller.selectedCustomerId.value, 'c1');
      expect(controller.customerDetailState.value, isA<UiSuccess<Customer>>());
      expect(controller.selectedCustomer.value, isNotNull);
      expect(controller.selectedCustomer.value?.id, 'c1');
      expect(controller.selectedCustomer.value?.locations.length, 1);
      expect(controller.selectedCustomer.value?.contacts.length, 1);
      expect(controller.selectedCustomer.value?.proposals.length, 1);
    });

    test('loadCustomers sets UiFailure on repository error', () async {
      repository.shouldFailGetCustomers = true;
      await controller.loadCustomers();

      expect(controller.customersState.value, isA<UiFailure<List<Customer>>>());
      expect(controller.filteredCustomers.value, isEmpty);
    });

    test('selectCustomer updates selectedCustomerId and fetches full details', () async {
      await controller.loadCustomers();

      await controller.selectCustomer('c2');
      expect(controller.selectedCustomerId.value, 'c2');
      expect(controller.customerDetailState.value, isA<UiSuccess<Customer>>());
      expect(controller.selectedCustomer.value?.id, 'c2');
      expect(controller.selectedCustomer.value?.name, 'Grand Hyatt Nusa Dua');
      expect(controller.selectedCustomer.value?.locations.length, 1);
    });

    test('selectCustomer with empty id resets customerDetailState', () async {
      await controller.loadCustomers();

      await controller.selectCustomer('');
      expect(controller.selectedCustomerId.value, '');
      expect(controller.customerDetailState.value, isA<UiInitial<Customer>>());
    });

    test('selectCustomer sets UiFailure when customer is not found', () async {
      await controller.loadCustomers();

      await controller.selectCustomer('non-existent');
      expect(controller.selectedCustomerId.value, 'non-existent');
      expect(controller.customerDetailState.value, isA<UiFailure<Customer>>());
    });

    test('filtering by search query updates filteredCustomers', () async {
      await controller.loadCustomers();

      controller.setSearchQuery('Dewi');
      final result = controller.filteredCustomers.value;
      expect(result.length, 1);
      expect(result.first.name, 'Villa Sari Dewi');

      controller.setSearchQuery('Denpasar');
      final denpasarResult = controller.filteredCustomers.value;
      expect(denpasarResult.length, 1);
      expect(denpasarResult.first.code, 'CRM-0099');
    });

    test('filtering by segment updates filteredCustomers', () async {
      await controller.loadCustomers();

      controller.selectSegment('Villa');
      final villas = controller.filteredCustomers.value;
      expect(villas.length, 1);
      expect(villas.first.segment, 'Villa');

      controller.selectSegment('seg-hotel');
      final hotels = controller.filteredCustomers.value;
      expect(hotels.length, 1);
      expect(hotels.first.name, 'Grand Hyatt Nusa Dua');
    });

    test('filtering by status updates filteredCustomers', () async {
      await controller.loadCustomers();

      controller.selectStatus('inactive');
      final inactive = controller.filteredCustomers.value;
      expect(inactive.length, 1);
      expect(inactive.first.id, 'c3');

      controller.selectStatus('active');
      final active = controller.filteredCustomers.value;
      expect(active.length, 2);
    });

    test('loadCustomers preserves existing selection if still present in list', () async {
      await controller.loadCustomers();
      await controller.selectCustomer('c2');
      expect(controller.selectedCustomerId.value, 'c2');

      // Reload customers
      await controller.loadCustomers();
      expect(controller.selectedCustomerId.value, 'c2');
      expect(controller.selectedCustomer.value?.id, 'c2');
    });

    test('setDetailTab updates activeDetailTab signal', () {
      controller.setDetailTab(2);
      expect(controller.activeDetailTab.value, 2);
    });

    test('loadSegments transitions to UiSuccess with segment list', () async {
      final segRepo = FakeCustomerRepository(
        initialSegments: [
          const Segment(id: 'seg-1', name: 'Villa'),
          const Segment(id: 'seg-2', name: 'Hotel'),
        ],
      );
      final ctrl = CustomerController(segRepo);
      await ctrl.loadSegments();
      expect(ctrl.segmentsState.value, isA<UiSuccess<List<Segment>>>());
      final data = (ctrl.segmentsState.value as UiSuccess<List<Segment>>).data;
      expect(data.length, 2);
      ctrl.dispose();
    });

    test('loadSegments sets UiFailure on error', () async {
      final failRepo = FakeCustomerRepository(failSegments: true);
      final ctrl = CustomerController(failRepo);
      await ctrl.loadSegments();
      expect(ctrl.segmentsState.value, isA<UiFailure<List<Segment>>>());
      ctrl.dispose();
    });
  });
}
