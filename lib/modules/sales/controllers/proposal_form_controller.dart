import 'package:centrow_sales/modules/sales/entities/create_proposal_input.dart';
import 'package:centrow_sales/modules/sales/entities/update_proposal_input.dart';
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

  Customer? selectedCustomer;
  Service? selectedService;

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
  String? notes;
  String? _editId;
  bool get isEditMode => _editId != null;

  List<CustomerLocation> availableLocations = [];

  ProposalFormController(
    this._proposalRepository,
    this._customerRepository,
    this._serviceRepository,
  );

  void initForEdit(Proposal proposal) {
    _editId = proposal.id;
    // Provide a dummy customer/service to display in the searchable selector
    selectedCustomer = Customer(
      id: proposal.customerId,
      name: proposal.clientName,
      code: '',
      initials: '',
      segment: '',
      status: '',
      locations: [],
    );
    customerId = proposal.customerId; // this triggers location load
    selectedService = Service(
      id: proposal.serviceId,
      name: proposal.serviceName,
      code: '',
      isActive: true,
    );
    serviceId = proposal.serviceId;

    // Replace the old comment and assign addressId:
    addressId = proposal.addressId;

    // Convert readable dates to YYYY-MM-DD for the form input if needed,
    // but assuming standard format is passed or we just leave it for re-selection
    // if the formats don't match easily. We will populate notes:
    notes = proposal.notes;
    notifyListeners();
  }

  Future<void> _loadCustomerLocations() async {
    if (_customerId == null) {
      availableLocations = [];
      notifyListeners();
      return;
    }
    final result = await _customerRepository.getCustomerById(_customerId!);
    if (result.isOk) {
      selectedCustomer = result.valueOrNull;
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

    if (isEditMode) {
      final input = UpdateProposalInput(
        customerId: _customerId!,
        serviceId: serviceId!,
        proposalDate: proposalDate!,
        validUntil: validUntil,
        addressId: addressId,
        notes: notes,
      );
      return await _proposalRepository.updateProposal(_editId!, input);
    } else {
      final input = CreateProposalInput(
        customerId: _customerId!,
        serviceId: serviceId!,
        proposalDate: proposalDate!,
        validUntil: validUntil,
        addressId: addressId,
        notes: notes,
      );
      return await _proposalRepository.createProposal(input);
    }
  }

  void updateFields({
    Customer? customer,
    Service? service,
    String? proposalDate,
    String? validUntil,
    String? addressId,
    String? notes,
  }) {
    if (customer != null) {
      selectedCustomer = customer;
      customerId = customer.id; // triggers location load
    }
    if (service != null) {
      selectedService = service;
      serviceId = service.id;
    }
    this.proposalDate = proposalDate ?? this.proposalDate;
    this.validUntil = validUntil ?? this.validUntil;
    this.addressId = addressId ?? this.addressId;
    this.notes = notes ?? this.notes;
    notifyListeners();
  }
}
