class Branch {
  final String id;
  final String name;
  final String slug;

  const Branch({required this.id, required this.name, required this.slug});

  Branch copyWith({String? id, String? name, String? slug}) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Branch &&
        other.id == id &&
        other.name == name &&
        other.slug == slug;
  }

  @override
  int get hashCode => Object.hash(id, name, slug);

  @override
  String toString() => 'Branch(id: $id, name: $name, slug: $slug)';
}
