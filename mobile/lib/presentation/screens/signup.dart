import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/providers/auth.dart';
import '../../l10n/app_localizations.dart';
import 'home.dart';
import 'login.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _dobController;

  bool _obscurePassword = true;

  Uint8List? _idImage;
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dobController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      if (isId) {
        _idImage = bytes;
      } else {
        _profileImage = bytes;
      }
    });
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idImage == null || _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required images.')),
      );
      return;
    }

    await ref
        .read(authProvider.notifier)
        .register(
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dateOfBirth:
              DateTime.tryParse(
                _dobController.text.trim(),
              )?.toIso8601String().split('T').first ??
              '',
          idImageBytes: _idImage!,
          profileImageBytes: _profileImage!,
        );

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
                const SizedBox(height: 32),
                Text(
                  loc.signup,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: .center,
                ),
                const SizedBox(height: 32),

                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(labelText: loc.firstName),
                        validator: (v) =>
                            v == null || v.isEmpty ? loc.required : null,
                      ),
                    ),

                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(labelText: loc.lastName),
                        validator: (v) =>
                            v == null || v.isEmpty ? loc.required : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(8),
                      child: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
                    ),
                    labelText: 'Date of Birth (YYYY-MM-DD)',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? loc.required : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: loc.phone,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(8),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSmartPhone01,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Phone is required';
                    if (value!.length < 10) return 'Invalid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: loc.password,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(8),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLockPassword,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: HugeIcon(
                        icon: _obscurePassword
                            ? HugeIcons.strokeRoundedView
                            : HugeIcons.strokeRoundedViewOffSlash,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password required';
                    if (value!.length < 8) return 'Min 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('ID Image'),
                          const SizedBox(height: 6),
                          OutlinedButton(
                            onPressed: () => _pickImage(true),
                            child: Text('Upload'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Profile Image'),
                          const SizedBox(height: 6),
                          OutlinedButton(
                            onPressed: () => _pickImage(false),
                            child: Text('Upload'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).errorContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorScheme.of(context).error),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: ColorScheme.of(context).onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            switch (authState.error!.type) {
                              .networkError => loc.noInternetConnection,
                              .badRequest => loc.checkYourRequest,
                              _ => authState.error!.message,
                            },
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSignup,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(loc.signup),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.already_have_account),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            ),
                      child: Text(loc.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
