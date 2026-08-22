class CreateProposalInput {
  final String customerId;
  final String serviceId;
  final String proposalDate;
  final String? validUntil;
  final String? addressId;

  const CreateProposalInput({
    required this.customerId,
    required this.serviceId,
    required this.proposalDate,
    this.validUntil,
    this.addressId,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'service_id': serviceId,
      'proposal_date': proposalDate,
      if (validUntil != null) 'valid_until': validUntil,
      if (addressId != null) 'address_id': addressId,
      'code': '',
      'total_amount': 0.0,
      'notes': '',
    };
  }
}
