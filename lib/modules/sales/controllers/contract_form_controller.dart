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
  int? totalVisits;
  double? contractValue;
  ContractPaymentType paymentType = ContractPaymentType.full;
  String? signatoryName;
  String? signatoryPosition;
  String? notes;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

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
    contractValue = prefilledValue;
    totalVisits = prefilledVisits;
    notifyListeners();
  }

  Future<List<ContractCategory>> searchCategories(String query) async {
    final result = await _categoryRepository.getContractCategories(
      query: query,
    );
    return result.valueOrNull ?? [];
  }

  void updateFields({
    ContractCategory? category,
    String? startDate,
    String? endDate,
    String? signedDate,
    String? firstInvoiceDate,
    int? totalVisits,
    double? contractValue,
    ContractPaymentType? paymentType,
    String? signatoryName,
    String? signatoryPosition,
    String? notes,
  }) {
    if (category != null) selectedCategory = category;
    if (startDate != null) this.startDate = startDate;
    if (endDate != null) this.endDate = endDate;
    if (signedDate != null) this.signedDate = signedDate;
    if (firstInvoiceDate != null) this.firstInvoiceDate = firstInvoiceDate;
    if (totalVisits != null) this.totalVisits = totalVisits;
    if (contractValue != null) this.contractValue = contractValue;
    if (paymentType != null) this.paymentType = paymentType;
    if (signatoryName != null) this.signatoryName = signatoryName;
    if (signatoryPosition != null) this.signatoryPosition = signatoryPosition;
    if (notes != null) this.notes = notes;
    notifyListeners();
  }

  Future<Result<Contract>> submit() async {
    if (proposalId == null) {
      return const Err(UnknownFailure('ID proposal tidak ada.'));
    }
    if (selectedCategory == null) {
      return const Err(UnknownFailure('Kategori kontrak wajib dipilih.'));
    }
    if (startDate == null || startDate!.isEmpty) {
      return const Err(UnknownFailure('Tanggal mulai wajib diisi.'));
    }

    _isSubmitting = true;
    notifyListeners();

    final input = CreateContractFromProposalInput(
      categoryId: selectedCategory!.id,
      signedDate: signedDate,
      startDate: startDate!,
      endDate: endDate,
      firstInvoiceDate: firstInvoiceDate,
      totalVisits: totalVisits,
      contractValue: contractValue,
      paymentTypeId: paymentType.id,
      signatoryName: (signatoryName != null && signatoryName!.isNotEmpty)
          ? signatoryName
          : null,
      signatoryPosition:
          (signatoryPosition != null && signatoryPosition!.isNotEmpty)
          ? signatoryPosition
          : null,
      notes: (notes != null && notes!.isNotEmpty) ? notes : null,
    );

    final result = await _contractRepository.createContractFromProposal(
      proposalId!,
      input,
    );

    _isSubmitting = false;
    notifyListeners();
    return result;
  }
}
