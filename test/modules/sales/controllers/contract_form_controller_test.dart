import 'package:flutter_test/flutter_test.dart';
import 'package:centrow_sales/modules/sales/controllers/contract_form_controller.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/entities/contract_category.dart';
import 'package:centrow_sales/modules/sales/entities/contract_template_option.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_category_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';

class MockContractCategoryRepository implements ContractCategoryRepository {
  List<ContractCategory> categories = [];

  @override
  Future<Result<List<ContractCategory>>> getContractCategories({
    String? query,
  }) async {
    return Ok(categories);
  }
}

class MockContractRepository implements ContractRepository {
  ContractFormInput? lastCreateInput;
  String? lastCreateProposalId;
  ContractFormInput? lastUpdateInput;
  String? lastUpdateId;

  @override
  Future<Result<List<Contract>>> getContracts({
    String? query,
    int? status,
  }) async => const Ok([]);

  @override
  Future<Result<Contract>> getContractById(String id) async =>
      const Err(ServerFailure('Not implemented'));

  @override
  Future<Result<Contract>> createContractFromProposal(
    String proposalId,
    ContractFormInput input,
  ) async {
    lastCreateProposalId = proposalId;
    lastCreateInput = input;
    return Ok(
      Contract(
        id: 'ctr-created',
        code: 'CTR-2026-0001',
        customerId: 'cust-1',
        serviceId: 'srv-1',
        categoryId: input.categoryId,
        status: ContractStatus.draft,
        startDate: input.startDate,
        sourceProposalId: proposalId,
      ),
    );
  }

  @override
  Future<Result<ContractStatusResult>> updateContract(
    String id,
    ContractFormInput input,
  ) async {
    lastUpdateId = id;
    lastUpdateInput = input;
    return Ok(ContractStatusResult(id: id, status: ContractStatus.draft));
  }

  @override
  Future<Result<void>> deleteContract(String id) async => const Ok(null);

  @override
  Future<Result<ContractStatusResult>> activateContract(String id) async =>
      Ok(ContractStatusResult(id: id, status: ContractStatus.active));

  @override
  Future<Result<ContractStatusResult>> suspendContract(String id) async =>
      Ok(ContractStatusResult(id: id, status: ContractStatus.suspended));

  @override
  Future<Result<ContractStatusResult>> terminateContract(
    String id,
    String reason,
  ) async =>
      Ok(ContractStatusResult(id: id, status: ContractStatus.terminated));

  @override
  Future<Result<ContractStatusResult>> cancelContract(String id) async =>
      Ok(ContractStatusResult(id: id, status: ContractStatus.cancelled));
}

