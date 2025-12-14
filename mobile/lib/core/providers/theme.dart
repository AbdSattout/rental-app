import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/preferences.dart';
import 'service.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  late PreferencesService _prefs;

  @override
  ThemeMode build() {
    _prefs = ref.watch(preferencesServiceProvider);
    final saved = _prefs.getThemeMode();
    return ThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setThemeMode(mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
