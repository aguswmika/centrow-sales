import 'package:centrow_sales/modules/sales/entities/create_proposal_input.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:flutter/foundation.dart';

class ProposalFormController extends ChangeNotifier {
  final ProposalRepository _proposalRepository;

  String? customerId;
  String? serviceId;
  String? proposalDate;
  String? validUntil;
  String? addressId;

  ProposalFormController(this._proposalRepository, {this.customerId});

  Future<Result<Proposal>> submit() async {
    if (customerId == null || serviceId == null || proposalDate == null) {
      return Err(Exception('Field wajib harus diisi'));
    }

    final input = CreateProposalInput(
      customerId: customerId!,
      serviceId: serviceId!,
      proposalDate: proposalDate!,
      validUntil: validUntil,
      addressId: addressId,
    );

    return await _proposalRepository.createProposal(input);
  }

  void updateFields({
    String? customerId,
    String? serviceId,
    String? proposalDate,
    String? validUntil,
    String? addressId,
  }) {
    this.customerId = customerId ?? this.customerId;
    this.serviceId = serviceId ?? this.serviceId;
    this.proposalDate = proposalDate ?? this.proposalDate;
    this.validUntil = validUntil ?? this.validUntil;
    this.addressId = addressId ?? this.addressId;
    notifyListeners();
  }
}
