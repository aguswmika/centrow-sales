import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalStorage {
  Future<void> setString(String key, String value);
  String? getString(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPreferencesLocalStorage implements LocalStorage {
  final SharedPreferences _prefs;

  const SharedPreferencesLocalStorage(this._prefs);

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}
