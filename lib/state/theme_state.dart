import 'package:flutter/material.dart';
class ThemeState extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeState({ThemeMode initialMode = ThemeMode.system})
    : _themeMode = initialMode;

  ThemeMode get themeMode => _themeMode;

  bool isDark(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme(BuildContext context) {
    if (isDark(context)) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
