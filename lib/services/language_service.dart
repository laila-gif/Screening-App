import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('en', 'US'); // Default ke en_US untuk kompatibilitas

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      if (languageCode == 'en') {
        _currentLocale = const Locale('en', 'US');
      } else {
        // Gunakan 'id' saja tanpa country code untuk kompatibilitas
        // Flutter akan fallback ke en_US melalui localeResolutionCallback
        _currentLocale = const Locale('id');
      }
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    if (languageCode == 'en') {
      _currentLocale = const Locale('en', 'US');
    } else {
      // Gunakan 'id' saja tanpa country code untuk kompatibilitas
      _currentLocale = const Locale('id');
    }
    
    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
        return 'English';
      default:
        return 'Bahasa Indonesia';
    }
  }

  String getLanguageDisplayName(String code) {
    switch (code) {
      case 'id':
        return 'Indonesia';
      case 'en':
        return 'English';
      default:
        return 'Indonesia';
    }
  }
}

