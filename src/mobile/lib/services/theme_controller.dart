import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;

  void toggle(bool value) {
    if (_isDark != value) {
      _isDark = value;
      notifyListeners();
    }
  }
}

