import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  final SharedPreferences _prefs;

  Locale _currentLocale = const Locale('vi'); // Default to Vietnamese

  LocaleService(this._prefs) {
    _loadSavedLocale();
  }

  Locale get currentLocale => _currentLocale;

  List<Locale> get supportedLocales => const [
        Locale('vi'), // Vietnamese
        Locale('en'), // English
      ];

  Future<void> _loadSavedLocale() async {
    final savedLocaleCode = _prefs.getString(_localeKey);
    if (savedLocaleCode != null) {
      _currentLocale = Locale(savedLocaleCode);
      notifyListeners();
    }
  }

  Future<void> changeLocale(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    await changeLocale(Locale(languageCode));
  }

  String get currentLanguageCode => _currentLocale.languageCode;

  String get currentLanguageName {
    switch (_currentLocale.languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return 'Tiếng Việt';
    }
  }
}
