import 'package:flutter/material.dart';

class LanguageController extends ChangeNotifier {
  Locale _locale = const Locale('vi');
  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
  }

  void toggle() {
    final isVi = _locale.languageCode.toLowerCase().startsWith('vi');
    setLocale(isVi ? const Locale('en') : const Locale('vi'));
  }

  void toggleLanguage() {
    toggle();
  }
}
