import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/presentation/widgets/warning.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/providers/auth.dart';
import '../../l10n/app_localizations.dart';
import 'home.dart';
import 'signup.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .login(_phoneController.text.trim(), _passwordController.text);

    if (ref.read(authStatusProvider) == .authenticated ||
        ref.read(authStatusProvider) == .approvalPending) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (_) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const .all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                SizedBox(height: 32),
                Text(
                  loc.welcome,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  loc.signInToYourAccount,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    labelText: loc.phone,
                    prefixIcon: Padding(
                      padding: .all(8),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSmartPhone01,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return loc.phoneRequired;
                    }
                    if (value!.length < 10) {
                      return loc.phoneMinDigits;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    labelText: loc.password,
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(8),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLockPassword,
                        size: 24,
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: .directional(end: 5),
                      child: IconButton(
                        icon: HugeIcon(
                          icon: _obscurePassword
                              ? HugeIcons.strokeRoundedView
                              : HugeIcons.strokeRoundedViewOffSlash,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return loc.passwordRequired;
                    }
                    if (value!.length < 8) {
                      return loc.passwordMinCharacters;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                if (authState.error != null)
                  Warning(
                    variant: .error,
                    message: switch (authState.error!.type) {
                      .networkError => loc.noInternetConnection,
                      .invalidCredentials => loc.invalidCredentials,
                      .badRequest => loc.checkYourRequest,
                      _ => authState.error!.message,
                    },
                  ),
                if (authState.error != null) SizedBox(height: 16),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  child: authState.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              ColorScheme.of(context).onPrimary,
                            ),
                          ),
                        )
                      : Text(loc.login),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4,
                  children: [
                    Text(loc.dont_have_account),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                      child: Text(loc.sign_up_here),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                  child: Text(loc.continueAsGuest),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
