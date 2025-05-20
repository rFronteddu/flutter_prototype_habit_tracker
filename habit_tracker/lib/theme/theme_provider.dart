import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/dark_mode.dart';
import 'package:habit_tracker/theme/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  // init in dark mode
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isDark => _themeData.brightness == Brightness.dark;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    _themeData = isDark ? lightMode : darkMode;
    notifyListeners();
  }
}