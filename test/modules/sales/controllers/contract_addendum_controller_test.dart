import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/shared/state/ui_state.dart';
import 'package:centrow_sales/modules/sales/entities/contract_addendum.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_addendum_controller.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_addendum_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/contract_addendum_dto.dart';
import 'package:centrow_sales/modules/sales/repositories/dtos/pricing_dto.dart';

class MockContractAddendumRepository implements ContractAddendumRepository {
  Result<List<ContractAddendum>> getAddendumsResult = const Ok([]);
  Result<ContractAddendum>? createAddendumResult;

  String? lastGetContractId;
  String? lastCreateContractId;
  CreateContractAddendumRequestDto? lastCreateRequest;

  @override
  Future<Result<List<ContractAddendum>>> getAddendums(String contractId) async {
    lastGetContractId = contractId;
    return getAddendumsResult;
  }

  @override
  Future<Result<ContractAddendum>> createAddendum(
    String contractId,
    CreateContractAddendumRequestDto request,
  ) async {
    lastCreateContractId = contractId;
    lastCreateRequest = request;
    return createAddendumResult ??
        Ok(
          ContractAddendum(
            id: 'mock-id',
            contractId: contractId,
            visitDelta: request.totalVisits - 10,
            oldTotalVisits: 10,
            newTotalVisits: request.totalVisits,
            oldContractValue: 10000000.0,
            newContractValue: 11000000.0,
            reason: request.reason,
          ),
        );
  }
}

void main() {
  late MockContractAddendumRepository mockRepo;
  late ContractAddendumController controller;

  setUp(() {
    mockRepo = MockContractAddendumRepository();
    controller = ContractAddendumController(mockRepo);
  });

  tearDown(() {
    controller.dispose();
  });

  group('ContractAddendumController', () {
    test('initial state is UiInitial', () {
      expect(
        controller.addendumsState.value,
        isA<UiInitial<List<ContractAddendum>>>(),
      );
      expect(controller.createState.value, isA<UiInitial<ContractAddendum>>());
    });

    test('loadAddendums emits UiSuccess on repository success', () async {
      const sample = ContractAddendum(
        id: 'add-1',
        contractId: 'ctr-1',
        visitDelta: 2,
        oldTotalVisits: 10,
        newTotalVisits: 12,
        oldContractValue: 10000000.0,
        newContractValue: 12000000.0,
      );
      mockRepo.getAddendumsResult = const Ok([sample]);

      await controller.loadAddendums('ctr-1');

      expect(mockRepo.lastGetContractId, 'ctr-1');
      expect(
        controller.addendumsState.value,
        isA<UiSuccess<List<ContractAddendum>>>(),
      );
      final data =
          (controller.addendumsState.value as UiSuccess<List<ContractAddendum>>)
              .data;
      expect(data.length, 1);
      expect(data.first.id, 'add-1');
    });

    test('loadAddendums emits UiFailure on repository error', () async {
      mockRepo.getAddendumsResult = const Err(
        ServerFailure('Gagal memuat addendum', 500),
      );

      await controller.loadAddendums('ctr-1');

      expect(
        controller.addendumsState.value,
        isA<UiFailure<List<ContractAddendum>>>(),
      );
      final failure =
          (controller.addendumsState.value as UiFailure<List<ContractAddendum>>)
              .failure;
      expect(failure.message, 'Gagal memuat addendum');
    });

    const sampleRequest = CreateContractAddendumRequestDto(
      contractMonths: 12,
      visitFrequency: 2,
      totalVisits: 24,
      markupType: 1,
      markupValue: 10.0,
      discountAmount: 0.0,
      taxPercentage: 11.0,
      supplies: [],
      workers: [],
      items: [],
      reason: 'Penambahan gedung',
    );

    test(
      'createAddendum emits UiSuccess on successful addendum submission',
      () async {
        final res = await controller.createAddendum('ctr-1', sampleRequest);

        expect(mockRepo.lastCreateContractId, 'ctr-1');
        expect(mockRepo.lastCreateRequest, sampleRequest);
        expect(mockRepo.lastCreateRequest?.totalVisits, 24);
        expect(mockRepo.lastCreateRequest?.reason, 'Penambahan gedung');
        expect(res, isA<Ok<ContractAddendum>>());
        expect(
          controller.createState.value,
          isA<UiSuccess<ContractAddendum>>(),
        );
      },
    );

    test('createAddendum emits UiFailure on error', () async {
      mockRepo.createAddendumResult = const Err(ServerFailure('Conflict', 409));

      final res = await controller.createAddendum('ctr-1', sampleRequest);

      expect(res, isA<Err<ContractAddendum>>());
      expect(controller.createState.value, isA<UiFailure<ContractAddendum>>());
      expect(
        (controller.createState.value as UiFailure).failure.message,
        'Conflict',
      );

      controller.resetCreateState();
      expect(controller.createState.value, isA<UiInitial<ContractAddendum>>());
    });

    test(
      'CreateContractAddendumRequestDto.fromPricingRequest copies fields and sets reason',
      () {
        const pricing = CreatePricingRequestDto(
          contractMonths: 6,
          visitFrequency: 1,
          totalVisits: 6,
          markupType: 1,
          markupValue: 5.0,
          discountAmount: 10000.0,
          taxPercentage: 11.0,
          supplies: [],
          workers: [],
          items: [],
        );

        final req = CreateContractAddendumRequestDto.fromPricingRequest(
          pricing,
          reason: 'Alasan penyesuaian',
        );

        expect(req.contractMonths, 6);
        expect(req.visitFrequency, 1);
        expect(req.totalVisits, 6);
        expect(req.reason, 'Alasan penyesuaian');
        final json = req.toJson();
        expect(json['contract_months'], 6);
        expect(json['reason'], 'Alasan penyesuaian');
      },
    );
  });
}
