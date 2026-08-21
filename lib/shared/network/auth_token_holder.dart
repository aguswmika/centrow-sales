import 'dart:convert';
import '../../modules/core/entities/user.dart';
import '../../modules/core/repositories/dtos/auth_dto.dart';
import '../storage/local_storage.dart';

class AuthTokenHolder {
  AuthTokenHolder._();

  static final AuthTokenHolder instance = AuthTokenHolder._();

  static const String tokenStorageKey = 'auth_token';
  static const String refreshTokenStorageKey = 'auth_refresh_token';
  static const String userStorageKey = 'auth_user';

  LocalStorage? _storage;
  String? token;
  String? refreshToken;
  User? currentUser;
  void Function()? onSessionExpired;
  bool _isHandlingSessionExpired = false;

  User? get user => currentUser;
  set user(User? val) {
    currentUser = val;
    if (val != null) {
      saveUser(val);
    }
  }

  bool get hasToken => token != null && token!.trim().isNotEmpty;

  String getInitials() {
    if (currentUser != null) {
      return currentUser!.getInitials();
    }
    return '';
  }

  String get userInitials => getInitials();

  void initFromStorage(LocalStorage storage) {
    _storage = storage;
    token = storage.getString(tokenStorageKey);
    refreshToken = storage.getString(refreshTokenStorageKey);
    final userJson = storage.getString(userStorageKey);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(userJson) as Map<String, dynamic>;
        currentUser = AuthDto.fromJson(data).toEntity();
      } catch (_) {
        currentUser = null;
      }
    }
  }

  Future<void> saveToken(String newToken, {String? newRefreshToken}) async {
    token = newToken;
    if (newRefreshToken != null) {
      refreshToken = newRefreshToken;
    }
    if (_storage != null) {
      await _storage!.setString(tokenStorageKey, newToken);
      if (newRefreshToken != null) {
        await _storage!.setString(refreshTokenStorageKey, newRefreshToken);
      }
    }
  }

  Future<void> saveUser(User newUser) async {
    currentUser = newUser;
    if (_storage != null) {
      final map = {
        'id': newUser.id,
        'name': newUser.name,
        'email': newUser.email,
        'role': newUser.role,
        'branch': newUser.branch,
        'token': newUser.token,
        'refresh_token': newUser.refreshToken,
      };
      await _storage!.setString(userStorageKey, jsonEncode(map));
    }
  }

  Future<void> clear() async {
    token = null;
    refreshToken = null;
    currentUser = null;
    if (_storage != null) {
      await _storage!.remove(tokenStorageKey);
      await _storage!.remove(refreshTokenStorageKey);
      await _storage!.remove(userStorageKey);
    }
  }

  Future<void> handleSessionExpired() async {
    if (_isHandlingSessionExpired) {
      return;
    }
    if (!hasToken && currentUser == null) {
      return;
    }

    _isHandlingSessionExpired = true;
    try {
      await clear();
      onSessionExpired?.call();
    } finally {
      _isHandlingSessionExpired = false;
    }
  }
}
