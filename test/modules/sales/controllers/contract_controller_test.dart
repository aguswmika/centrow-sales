import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_controller.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/shared/sync/data_sync_event.dart';
import 'package:centrow_sales/shared/sync/data_sync_service.dart';

class FakeContractRepository implements ContractRepository {
  List<Contract> contracts = [];

  @override
  Future<Result<List<Contract>>> getContracts({
    String? query,
    int? status,
  }) async {
    return Ok(contracts);
  }

  @override
  Future<Result<Contract>> getContractById(String id) async {
    final c = contracts.firstWhere((e) => e.id == id);
    return Ok(c);
  }

  @override
  Future<Result<Contract>> createContractFromProposal(
    String proposalId,
    dynamic input,
  ) async {
    return const Err(ServerFailure('Not implemented'));
  }

  @override
  Future<Result<ContractStatusResult>> updateContract(
    String id,
    ContractFormInput input,
  ) async {
    return Ok(ContractStatusResult(id: id, status: ContractStatus.draft));
  }

  @override
  Future<Result<void>> deleteContract(String id) async {
    contracts.removeWhere((e) => e.id == id);
    return const Ok(null);
  }

  @override
  Future<Result<ContractStatusResult>> activateContract(String id) async {
    return Ok(ContractStatusResult(id: id, status: ContractStatus.active));
  }

  @override
  Future<Result<ContractStatusResult>> suspendContract(String id) async {
    return Ok(ContractStatusResult(id: id, status: ContractStatus.suspended));
  }

  @override
  Future<Result<ContractStatusResult>> terminateContract(
    String id,
    String reason,
  ) async {
    return Ok(ContractStatusResult(id: id, status: ContractStatus.terminated));
  }

  @override
  Future<Result<ContractStatusResult>> cancelContract(String id) async {
    return Ok(ContractStatusResult(id: id, status: ContractStatus.cancelled));
  }
}

