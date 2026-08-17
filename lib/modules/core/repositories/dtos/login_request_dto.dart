class LoginRequestDto {
  final String email;
  final String password;
  final String tenantId;

  const LoginRequestDto({
    required this.email,
    required this.password,
    required this.tenantId,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'tenant_id': tenantId};
  }
}
