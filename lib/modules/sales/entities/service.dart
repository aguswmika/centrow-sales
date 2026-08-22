class Service {
  final String id;
  final String code;
  final String name;
  final bool isActive;

  const Service({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool,
    );
  }
}
