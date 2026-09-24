import 'package:centrow_sales/modules/sales/entities/contract_template_option.dart';

enum ContractScheduleCycle {
  yearly(1, 'Tahunan', 'tahun'),
  monthly(2, 'Bulanan', 'bulan');

  final int id;
  final String displayName;
  final String unitPeriod;

  const ContractScheduleCycle(this.id, this.displayName, this.unitPeriod);

  bool get isMonthly => this == ContractScheduleCycle.monthly;
  bool get isYearly => this == ContractScheduleCycle.yearly;

  static ContractScheduleCycle? fromDynamic(dynamic val) {
    if (val == null) return null;
    if (val is num) {
      if (val.toInt() == 2) return ContractScheduleCycle.monthly;
      if (val.toInt() == 1) return ContractScheduleCycle.yearly;
    }
    final s = val.toString().toLowerCase().trim();
    if (s == '2' || s == 'monthly' || s == 'bulanan') {
      return ContractScheduleCycle.monthly;
    }
    if (s == '1' || s == 'yearly' || s == 'tahunan') {
      return ContractScheduleCycle.yearly;
    }
    return null;
  }
}

class ContractCategory {
  final String id;
  final String name;
  final String? createdAt;
  final List<ContractTemplateOption> templates;
  final ContractScheduleCycle scheduleCycle;

  const ContractCategory({
    required this.id,
    required this.name,
    this.createdAt,
    this.templates = const [],
    this.scheduleCycle = ContractScheduleCycle.yearly,
  });

  @override
  String toString() =>
      'ContractCategory(id: $id, name: $name, scheduleCycle: $scheduleCycle)';
}
