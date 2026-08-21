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
}
