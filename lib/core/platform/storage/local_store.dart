import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalStore {
  Future<void> setString(String key, String value);
  String? getString(String key);
}

class SharedPreferencesLocalStore implements LocalStore {
  const SharedPreferencesLocalStore(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  @override
  String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }
}
