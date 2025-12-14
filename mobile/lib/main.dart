import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/theme/theme.dart';
import 'config/theme/utils.dart';
import 'core/providers/language.dart';
import 'core/providers/service.dart';
import 'core/providers/theme.dart';
import 'core/services/preferences.dart';
import 'l10n/app_localizations.dart';
import 'presentation/screens/loading.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = PreferencesService();
  await prefs.init();

  runApp(
    ProviderScope(
      overrides: [preferencesServiceProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);

    TextTheme textTheme = createTextTheme(
      context,
      "IBM Plex Sans Arabic",
      "Lalezar",
    );

    MaterialTheme theme = .new(textTheme);

    return MaterialApp(
      title: 'Homio',
      locale: language != null ? Locale(language.code) : null,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: themeMode,
      theme: theme.light(),
      darkTheme: theme.dark(),
      home: const LoadingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
