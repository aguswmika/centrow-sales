import 'package:centrow_sales/modules/sales/entities/contract_template_option.dart';

class ContractCategory {
  final String id;
  final String name;
  final String? createdAt;
  final List<ContractTemplateOption> templates;

  const ContractCategory({
    required this.id,
    required this.name,
    this.createdAt,
    this.templates = const [],
  });

  @override
  String toString() => 'ContractCategory(id: $id, name: $name)';
}
