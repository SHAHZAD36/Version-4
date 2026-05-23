import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, urdu }

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.urdu) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langIndex = prefs.getInt('app_lang_index') ?? 1;
    state = AppLanguage.values[langIndex];
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_lang_index', lang.index);
  }

  void toggleLanguage() {
    if (state == AppLanguage.urdu) {
      setLanguage(AppLanguage.english);
    } else {
      setLanguage(AppLanguage.urdu);
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});
