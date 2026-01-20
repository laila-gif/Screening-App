import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  // _currentLocale adalah locale aktif yang digunakan oleh app
  Locale _currentLocale = const Locale('en', 'US'); // default

  // menyimpan kode pilihan user ('system','id','en','zh','ar')
  String _selectedLanguageCode = 'system';

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _selectedLanguageCode;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode == null || languageCode == 'system') {
      // Gunakan locale perangkat jika tidak ada pilihan
      _selectedLanguageCode = 'system';
      _currentLocale = WidgetsBinding.instance.platformDispatcher.locale;
    } else {
      _selectedLanguageCode = languageCode;
      if (languageCode == 'en') {
        _currentLocale = const Locale('en', 'US');
      } else if (languageCode == 'id') {
        _currentLocale = const Locale('id');
      } else if (languageCode == 'zh') {
        _currentLocale = const Locale('zh');
      } else if (languageCode == 'ar') {
        _currentLocale = const Locale('ar');
      } else {
        _currentLocale = WidgetsBinding.instance.platformDispatcher.locale;
      }
    }

    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);

    _selectedLanguageCode = languageCode;

    if (languageCode == 'system') {
      _currentLocale = WidgetsBinding.instance.platformDispatcher.locale;
    } else if (languageCode == 'en') {
      _currentLocale = const Locale('en', 'US');
    } else if (languageCode == 'id') {
      _currentLocale = const Locale('id');
    } else if (languageCode == 'zh') {
      _currentLocale = const Locale('zh');
    } else if (languageCode == 'ar') {
      _currentLocale = const Locale('ar');
    } else {
      _currentLocale = WidgetsBinding.instance.platformDispatcher.locale;
    }

    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'system':
        return 'Sistem (Perangkat)';
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
        return 'English';
      case 'zh':
        return 'Mandarin (中文)';
      case 'ar':
        return 'Arab (العربية)';
      default:
        return 'Sistem (Perangkat)';
    }
  }

  String getLanguageDisplayName(String code) {
    switch (code) {
      case 'system':
        return 'Sistem';
      case 'id':
        return 'Indonesia';
      case 'en':
        return 'English';
      case 'zh':
        return 'Mandarin';
      case 'ar':
        return 'Arab';
      default:
        return 'Sistem';
    }
  }
}
