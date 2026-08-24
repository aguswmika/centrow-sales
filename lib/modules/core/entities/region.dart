class Province {
  final int id;
  final String name;

  const Province({required this.id, required this.name});

  Province copyWith({int? id, String? name}) {
    return Province(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Province && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Province(id: $id, name: $name)';
}

class Regency {
  final int id;
  final String name;

  const Regency({required this.id, required this.name});

  Regency copyWith({int? id, String? name}) {
    return Regency(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Regency && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Regency(id: $id, name: $name)';
}

class District {
  final int id;
  final String name;

  const District({required this.id, required this.name});

  District copyWith({int? id, String? name}) {
    return District(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is District && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'District(id: $id, name: $name)';
}

class Village {
  final int id;
  final String name;

  const Village({required this.id, required this.name});

  Village copyWith({int? id, String? name}) {
    return Village(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Village && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Village(id: $id, name: $name)';
}
