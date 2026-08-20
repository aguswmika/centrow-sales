import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String tenantId;
  final String name;
  final String email;
  final List<String> roles;
  final String position;
  final String department;
  final String token;
  final String branch;
  final String? _legacyRole;

  const User({
    required this.id,
    this.tenantId = '',
    required this.name,
    required this.email,
    this.roles = const [],
    this.position = '',
    this.department = '',
    required this.token,
    String? role,
    this.branch = '',
  }) : _legacyRole = role;

  String get role => roles.isNotEmpty ? roles.first : (_legacyRole ?? '');

  String get initials => getInitials();

  String getInitials() {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts =
        trimmed.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  User copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? email,
    List<String>? roles,
    String? position,
    String? department,
    String? token,
    String? role,
    String? branch,
  }) {
    return User(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? (role != null ? [role] : this.roles),
      position: position ?? this.position,
      department: department ?? this.department,
      token: token ?? this.token,
      role: role ?? _legacyRole,
      branch: branch ?? this.branch,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, tenantId: $tenantId, name: $name, email: $email, roles: $roles, position: $position, department: $department, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.name == name &&
        other.email == email &&
        listEquals(other.roles, roles) &&
        other.position == position &&
        other.department == department &&
        other.token == token;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      tenantId,
      name,
      email,
      Object.hashAll(roles),
      position,
      department,
      token,
    );
  }
}
