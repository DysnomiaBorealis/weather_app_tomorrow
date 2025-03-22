import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  AppSession(this._prefs);

  final SharedPreferences _prefs;
  static const _cityNameKey = 'cityName';
  static const _cityIdKey = 'cityId';

  String? get cityName => _prefs.getString(_cityNameKey) ?? '';

  Future<bool>saveCityName(String cityName) => _prefs.setString(_cityNameKey, cityName);

}