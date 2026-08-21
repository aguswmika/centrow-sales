import 'package:flutter/foundation.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';

class UserMeDto {
  final String id;
  final String tenantId;
  final String name;
  final String email;
  final List<String> roles;
  final String position;
  final String department;

  const UserMeDto({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.email,
    this.roles = const [],
    this.position = '',
    this.department = '',
  });

  factory UserMeDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final rolesList = data['roles'];
    final List<String> parsedRoles;
    if (rolesList is List) {
      parsedRoles = rolesList.map((e) => e.toString()).toList();
    } else {
      parsedRoles = const [];
    }

    return UserMeDto(
      id: data['id']?.toString() ?? '',
      tenantId: data['tenant_id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      roles: parsedRoles,
      position: data['position']?.toString() ?? '',
      department: data['department']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'email': email,
      'roles': roles,
      'position': position,
      'department': department,
    };
  }

  User toEntity([String token = '']) {
    return User(
      id: id,
      tenantId: tenantId,
      name: name,
      email: email,
      roles: roles,
      position: position,
      department: department,
      token: token,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserMeDto &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.name == name &&
        other.email == email &&
        listEquals(other.roles, roles) &&
        other.position == position &&
        other.department == department;
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
    );
  }

  @override
  String toString() {
    return 'UserMeDto(id: $id, tenantId: $tenantId, name: $name, email: $email, roles: $roles, position: $position, department: $department)';
  }
}
