class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String branch;
  final String token;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branch,
    required this.token,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? branch,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      branch: branch ?? this.branch,
      token: token ?? this.token,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, branch: $branch, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.branch == branch &&
        other.token == token;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, role, branch, token);
  }
}
