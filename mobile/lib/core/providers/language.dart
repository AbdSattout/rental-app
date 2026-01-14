import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/preferences.dart';
import 'service.dart';

enum LanguageCode { en, ar }

extension LanguageCodeX on LanguageCode {
  String get code => name;
  String get displayName {
    switch (this) {
      case .en:
        return 'English';
      case .ar:
        return 'العربية';
    }
  }
}

class LanguageNotifier extends Notifier<LanguageCode?> {
  late PreferencesService _prefs;

  @override
  LanguageCode? build() {
    _prefs = ref.watch(preferencesServiceProvider);
    final saved = _prefs.getLanguage();
    try {
      return LanguageCode.values.singleWhere((e) => e.code == saved);
    } catch (_) {
      return null;
    }
  }

  Future<void> setLanguage(LanguageCode? language) async {
    state = language;
    await _prefs.setLanguage(language?.code ?? "");
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, LanguageCode?>(
  LanguageNotifier.new,
);
