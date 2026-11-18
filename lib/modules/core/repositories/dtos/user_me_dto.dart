import 'package:flutter/foundation.dart';
import 'package:centrow_sales/modules/core/entities/user.dart';

class UserMeDto {
  final String id;
  final String branchId;
  final String name;
  final String email;
  final List<String> roles;
  final String position;
  final String department;
  final String branchName;
  final String companyId;
  final String companyName;

  const UserMeDto({
    required this.id,
    required this.branchId,
    required this.name,
    required this.email,
    this.roles = const [],
    this.position = '',
    this.department = '',
    this.branchName = '',
    this.companyId = '',
    this.companyName = '',
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

    final branchObj = data['branch'] is Map ? data['branch'] as Map : null;
    final companyObj = data['company'] is Map ? data['company'] as Map : null;

    return UserMeDto(
      id: data['id']?.toString() ?? '',
      branchId:
          (branchObj?['id'] ?? data['branch_id'] ?? data['tenant_id'])
              ?.toString() ??
          '',
      branchName: branchObj?['name']?.toString() ?? '',
      companyId: companyObj?['id']?.toString() ?? '',
      companyName: companyObj?['name']?.toString() ?? '',
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
      'branch_id': branchId,
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
      branchId: branchId,
      name: name,
      email: email,
      roles: roles,
      position: position,
      department: department,
      branchName: branchName,
      companyId: companyId,
      companyName: companyName,
      token: token,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserMeDto &&
        other.id == id &&
        other.branchId == branchId &&
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
      branchId,
      name,
      email,
      Object.hashAll(roles),
      position,
      department,
    );
  }

  @override
  String toString() {
    return 'UserMeDto(id: $id, branchId: $branchId, name: $name, email: $email, roles: $roles, position: $position, department: $department)';
  }
}
