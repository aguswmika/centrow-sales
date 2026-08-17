class Tenant {
  final String id;
  final String name;
  final String slug;

  const Tenant({required this.id, required this.name, required this.slug});

  Tenant copyWith({String? id, String? name, String? slug}) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tenant &&
        other.id == id &&
        other.name == name &&
        other.slug == slug;
  }

  @override
  int get hashCode => Object.hash(id, name, slug);

  @override
  String toString() => 'Tenant(id: $id, name: $name, slug: $slug)';
}
