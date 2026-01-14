import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/data/models/post.dart';
import '/l10n/app_localizations.dart';
import '../widgets/forms/create_post.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key, this.post});

  final Post? post;

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.post == null ? loc.createApartment : loc.editApartment,
        ),
      ),
      body: CreatePostForm(post: widget.post),
    );
  }
}
