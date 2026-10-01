class Product {
  final String id;
  final String code;
  final String name;
  final String uomId;
  final String uomCode;
  final String uomName;
  final double cogs;
  final bool isActive;
  final int? kind;

  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.uomId,
    required this.uomCode,
    this.uomName = '',
    required this.cogs,
    required this.isActive,
    this.kind,
  });

  String get uomDisplayName => uomName.isNotEmpty ? uomName : uomCode;
}
