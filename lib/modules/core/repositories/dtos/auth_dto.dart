import 'package:centrow_sales/modules/core/entities/user.dart';

class AuthDto {
  final String id;
  final String name;
  final String email;
  final String role;
  final String branch;
  final String token;
  final String refreshToken;
  final String branchId;
  final String branchName;
  final String companyId;
  final String companyName;

  const AuthDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branch,
    required this.token,
    required this.refreshToken,
    this.branchId = '',
    this.branchName = '',
    this.companyId = '',
    this.companyName = '',
  });

  factory AuthDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final user = (data['user'] as Map<String, dynamic>? ?? data);

    final branchObj = data['branch'] is Map
        ? data['branch'] as Map
        : (user['branch'] is Map ? user['branch'] as Map : null);
    final companyObj = data['company'] is Map
        ? data['company'] as Map
        : (user['company'] is Map ? user['company'] as Map : null);

    return AuthDto(
      id: user['id']?.toString() ?? '',
      name: user['name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      role: user['role']?.toString() ?? '',
      branch: user['branch'] is String ? user['branch'] as String : '',
      token: data['token']?.toString() ?? '',
      refreshToken: data['refresh_token']?.toString() ?? '',
      branchId: (branchObj?['id'] ?? data['branch_id'])?.toString() ?? '',
      branchName: (branchObj?['name'] ?? data['branch_name'])?.toString() ?? '',
      companyId: (companyObj?['id'] ?? data['company_id'])?.toString() ?? '',
      companyName:
          (companyObj?['name'] ?? data['company_name'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'branch': branch,
      'token': token,
      'refresh_token': refreshToken,
      'branch_id': branchId,
      'branch_name': branchName,
      'company_id': companyId,
      'company_name': companyName,
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      roles: role.isNotEmpty ? [role] : const [],
      branch: branch,
      branchId: branchId,
      branchName: branchName,
      companyId: companyId,
      companyName: companyName,
      token: token,
      refreshToken: refreshToken,
    );
  }
}
