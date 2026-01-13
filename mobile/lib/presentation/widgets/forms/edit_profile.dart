import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/core/providers/navigator_key.dart';
import 'package:homio/core/utils/asset.dart';
import 'package:homio/presentation/widgets/error_retry.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '/l10n/app_localizations.dart';
import '../../providers/profile.dart';
import '../../utils.dart';

class EditProfileForm extends ConsumerStatefulWidget {
  const EditProfileForm({super.key});

  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  String? _first;
  String? _last;
  String? _dob;
  File? _profileImage;
  bool _loaded = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() {
      _dob = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  Future<void> _pickImage() async {
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

    setState(() => _profileImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentAsync = ref.watch(getProfile);

    if (currentAsync.isLoading && !currentAsync.hasError) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentAsync.hasError && !currentAsync.isLoading) {
      final error = currentAsync.error;
      String message;
      if (error is DioException && error.response == null) {
        message = loc.noInternetConnection;
      } else {
        message = error.toString();
      }

      return Expanded(
        child: ErrorRetry(
          message: message,
          onRetry: () async {
            ref.invalidate(getProfile);
          },
        ),
      );
    }

    if (!_loaded) {
      _first = currentAsync.requireValue.firstName;
      _last = currentAsync.requireValue.lastName;
      _dob = currentAsync.requireValue.dateOfBirth;
      _loaded = true;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : CachedNetworkImageProvider(
                            AssetUtil.getProfile(
                              ref.read(getProfile).value!.profileImage,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      borderRadius: .circular(18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).primaryContainer,
                          borderRadius: .circular(18),
                        ),
                        child: Padding(
                          padding: const .all(8.0),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedImageAdd01,
                            size: 18,
                            color: ColorScheme.of(context).onPrimaryContainer,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Form(
              key: _formKey,
              child: Column(
                spacing: 8,
                children: [
                  TextFormField(
                    initialValue: _first,
                    decoration: InputDecoration(labelText: loc.firstName),
                    onSaved: (v) => _first = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? loc.required : null,
                  ),
                  TextFormField(
                    initialValue: _last,
                    decoration: InputDecoration(labelText: loc.lastName),
                    onSaved: (v) => _last = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? loc.required : null,
                  ),
                  TextFormField(
                    initialValue: _dob,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: InputDecoration(labelText: loc.dateOfBirth),
                    onSaved: (v) => _dob = v,
                    validator: (v) =>
                        v == null || v.isEmpty ? loc.required : null,
                  ),

                  Row(
                    mainAxisAlignment: .end,
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(loc.cancel),
                      ),
                      FilledButton(onPressed: _save, child: Text(loc.save)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context)!;
    _formKey.currentState?.save();

    if (mounted) {
      await showBlockingLoadingUntil(
        context,
        ref.read(navigatorKeyProvider),
        action: () async {
          return await updateProfile(
            ref,
            firstName: _first,
            lastName: _last,
            dateOfBirth: _dob,
            profileImage: _profileImage != null
                ? MultipartFile.fromBytes(
                    await _profileImage!.readAsBytes(),
                    filename: _profileImage!.path.split('/').last,
                  )
                : null,
          );
        },
        onCompleted: (result) {
          if (result == null) {
            ref.invalidate(getProfile);
            Navigator.of(context).pop(true);
          } else {
            final message = switch (result.type) {
              ProfileError.networkError => loc.noInternetConnection,
              ProfileError.badRequest => (loc.checkYourRequest),
              _ => result.message,
            };
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
      );
    }
  }
}
