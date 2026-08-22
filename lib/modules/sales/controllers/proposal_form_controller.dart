import 'package:centrow_sales/modules/sales/entities/create_proposal_input.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/entities/customer.dart';
import 'package:centrow_sales/modules/sales/entities/service.dart';
import 'package:centrow_sales/modules/sales/repositories/proposal_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/customer_repository.dart';
import 'package:centrow_sales/modules/sales/repositories/service_repository.dart';
import 'package:centrow_sales/shared/error/failure.dart';
import 'package:centrow_sales/shared/result/result.dart';
import 'package:flutter/foundation.dart';

class ProposalFormController extends ChangeNotifier {
  final ProposalRepository _proposalRepository;
  final CustomerRepository _customerRepository;
  final ServiceRepository _serviceRepository;

  String? _customerId;
  String? get customerId => _customerId;
  set customerId(String? val) {
    _customerId = val;
    _loadCustomerLocations();
  }

  String? serviceId;
  String? proposalDate;
  String? validUntil;
  String? addressId;

  List<CustomerLocation> availableLocations = [];

  ProposalFormController(
    this._proposalRepository,
    this._customerRepository,
    this._serviceRepository,
  );

  Future<void> _loadCustomerLocations() async {
    if (_customerId == null) {
      availableLocations = [];
      notifyListeners();
      return;
    }
    final result = await _customerRepository.getCustomerById(_customerId!);
    if (result.isOk) {
      availableLocations = result.valueOrNull!.locations;
      notifyListeners();
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final result = await _customerRepository.getCustomers(query: query);
    return result.valueOrNull ?? [];
  }

  Future<List<Service>> searchServices(String query) async {
    final result = await _serviceRepository.getServices(query: query);
    return result.valueOrNull ?? [];
  }

  Future<Result<Proposal>> submit() async {
    if (_customerId == null || serviceId == null || proposalDate == null) {
      return const Err(UnknownFailure('Field wajib harus diisi'));
    }

    final input = CreateProposalInput(
      customerId: _customerId!,
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
    if (customerId != null) {
      this.customerId = customerId; // triggers location load
    }
    this.serviceId = serviceId ?? this.serviceId;
    this.proposalDate = proposalDate ?? this.proposalDate;
    this.validUntil = validUntil ?? this.validUntil;
    this.addressId = addressId ?? this.addressId;
    notifyListeners();
  }
}
