import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _firstTimeKey = 'is_first_time';
  static const String _themeKey = 'theme_mode'; // light, dark, system
  static const String _languageKey = 'language'; // en, ar

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool isFirstTime() {
    return _prefs.getBool(_firstTimeKey) ?? true;
  }

  Future<void> setNotFirstTime() async {
    await _prefs.setBool(_firstTimeKey, false);
  }

  Future<void> resetFirstTime() async {
    await _prefs.setBool(_firstTimeKey, true);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> setLanguage(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
