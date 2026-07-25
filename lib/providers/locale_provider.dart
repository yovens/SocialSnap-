import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🟢 Jere lang aplikasyon an (Fransè / Kreyòl Ayisyen) epi sonje chwa a
/// entre 2 sesyon (persistance ak SharedPreferences).
class LocaleProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_locale_code';

  /// Lang pa defo se Fransè.
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('ht'),
  ];

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefsKey);

    if (savedCode != null &&
        supportedLocales.any((l) => l.languageCode == savedCode)) {
      _locale = Locale(savedCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
