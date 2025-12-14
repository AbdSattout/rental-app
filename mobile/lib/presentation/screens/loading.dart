import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    print(authState.status);

    if (authState.status == AuthStatus.loading) {
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
              Text(
                AppLocalizations.of(context)!.loading,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
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
        return _ErrorScreen(error: authState.error ?? 'Unknown error');
    }
  }
}

class _RejectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                AppLocalizations.of(context)?.approvalRejected ??
                    'Account Rejected',
                style: Theme.of(context).textTheme.headlineSmall,
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
                child: Text(AppLocalizations.of(context)!.sign_up_here),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatefulWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  State<_ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<_ErrorScreen> {
  bool isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: ColorScheme.of(context).error,
              ),
              SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)?.error ?? 'Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              Text(
                widget.error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              if (!isRetrying)
                ElevatedButton(
                  onPressed: () {
                    setState(() => isRetrying = true);
                    Future.delayed(Duration(seconds: 1), () {
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/');
                      }
                    });
                  },
                  child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
                )
              else
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(
                    ColorScheme.of(context).primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
