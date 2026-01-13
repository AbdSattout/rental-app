import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/data/models/user.dart';
import 'package:homio/l10n/app_localizations.dart';
import 'package:homio/presentation/providers/post.dart';
import 'package:homio/presentation/providers/profile.dart';
import 'package:homio/presentation/screens/post_details.dart';
import 'package:homio/presentation/widgets/empty.dart';
import 'package:homio/presentation/widgets/error_retry.dart';
import 'package:homio/presentation/widgets/posts_grid.dart';
import 'package:homio/presentation/widgets/warning.dart';
import 'package:hugeicons/hugeicons.dart';

class PostsTab extends ConsumerStatefulWidget {
  final User? user;

  const PostsTab({super.key, required this.user});

  @override
  ConsumerState<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends ConsumerState<PostsTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.user != null && widget.user!.role == .host) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          ref.read(ownPostsProvider.notifier).loadMore();
        }
      });
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(getOwnPosts);
    ref.invalidate(getProfile);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final isGuest = widget.user == null || widget.user!.role == .guest;

    final posts = widget.user != null && widget.user!.role == .host
        ? ref.watch(ownPostsProvider)
        : null;

    if (isGuest) {
      return Center(child: Text(loc.guestMode));
    }

    if (widget.user!.role != .host) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Warning(variant: WarningVariant.info, message: loc.notAHost),
          ],
        ),
      );
    }

    if (posts == null) {
      return const SizedBox.shrink();
    }

    if (posts.isLoading && !posts.hasError) {
      return const PostsGridSkeleton();
    }

    if (posts.hasError) {
      final error = posts.error;
      String message;
      if (error is DioException && error.response == null) {
        message = loc.noInternetConnection;
      } else {
        message = error.toString();
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [ErrorRetry(message: message, onRetry: _refresh)],
        ),
      );
    }

    if (posts.requireValue.$2.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: .symmetric(horizontal: 20),
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Empty(
                  icon: HugeIcons.strokeRoundedHouse01,
                  message: loc.noAppartments,
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: PostsGrid(
        controller: _scrollController,
        hasMore: posts.requireValue.$1.hasMore,
        posts: posts.requireValue.$2,
        cardFlags: .new(showFavorite: false),
        detailsFlags: const PostDetailsScreenFlags(
          showHost: false,
          showButtons: false,
          canEdit: true,
        ),
      ),
    );
  }
}
