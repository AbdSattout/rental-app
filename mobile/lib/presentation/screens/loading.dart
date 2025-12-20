import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/presentation/screens/signup.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/providers/auth.dart';
import '../../l10n/app_localizations.dart';
import 'home.dart';
import 'login.dart';
import 'welcome.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).initializeAuth());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final loc = AppLocalizations.of(context)!;

    if (authState.status == .loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  ColorScheme.of(context).primary,
                ),
              ),
              SizedBox(height: 24),
              Text(loc.loading, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    switch (authState.status) {
      case AuthStatus.authenticated:
        return const HomeScreen();

      case AuthStatus.approvalPending:
        return const HomeScreen();

      case AuthStatus.rejected:
        return _RejectionScreen();

      case AuthStatus.initial:
        return const WelcomeScreen();

      case AuthStatus.unauthenticated:
        return const LoginScreen();

      case AuthStatus.loading:
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                ColorScheme.of(context).primary,
              ),
            ),
          ),
        );

      case AuthStatus.error:
        {
          if (authState.error?.$1 == .networkError) {
            return _ErrorScreen(message: loc.noInternetConnection);
          }
          return _ErrorScreen(message: authState.error?.$2 ?? 'Unknown error');
        }
    }
  }
}

class _RejectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: .all(24),
          child: Column(
            mainAxisAlignment: .center,
            spacing: 24,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedBlocked,
                size: 64,
                color: ColorScheme.of(context).error,
              ),
              Text(
                loc.approvalRejected,
                style: TextTheme.of(context).headlineSmall,
                textAlign: .center,
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: Text(loc.createANewAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: .all(24),
          child: Column(
            mainAxisAlignment: .center,
            spacing: 24,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAlertCircle,
                size: 64,
                color: ColorScheme.of(context).tertiary,
              ),
              Text(
                message,
                style: TextTheme.of(context).headlineSmall,
                textAlign: .center,
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoadingScreen(),
                    ),
                  );
                },
                child: Text(loc.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
