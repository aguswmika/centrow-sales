class TokenDto {
  final String token;
  final String refreshToken;
  final int expiresIn;

  const TokenDto({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return TokenDto(
      token: data['token']?.toString() ?? '',
      refreshToken: data['refresh_token']?.toString() ?? '',
      expiresIn: (data['expiresIn'] as num?)?.toInt() ?? 0,
    );
  }
}
