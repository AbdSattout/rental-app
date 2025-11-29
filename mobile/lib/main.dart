import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  build(context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CounterNotifier extends Notifier<int> {
  @override
  build() => 0;

  void increment() => state++;
}

final counterProvider = NotifierProvider(CounterNotifier.new);

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  build(context, ref) {
    final counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.title),
      ),
      body: Center(child: Text(AppLocalizations.of(context)!.clicked(counter))),
      floatingActionButton: FloatingActionButton(
        onPressed: ref.read(counterProvider.notifier).increment,
        tooltip: AppLocalizations.of(context)!.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
