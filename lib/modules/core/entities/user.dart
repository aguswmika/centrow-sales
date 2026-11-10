import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String branchId;
  final String name;
  final String email;
  final List<String> roles;
  final String position;
  final String department;
  final String token;
  final String refreshToken;
  final String branch;
  final String? _legacyRole;

  const User({
    required this.id,
    this.branchId = '',
    required this.name,
    required this.email,
    this.roles = const [],
    this.position = '',
    this.department = '',
    required this.token,
    this.refreshToken = '',
    String? role,
    this.branch = '',
  }) : _legacyRole = role;

  String get role => roles.isNotEmpty ? roles.first : (_legacyRole ?? '');

  String get initials => getInitials();

  String getInitials() {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  User copyWith({
    String? id,
    String? branchId,
    String? name,
    String? email,
    List<String>? roles,
    String? position,
    String? department,
    String? token,
    String? refreshToken,
    String? role,
    String? branch,
  }) {
    return User(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? (role != null ? [role] : this.roles),
      position: position ?? this.position,
      department: department ?? this.department,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      role: role ?? _legacyRole,
      branch: branch ?? this.branch,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, branchId: $branchId, name: $name, email: $email, roles: $roles, position: $position, department: $department, token: $token, refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.branchId == branchId &&
        other.name == name &&
        other.email == email &&
        listEquals(other.roles, roles) &&
        other.position == position &&
        other.department == department &&
        other.token == token &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      branchId,
      name,
      email,
      Object.hashAll(roles),
      position,
      department,
      token,
      refreshToken,
    );
  }
}
