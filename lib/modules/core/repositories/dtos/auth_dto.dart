import '../../entities/user.dart';

class AuthDto {
  final String id;
  final String name;
  final String email;
  final String role;
  final String branch;
  final String token;

  const AuthDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branch,
    required this.token,
  });

  factory AuthDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final user = (data['user'] as Map<String, dynamic>? ?? data);

    return AuthDto(
      id: user['id']?.toString() ?? '',
      name: user['name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      role: user['role']?.toString() ?? '',
      branch: user['branch']?.toString() ?? '',
      token: data['token']?.toString() ?? '',
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
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      branch: branch,
      token: token,
    );
  }
}
