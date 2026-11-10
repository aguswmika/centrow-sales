class LoginRequestDto {
  final String email;
  final String password;
  final String branchId;

  const LoginRequestDto({
    required this.email,
    required this.password,
    required this.branchId,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'branch_id': branchId};
  }
}