void main() {
  const sampleContracts = [
    Contract(
      id: 'c1',
      code: 'CTR-2026-0001',
      customerId: 'cust1',
      customerName: 'Villa Sari Dewi',
      serviceId: 'srv1',
      serviceName: 'Termite Protection',
      categoryId: 'cat1',
      categoryName: 'Pest Control',
      status: ContractStatus.draft,
      startDate: '2026-09-01',
      contractValue: 5000000.0,
      paymentType: ContractPaymentType.full,
    ),
    Contract(
      id: 'c2',
      code: 'CTR-2026-0002',
      customerId: 'cust2',
      customerName: 'Hotel Surya Kuta',
      serviceId: 'srv2',
      serviceName: 'General Pest',
      categoryId: 'cat1',
      categoryName: 'Pest Control',
      status: ContractStatus.active,
      startDate: '2026-09-02',
      contractValue: 12000000.0,
      paymentType: ContractPaymentType.monthly,
    ),
    Contract(
      id: 'c3',
      code: 'CTR-2026-0003',
      customerId: 'cust3',
      customerName: 'Restoran Laut Biru',
      serviceId: 'srv3',
      serviceName: 'Rodent Control',
      categoryId: 'cat2',
      categoryName: 'Hygiene',
      status: ContractStatus.suspended,
      startDate: '2026-08-01',
      contractValue: 8000000.0,
      paymentType: ContractPaymentType.termin,
    ),
  ];

  late FakeContractRepository repo;
  late ContractController controller;

  setUp(() {
    repo = FakeContractRepository();
    repo.contracts = List.of(sampleContracts);
    controller = ContractController(repo);
  });

  tearDown(() {
    controller.dispose();
  });

  test('filteredContracts reacts to search query and status changes', () async {
    await controller.loadContracts();
    expect(controller.filteredContracts.value.length, 3);

    // Filter by status: Draft (1)
    controller.selectStatus(1);
    expect(controller.filteredContracts.value.length, 1);
    expect(controller.filteredContracts.value.first.id, 'c1');

    // Filter by status: Active (2)
    controller.selectStatus(2);
    expect(controller.filteredContracts.value.length, 1);
    expect(controller.filteredContracts.value.first.id, 'c2');

    // Reset status to null (Semua)
    controller.selectStatus(null);
    expect(controller.filteredContracts.value.length, 3);

    // Search query
    controller.setSearchQuery('Surya');
    expect(controller.filteredContracts.value.length, 1);
    expect(
      controller.filteredContracts.value.first.customerName,
      'Hotel Surya Kuta',
    );

    // Clear search
    controller.setSearchQuery('');
    expect(controller.filteredContracts.value.length, 3);
  });

  group('ContractController DataSync', () {
    late FakeContractRepository repo;
    late DataSyncService syncService;
    late ContractController controller;

    setUp(() {
      repo = FakeContractRepository();
      repo.contracts = List.of(sampleContracts);
      syncService = DataSyncServiceImpl();
      controller = ContractController(repo, syncService);
    });

    tearDown(() {
      controller.dispose();
      syncService.dispose();
    });

    test(
      'auto-refreshes contract list when ContractSyncEvent is received',
      () async {
        await controller.loadContracts();
        expect(
          (controller.contractsState.value as UiSuccess<List<Contract>>)
              .data
              .length,
          3,
        );

        // Add contract directly to repo
        repo.contracts.add(
          const Contract(
            id: 'c4',
            code: 'CTR-2026-0004',
            customerId: 'cust4',
            customerName: 'Ayam Betutu Khas Gilimanuk',
            serviceId: 'srv4',
            serviceName: 'Fly Control',
            categoryId: 'cat1',
            status: ContractStatus.draft,
            startDate: '2026-09-10',
          ),
        );

        // Emit ContractSyncEvent
        syncService.emit(
          const ContractSyncEvent('c4', action: SyncAction.created),
        );

        // Wait for async event stream
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(
          controller.contractsState.value,
          isA<UiSuccess<List<Contract>>>(),
        );
        final contracts =
            (controller.contractsState.value as UiSuccess<List<Contract>>).data;
        expect(contracts.length, 4);
        expect(contracts.any((c) => c.id == 'c4'), isTrue);
      },
    );

    test(
      'auto-refreshes selected contract detail when ContractSyncEvent matches selectedContractId',
      () async {
        await controller.loadContracts();
        await controller.selectContract('c1');
        expect(
          controller.selectedContract.value?.customerName,
          'Villa Sari Dewi',
        );

        // Update contract in repository
        final idx = repo.contracts.indexWhere((c) => c.id == 'c1');
        repo.contracts[idx] = repo.contracts[idx].copyWith(
          customerName: 'Villa Sari Dewi Updated',
        );

        // Emit ContractSyncEvent
        syncService.emit(
          const ContractSyncEvent('c1', action: SyncAction.updated),
        );

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(
          controller.selectedContract.value?.customerName,
          'Villa Sari Dewi Updated',
        );
      },
    );

    test(
      'does not refresh detail when ContractSyncEvent has different contractId',
      () async {
        await controller.loadContracts();
        await controller.selectContract('c1');

        // Update c2 in repository
        final idx = repo.contracts.indexWhere((c) => c.id == 'c2');
        repo.contracts[idx] = repo.contracts[idx].copyWith(
          customerName: 'Hotel Surya Kuta Updated',
        );

        syncService.emit(
          const ContractSyncEvent('c2', action: SyncAction.updated),
        );

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(controller.selectedContractId.value, 'c1');
        expect(
          controller.selectedContract.value?.customerName,
          'Villa Sari Dewi',
        );
      },
    );

    test(
      'cancels subscription and does not handle events after dispose',
      () async {
        await controller.loadContracts();
        controller.dispose();

        expect(
          () => syncService.emit(
            const ContractSyncEvent('c1', action: SyncAction.updated),
          ),
          returnsNormally,
        );
      },
    );
  });
}
