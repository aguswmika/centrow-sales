class ContractCategory {
  final String id;
  final String name;
  final String? contractTemplateId;
  final String? createdAt;

  const ContractCategory({
    required this.id,
    required this.name,
    this.contractTemplateId,
    this.createdAt,
  });

  @override
  String toString() => 'ContractCategory(id: $id, name: $name)';
}
