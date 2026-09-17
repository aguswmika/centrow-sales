import 'package:flutter/foundation.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:centrow_sales/modules/sales/entities/contract.dart';
import 'package:centrow_sales/modules/sales/entities/contract_category.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/contract_category_repository.dart';

class ContractFormController extends ChangeNotifier {
  final ContractRepository _contractRepository;
  final ContractCategoryRepository _categoryRepository;

  ContractFormController(this._contractRepository, this._categoryRepository);

  String? contractId;
  String? proposalId;
  String? proposalCode;
  String? prefilledCustomerName;
  String? prefilledServiceName;
  double? prefillContractValue;
  int? prefillTotalVisits;

  ContractCategory? selectedCategory;
  String? startDate;
  String? endDate;
  String? signedDate;
  String? firstInvoiceDate;
  ContractPaymentType paymentType = ContractPaymentType.full;
  String? notes;

  String? contractTemplateId;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;
  bool get isEditMode => contractId != null;

  void initFromProposal({
    required String proposalId,
    required String proposalCode,
    required String customerName,
    required String serviceName,
    double? prefilledValue,
    int? prefilledVisits,
  }) {
    this.proposalId = proposalId;
    this.proposalCode = proposalCode;
    prefilledCustomerName = customerName;
    prefilledServiceName = serviceName;
    prefillContractValue = prefilledValue;
    prefillTotalVisits = prefilledVisits;
    contractId = null;
    notifyListeners();
  }

  void initFromContract(Contract contract) {
    contractId = contract.id;
    proposalCode = contract.sourceProposalCode;
    prefilledCustomerName = contract.customerName;
    prefilledServiceName = contract.serviceName;
    selectedCategory = ContractCategory(
      id: contract.categoryId,
      name: contract.categoryName,
    );
    startDate = contract.startDate;
    endDate = contract.endDate;
    firstInvoiceDate = contract.firstInvoiceDate;
    signedDate = contract.signedDate;
    paymentType = contract.paymentType;
    notes = contract.notes;
    notifyListeners();
  }

  Future<List<ContractCategory>> searchCategories(String query) async {
    final result = await _categoryRepository.getContractCategories(
      query: query,
    );
    return result.valueOrNull ?? [];
  }

  void selectContractTemplate(String? id) {
    contractTemplateId = id;
    notifyListeners();
  }

  void updateFields({
    ContractCategory? category,
    String? startDate,
    String? endDate,
    String? signedDate,
    String? firstInvoiceDate,
    ContractPaymentType? paymentType,
    String? notes,
  }) {
    if (category != null) {
      selectedCategory = category;
      final matches = category.templates.where((t) => t.isDefault);
      contractTemplateId = matches.isEmpty ? null : matches.first.id;
    }
    if (startDate != null) this.startDate = startDate;
    if (endDate != null) this.endDate = endDate;
    if (signedDate != null) this.signedDate = signedDate;
    if (firstInvoiceDate != null) this.firstInvoiceDate = firstInvoiceDate;
    if (paymentType != null) this.paymentType = paymentType;
    if (notes != null) this.notes = notes;
    notifyListeners();
  }

  Future<Result<Contract>> submit() async {
    if (!isEditMode && proposalId == null) {
      return const Err(UnknownFailure('ID proposal tidak ada.'));
    }
    if (selectedCategory == null) {
      return const Err(UnknownFailure('Kategori kontrak wajib dipilih.'));
    }
    if (startDate == null || startDate!.isEmpty) {
      return const Err(UnknownFailure('Tanggal mulai wajib diisi.'));
    }
    if (signedDate == null || signedDate!.isEmpty) {
      return const Err(UnknownFailure('Tanggal penandatanganan wajib diisi.'));
    }
    if (notes == null || notes!.trim().isEmpty) {
      return const Err(UnknownFailure('Catatan wajib diisi.'));
    }
    if (endDate != null &&
        endDate!.isNotEmpty &&
        startDate!.compareTo(endDate!) > 0) {
      return const Err(
        UnknownFailure('Tanggal akhir tidak boleh sebelum tanggal mulai.'),
      );
    }
    if (!isEditMode && contractTemplateId == null) {
      return const Err(UnknownFailure('Template kontrak wajib dipilih.'));
    }

    _isSubmitting = true;
    notifyListeners();

    final input = ContractFormInput(
      categoryId: selectedCategory!.id,
      startDate: startDate!,
      endDate: endDate,
      firstInvoiceDate: firstInvoiceDate,
      signedDate: signedDate!,
      paymentTypeId: paymentType.id,
      notes: notes!.trim(),
      contractTemplateId: isEditMode ? null : contractTemplateId,
    );

    if (isEditMode) {
      final result = await _contractRepository.updateContract(
        contractId!,
        input,
      );
      _isSubmitting = false;
      notifyListeners();
      return switch (result) {
        Ok() => Ok(
          Contract(
            id: contractId!,
            code: '',
            customerId: '',
            serviceId: '',
            categoryId: selectedCategory!.id,
            status: ContractStatus.draft,
            startDate: startDate!,
          ),
        ),
        Err(:final failure) => Err(failure),
      };
    }

    final result = await _contractRepository.createContractFromProposal(
      proposalId!,
      input,
    );

    _isSubmitting = false;
    notifyListeners();
    return result;
  }
}
