class CreateProposalInput {
  final String customerId;
  final String serviceId;
  final String proposalDate;
  final String proposalTemplateId;
  final String? validUntil;
  final String? addressId;
  final String? notes;

  const CreateProposalInput({
    required this.customerId,
    required this.serviceId,
    required this.proposalDate,
    required this.proposalTemplateId,
    this.validUntil,
    this.addressId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'service_id': serviceId,
      'proposal_date': proposalDate,
      'proposal_template_id': proposalTemplateId,
      if (validUntil != null) 'valid_until': validUntil,
      if (addressId != null) 'address_id': addressId,
      'code': '',
      'notes': notes ?? '',
    };
  }
}
