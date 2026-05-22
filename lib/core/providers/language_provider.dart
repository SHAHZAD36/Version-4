import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { english, urdu }

class LanguageNotifier extends StateNotifier<<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.urdu);

  void toggleLanguage() {
    state = state == AppLanguage.urdu ? AppLanguage.english : AppLanguage.urdu;
  }

  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

final languageProvider = StateNotifierProvider<<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});
