class AuthTokenHolder {
  AuthTokenHolder._();

  static final AuthTokenHolder instance = AuthTokenHolder._();

  String? token;

  bool get hasToken => token != null && token!.trim().isNotEmpty;

  void clear() {
    token = null;
  }
}
