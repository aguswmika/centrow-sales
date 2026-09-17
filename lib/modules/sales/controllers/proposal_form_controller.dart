import 'package:centrow_sales/modules/sales/entities/create_proposal_input.dart';
import 'package:centrow_sales/modules/sales/entities/update_proposal_input.dart';
import 'package:centrow_sales/modules/sales/entities/proposal.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_template_option.dart';
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
  bool _isReviseMode = false;
  bool get isReviseMode => _isReviseMode;

  List<CustomerLocation> availableLocations = [];

  List<ProposalTemplateOption> availableTemplates = [];
  String? templateId;
  bool isLoadingTemplates = false;

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

    addressId = proposal.addressId;
    proposalDate = proposal.date;
    if (proposal.validUntil.isNotEmpty) {
      validUntil = proposal.validUntil;
    }
    notes = proposal.notes;
    notifyListeners();
  }

  void initForRevise(Proposal proposal) {
    _isReviseMode = true;
    initForEdit(proposal);
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

  Future<void> _loadProposalTemplates(String serviceId) async {
    availableTemplates = [];
    templateId = null;
    isLoadingTemplates = true;
    notifyListeners();

    final result = await _serviceRepository.getSelectableProposalTemplates(
      serviceId,
    );
    if (result.isOk) {
      availableTemplates = result.valueOrNull ?? [];
      final defaultTemplate = availableTemplates
          .where((t) => t.isDefault)
          .cast<ProposalTemplateOption?>()
          .firstWhere((_) => true, orElse: () => null);
      templateId = defaultTemplate?.value;
    } else {
      availableTemplates = [];
      templateId = null;
    }
    isLoadingTemplates = false;
    notifyListeners();
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final result = await _customerRepository.getCustomers(query: query);
    return result.valueOrNull ?? [];
  }

  Future<List<Service>> searchServices(String query) async {
    final result = await _serviceRepository.getServices(query: query);
    return result.valueOrNull ?? [];
  }

  void selectTemplate(String? id) {
    templateId = id;
    notifyListeners();
  }

  Future<Result<Proposal>> submit() async {
    if (_customerId == null || serviceId == null || proposalDate == null) {
      return const Err(UnknownFailure('Field wajib harus diisi'));
    }

    if (isEditMode || isReviseMode) {
      final input = UpdateProposalInput(
        proposalDate: proposalDate!,
        validUntil: validUntil,
        addressId: addressId,
        notes: notes,
      );
      if (isReviseMode) {
        return await _proposalRepository.reviseProposal(_editId!, input);
      }
      return await _proposalRepository.updateProposal(_editId!, input);
    } else {
      if (templateId == null) {
        return const Err(UnknownFailure('Template proposal wajib dipilih.'));
      }
      final input = CreateProposalInput(
        customerId: _customerId!,
        serviceId: serviceId!,
        proposalDate: proposalDate!,
        proposalTemplateId: templateId!,
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
      _loadProposalTemplates(service.id);
    }
    this.proposalDate = proposalDate ?? this.proposalDate;
    this.validUntil = validUntil ?? this.validUntil;
    this.addressId = addressId ?? this.addressId;
    this.notes = notes ?? this.notes;
    notifyListeners();
  }
}
