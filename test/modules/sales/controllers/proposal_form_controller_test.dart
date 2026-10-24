import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/proposal_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/create_proposal_input.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_template_option.dart';
import 'package:centrow_sales/modules/sales/entities/service.dart';
import 'package:centrow_sales/modules/sales/entities/update_proposal_input.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/service_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/sync/data_sync_event.dart';
import 'package:centrow_sales/shared/sync/data_sync_service.dart';

class MockProposalRepository implements ProposalRepository {
  CreateProposalInput? lastCreateInput;
  UpdateProposalInput? lastUpdateInput;
  String? lastUpdateId;
  Result<Proposal> response = const Ok(
    Proposal(
      id: 'prop-new',
      code: 'PRO-2026-0001',
      customerId: 'cust-1',
      clientName: 'Client 1',
      serviceId: 'srv-1',
      serviceName: 'Service 1',
      status: ProposalStatus.draft,
      date: '2026-09-01',
      validUntil: '2026-10-01',
      location: 'Location 1',
      version: '1',
      total: 1000000.0,
    ),
  );

  @override
  Future<Result<Proposal>> createProposal(CreateProposalInput input) async {
    lastCreateInput = input;
    return response;
  }

  @override
  Future<Result<Proposal>> updateProposal(
    String id,
    UpdateProposalInput input,
  ) async {
    lastUpdateId = id;
    lastUpdateInput = input;
    return response;
  }

