import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const String _themeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';

  // Default values
  static const String defaultThemeMode = 'system';
  static const String defaultPrimaryColor = '#2563EB'; // Modern Blue

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? defaultThemeMode;
  }

  Future<void> setPrimaryColor(String colorHex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_primaryColorKey, colorHex);
  }

  Future<String> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_primaryColorKey) ?? defaultPrimaryColor;
  }
}
