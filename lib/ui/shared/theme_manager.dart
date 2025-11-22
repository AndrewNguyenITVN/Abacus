import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_constants.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ColorSelection _colorSelected = ColorSelection.teal;

  ThemeManager() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  ColorSelection get colorSelected => _colorSelected;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final colorIndex = prefs.getInt('colorIndex') ?? -1;

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    if (colorIndex >= 0 && colorIndex < ColorSelection.values.length) {
      _colorSelected = ColorSelection.values[colorIndex];
    } else {
      _colorSelected = ColorSelection.teal;
    }
    
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<void> changeColor(ColorSelection color) async {
    _colorSelected = color;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('colorIndex', color.index);
  }
}
