class TreatmentMethod {
  final String id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;

  const TreatmentMethod({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.isActive = true,
  });

  TreatmentMethod copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return TreatmentMethod(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreatmentMethod &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          name == other.name &&
          description == other.description &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(id, code, name, description, isActive);

  @override
  String toString() =>
      'TreatmentMethod(id: $id, code: $code, name: $name, description: $description, isActive: $isActive)';
}
