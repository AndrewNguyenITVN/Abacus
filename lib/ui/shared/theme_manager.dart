import 'package:flutter/material.dart';
import 'theme_constants.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ColorSelection _colorSelected = ColorSelection.teal;

  ThemeMode get themeMode => _themeMode;
  ColorSelection get colorSelected => _colorSelected;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void changeColor(ColorSelection color) {
    _colorSelected = color;
    notifyListeners();
  }
}