  @override
  Future<Result<Proposal>> reviseProposal(
    String id,
    UpdateProposalInput input,
  ) async {
    lastUpdateId = id;
    lastUpdateInput = input;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCustomerRepository implements CustomerRepository {
  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    return Ok(
      Customer(
        id: id,
        code: 'CRM-1',
        name: 'Client 1',
        initials: 'C1',
        segment: 'Hotel',
        status: 'active',
        locations: [
          const CustomerLocation(
            id: 'loc-1',
            isPrimary: true,
            label: 'Main',
            addressLine: 'Jl. Main',
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<List<Customer>>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? query,
    String? segmentId,
    String? status,
  }) async => const Ok([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockServiceRepository implements ServiceRepository {
  @override
  Future<Result<List<ProposalTemplateOption>>> getSelectableProposalTemplates(
    String serviceId,
  ) async {
    return const Ok([
      ProposalTemplateOption(
        value: 'tmpl-1',
        label: 'Template 1',
        isDefault: true,
      ),
    ]);
  }

  @override
  Future<Result<List<Service>>> getServices({String? query}) async =>
      const Ok([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ProposalFormController DataSync', () {
    late MockProposalRepository proposalRepo;
    late MockCustomerRepository customerRepo;
    late MockServiceRepository serviceRepo;
    late DataSyncService syncService;
    late ProposalFormController controller;

    setUp(() {
      proposalRepo = MockProposalRepository();
      customerRepo = MockCustomerRepository();
      serviceRepo = MockServiceRepository();
      syncService = DataSyncServiceImpl();
      controller = ProposalFormController(
        proposalRepo,
        customerRepo,
        serviceRepo,
        syncService,
      );
    });

    tearDown(() {
      controller.dispose();
      syncService.dispose();
    });

    test(
      'submit emits ProposalSyncEvent with created action on create',
      () async {
        final emittedEvents = <DataSyncEvent>[];
        final sub = syncService.events.listen(emittedEvents.add);

        controller.customerId = 'cust-1';
        controller.addressId = 'loc-1';
        controller.serviceId = 'srv-1';
        controller.proposalDate = '2026-09-01';
        controller.templateId = 'tmpl-1';

        final result = await controller.submit();
        await Future<void>.delayed(Duration.zero);

        expect(result.isOk, isTrue);
        expect(emittedEvents.length, 1);
        final event = emittedEvents.first;
        expect(event, isA<ProposalSyncEvent>());
        final propEvent = event as ProposalSyncEvent;
        expect(propEvent.proposalId, 'prop-new');
        expect(propEvent.customerId, 'cust-1');
        expect(propEvent.action, SyncAction.created);

        await sub.cancel();
      },
    );

    test(
      'submit emits ProposalSyncEvent with updated action on edit',
      () async {
        final emittedEvents = <DataSyncEvent>[];
        final sub = syncService.events.listen(emittedEvents.add);

        const existingProposal = Proposal(
          id: 'prop-edit-1',
          code: 'PRO-2026-0001',
          customerId: 'cust-1',
          clientName: 'Client 1',
          serviceId: 'srv-1',
          serviceName: 'Service 1',
          status: ProposalStatus.draft,
          date: '2026-09-01',
          validUntil: '2026-10-01',
          location: 'Location 1',
          addressId: 'loc-1',
          version: '1',
          total: 1000000.0,
        );
        controller.initForEdit(existingProposal);
        proposalRepo.response = const Ok(existingProposal);

        final result = await controller.submit();
        await Future<void>.delayed(Duration.zero);

        expect(result.isOk, isTrue);
        expect(emittedEvents.length, 1);
        final event = emittedEvents.first;
        expect(event, isA<ProposalSyncEvent>());
        final propEvent = event as ProposalSyncEvent;
        expect(propEvent.proposalId, 'prop-edit-1');
        expect(propEvent.customerId, 'cust-1');
        expect(propEvent.action, SyncAction.updated);

        await sub.cancel();
      },
    );

    test(
      'submit emits ProposalSyncEvent with updated action on revise',
      () async {
        final emittedEvents = <DataSyncEvent>[];
        final sub = syncService.events.listen(emittedEvents.add);

        const existingProposal = Proposal(
          id: 'prop-revise-1',
          code: 'PRO-2026-0001',
          customerId: 'cust-1',
          clientName: 'Client 1',
          serviceId: 'srv-1',
          serviceName: 'Service 1',
          status: ProposalStatus.draft,
          date: '2026-09-01',
          validUntil: '2026-10-01',
          location: 'Location 1',
          addressId: 'loc-1',
          version: '1',
          total: 1000000.0,
        );
        controller.initForRevise(existingProposal);
        proposalRepo.response = const Ok(existingProposal);

        final result = await controller.submit();
        await Future<void>.delayed(Duration.zero);

        expect(result.isOk, isTrue);
        expect(emittedEvents.length, 1);
        final event = emittedEvents.first;
        expect(event, isA<ProposalSyncEvent>());
        final propEvent = event as ProposalSyncEvent;
        expect(propEvent.proposalId, 'prop-revise-1');
        expect(propEvent.customerId, 'cust-1');
        expect(propEvent.action, SyncAction.updated);

        await sub.cancel();
      },
    );

    test(
      'submit does not emit ProposalSyncEvent when repository fails',
      () async {
        final emittedEvents = <DataSyncEvent>[];
        final sub = syncService.events.listen(emittedEvents.add);

        proposalRepo.response = const Err(ServerFailure('Failed'));
        controller.customerId = 'cust-1';
        controller.addressId = 'loc-1';
        controller.serviceId = 'srv-1';
        controller.proposalDate = '2026-09-01';
        controller.templateId = 'tmpl-1';

        final result = await controller.submit();
        await Future<void>.delayed(Duration.zero);

        expect(result.isErr, isTrue);
        expect(emittedEvents, isEmpty);

        await sub.cancel();
      },
    );

    test('submit returns error when required fields are missing', () async {
      // All missing
      final result1 = await controller.submit();
      expect(result1.isErr, isTrue);
      expect(
        (result1 as Err).failure.message,
        'Pelanggan, Layanan, Alamat, Tanggal Proposal wajib diisi.',
      );

      // Customer filled, but addressId cleared, others missing
      controller.customerId = 'cust-1';
      controller.addressId = null;
      final result2 = await controller.submit();
      expect(result2.isErr, isTrue);
      expect(
        (result2 as Err).failure.message,
        'Layanan, Alamat, Tanggal Proposal wajib diisi.',
      );

      // Service filled, address missing
      controller.serviceId = 'srv-1';
      controller.proposalDate = '2026-10-19';
      controller.addressId = null;
      final result3 = await controller.submit();
      expect(result3.isErr, isTrue);
      expect((result3 as Err).failure.message, 'Alamat wajib diisi.');

      // Address filled, template missing in create mode
      controller.addressId = 'loc-1';
      final result4 = await controller.submit();
      expect(result4.isErr, isTrue);
      expect(
        (result4 as Err).failure.message,
        'Template proposal wajib dipilih.',
      );
    });
  });
}
