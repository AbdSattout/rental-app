import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/presentation/widgets/warning.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  late final TextEditingController _bioController;

  bool _obscurePassword = true;

  File? _idImage;
  File? _profileImage;

  bool _validated = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dobController = TextEditingController();
    _bioController = TextEditingController();
    if (ref.read(authStatusProvider) == .error) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(authProvider.notifier).reset(),
      );
    }
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  Future<void> _pickImage(bool isId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxHeight: 1024,
      maxWidth: 1024,
    );
    if (picked == null) return;

    if (await picked.length() > 2 * 1024 * 1024) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.imageTooLarge)));
      return;
    }

    if (picked.mimeType != null &&
        picked.mimeType != 'image/jpeg' &&
        picked.mimeType != 'image/png') {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.invalidImageType)));
      return;
    }

    setState(() {
      if (isId) {
        _idImage = File(picked.path);
      } else {
        _profileImage = File(picked.path);
      }
    });
  }

  void _handleSignup() async {
    setState(() {
      _validated = true;
    });
    if (!_formKey.currentState!.validate()) return;
    if (_idImage == null || _profileImage == null) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.uploadRequiredImages)));
      return;
    }

    await ref
        .read(authProvider.notifier)
        .register(
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
          bio: _bioController.text.trim(),
          idImageBytes: MultipartFile.fromBytes(
            await _idImage!.readAsBytes(),
            filename: _idImage!.path.split('/').last,
          ),
          profileImageBytes: MultipartFile.fromBytes(
            await _profileImage!.readAsBytes(),
            filename: _profileImage!.path.split('/').last,
          ),
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
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(8),
                      child: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
                    ),
                    labelText: loc.dateOfBirthFormat,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? loc.required : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(8),
                      child: HugeIcon(icon: HugeIcons.strokeRoundedPen01),
                    ),
                    labelText: loc.bio,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? loc.required : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: .phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    if (value?.isEmpty ?? true) return loc.phoneRequired;
                    if (!RegExp(r'^0\d{9}$').hasMatch(value ?? "")) {
                      return loc.invalidPhone;
                    }
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
                    if (value?.isEmpty ?? true) return loc.passwordRequired;
                    if (value!.length < 8) return loc.minPasswordCharacters;
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: Column(
                        spacing: 6,
                        children: [
                          Text(
                            loc.idImage,
                            style: .new(
                              color: _idImage == null && _validated
                                  ? ColorScheme.of(context).error
                                  : null,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _pickImage(true),
                            child: Text(loc.upload),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        spacing: 6,
                        children: [
                          Text(
                            loc.profileImage,
                            style: .new(
                              color: _profileImage == null && _validated
                                  ? ColorScheme.of(context).error
                                  : null,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _pickImage(false),
                            child: Text(loc.upload),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (authState.error != null)
                  Warning(
                    variant: .error,
                    message: switch (authState.error!.type) {
                      .networkError => loc.noInternetConnection,
                      .badRequest => loc.checkYourRequest,
                      _ => authState.error!.message,
                    },
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
