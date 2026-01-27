import 'package:flutter/material.dart';
import '../data/theme_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemePreferences _preferences = ThemePreferences();

  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = const Color(0xFF2563EB); // Modern Blue

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  // Color options
  static const Map<String, Map<String, dynamic>> colorOptions = {
    '#2563EB': {
      'name': 'Modern Blue',
      'description': 'Trust & Technology',
      'color': Color(0xFF2563EB),
    },
    '#22C55E': {
      'name': 'Success Green',
      'description': 'Growth & Success',
      'color': Color(0xFF22C55E),
    },
    '#7C3AED': {
      'name': 'Creative Purple',
      'description': 'Innovation & Premium',
      'color': Color(0xFF7C3AED),
    },
    '#111827': {
      'name': 'Charcoal Black',
      'description': 'Professional & Minimal',
      'color': Color(0xFF111827),
    },
    '#F97316': {
      'name': 'Action Orange',
      'description': 'Energy & Action',
      'color': Color(0xFFF97316),
    },
  };

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final themeMode = await _preferences.getThemeMode();
    final primaryColorHex = await _preferences.getPrimaryColor();

    _themeMode = _themeModeFromString(themeMode);
    _primaryColor = _colorFromHex(primaryColorHex);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = _themeModeFromString(mode);
    await _preferences.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setPrimaryColor(String colorHex) async {
    _primaryColor = _colorFromHex(colorHex);
    await _preferences.setPrimaryColor(colorHex);
    notifyListeners();
  }

  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String themeModeToString() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
        primary: _primaryColor,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE4E9F2),
      shadowColor: const Color(0xFF1A1F36),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1F36),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1A1F36)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1F36),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Color(0xFF1A1F36)),
        titleMedium: TextStyle(color: Color(0xFF1A1F36)),
        bodyLarge: TextStyle(color: Color(0xFF1A1F36)),
        bodyMedium: TextStyle(color: Color(0xFF1A1F36)),
        bodySmall: TextStyle(color: Color(0xFF8F9BB3)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
        primary: _primaryColor,
        surface: const Color(0xFF1E242C),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F1419),
      cardColor: const Color(0xFF1E242C),
      dividerColor: Colors.white12,
      shadowColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1F36),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