void main() {
  late MockContractCategoryRepository mockCategoryRepo;
  late MockContractRepository mockContractRepo;
  late ContractFormController controller;

  const testCategory = ContractCategory(
    id: 'cat-1',
    name: 'Pest Control',
    templates: [
      ContractTemplateOption(
        id: 'tmpl-1',
        label: 'Template 1',
        isDefault: true,
      ),
      ContractTemplateOption(
        id: 'tmpl-2',
        label: 'Template 2',
        isDefault: false,
      ),
    ],
  );

  setUp(() {
    mockCategoryRepo = MockContractCategoryRepository();
    mockContractRepo = MockContractRepository();
    mockCategoryRepo.categories = [testCategory];
    controller = ContractFormController(mockContractRepo, mockCategoryRepo);
  });

  tearDown(() {
    controller.dispose();
  });

  group('ContractFormController - Create Mode (from Proposal)', () {
    setUp(() {
      controller.initFromProposal(
        proposalId: 'prop-10',
        proposalCode: 'PROP-2026-0010',
        customerName: 'PT Maju Terus',
        serviceName: 'Termite Protection',
        prefilledValue: 10000000.0,
        prefilledVisits: 12,
      );
    });

    test('isEditMode is false in create mode', () {
      expect(controller.isEditMode, isFalse);
      expect(controller.proposalId, 'prop-10');
      expect(controller.proposalCode, 'PROP-2026-0010');
      expect(controller.contractId, isNull);
    });

    test('validates required fields in create mode', () async {
      // 1. Missing category
      var res = await controller.submit();
      expect(res.isErr, isTrue);
      expect(res.failureOrNull?.message, 'Kategori kontrak wajib dipilih.');

      // 2. Set category, missing startDate
      controller.updateFields(category: testCategory);
      res = await controller.submit();
      expect(res.isErr, isTrue);
      expect(res.failureOrNull?.message, 'Tanggal mulai wajib diisi.');

      // 3. Set startDate, missing signedDate
      controller.updateFields(startDate: '2026-01-01');
      res = await controller.submit();
      expect(res.isErr, isTrue);
      expect(
        res.failureOrNull?.message,
        'Tanggal penandatanganan wajib diisi.',
      );

      // 4. Set signedDate, missing notes
      controller.updateFields(signedDate: '2026-01-01');
      res = await controller.submit();
      expect(res.isErr, isTrue);
      expect(res.failureOrNull?.message, 'Catatan wajib diisi.');

      // 5. Set notes, template was auto-selected from default template
      controller.updateFields(notes: 'Catatan kontrak baru');
      // clear template to test validation
      controller.selectContractTemplate(null);
      res = await controller.submit();
      expect(res.isErr, isTrue);
      expect(res.failureOrNull?.message, 'Template kontrak wajib dipilih.');
    });

    test(
      'bypasses endDate validation in create mode even if endDate < startDate',
      () async {
        controller.updateFields(
          category: testCategory,
          startDate: '2026-06-01',
          endDate: '2026-01-01', // End date before start date
          signedDate: '2026-06-01',
          notes: 'Kontrak Baru',
        );
        controller.selectContractTemplate('tmpl-1');

        final res = await controller.submit();

        expect(res.isOk, isTrue);
        expect(mockContractRepo.lastCreateProposalId, 'prop-10');
        expect(mockContractRepo.lastCreateInput?.contractTemplateId, 'tmpl-1');
      },
    );

    test(
      'submits successfully in create mode with contractTemplateId',
      () async {
        controller.updateFields(
          category: testCategory,
          startDate: '2026-06-01',
          signedDate: '2026-06-01',
          notes: 'Catatan pengujian',
        );
        controller.selectContractTemplate('tmpl-2');

        final res = await controller.submit();

        expect(res.isOk, isTrue);
        expect(mockContractRepo.lastCreateProposalId, 'prop-10');
        expect(mockContractRepo.lastCreateInput?.contractTemplateId, 'tmpl-2');
        expect(mockContractRepo.lastCreateInput?.categoryId, 'cat-1');
      },
    );
  });

  group('ContractFormController - Edit Mode (Existing Contract)', () {
    const existingContract = Contract(
      id: 'ctr-50',
      code: 'CTR-2026-0050',
      customerId: 'cust-1',
      customerName: 'PT Maju Terus',
      serviceId: 'srv-1',
      serviceName: 'Termite Protection',
      categoryId: 'cat-1',
      categoryName: 'Pest Control',
      status: ContractStatus.draft,
      startDate: '2026-01-01',
      endDate: '2026-12-31',
      signedDate: '2026-01-01',
      notes: 'Catatan awal',
    );

    setUp(() {
      controller.initFromContract(existingContract);
    });

    test('isEditMode is true in edit mode', () {
      expect(controller.isEditMode, isTrue);
      expect(controller.contractId, 'ctr-50');
    });

    test(
      'does not require contractTemplateId in edit mode and passes null template',
      () async {
        controller.selectContractTemplate(null);

        final res = await controller.submit();

        expect(res.isOk, isTrue);
        expect(mockContractRepo.lastUpdateId, 'ctr-50');
        expect(mockContractRepo.lastUpdateInput?.contractTemplateId, isNull);
      },
    );

    test(
      'validates endDate against startDate in edit mode when provided',
      () async {
        // Set endDate before startDate
        controller.updateFields(startDate: '2026-06-01', endDate: '2026-05-01');

        final res = await controller.submit();

        expect(res.isErr, isTrue);
        expect(
          res.failureOrNull?.message,
          'Tanggal akhir tidak boleh sebelum tanggal mulai.',
        );
      },
    );

    test('allows null endDate in edit mode', () async {
      controller.updateFields(startDate: '2026-06-01', endDate: '');

      final res = await controller.submit();

      expect(res.isOk, isTrue);
      expect(mockContractRepo.lastUpdateId, 'ctr-50');
    });

    test('submits successfully in edit mode with valid endDate', () async {
      controller.updateFields(startDate: '2026-06-01', endDate: '2026-12-01');

      final res = await controller.submit();

      expect(res.isOk, isTrue);
      expect(mockContractRepo.lastUpdateId, 'ctr-50');
      expect(mockContractRepo.lastUpdateInput?.endDate, '2026-12-01');
      expect(mockContractRepo.lastUpdateInput?.contractTemplateId, isNull);
    });
  });
}
