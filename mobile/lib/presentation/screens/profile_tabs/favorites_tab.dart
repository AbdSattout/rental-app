import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/data/models/user.dart';
import 'package:homio/l10n/app_localizations.dart';
import 'package:homio/presentation/providers/favorite.dart';
import 'package:homio/presentation/providers/profile.dart';
import 'package:homio/presentation/widgets/error_retry.dart';
import 'package:homio/presentation/widgets/posts_grid.dart';
import 'package:homio/presentation/widgets/warning.dart';

class FavoritesTab extends ConsumerStatefulWidget {
  final User? user;

  const FavoritesTab({super.key, required this.user});

  @override
  ConsumerState<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends ConsumerState<FavoritesTab> {
  Future<void> _refresh() async {
    ref.invalidate(getFavorites);
    ref.invalidate(getProfile);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final isGuest = widget.user == null || widget.user!.role == .guest;
    final favoritesAsync = !isGuest ? ref.watch(getFavorites) : null;

    if (isGuest) {
      return Center(child: Text(loc.guestMode));
    }

    if (favoritesAsync == null) {
      return const SizedBox.shrink();
    }

    if (favoritesAsync.isLoading && !favoritesAsync.hasError) {
      return const PostsGridSkeleton();
    }

    if (favoritesAsync.hasError) {
      final error = favoritesAsync.error;
      String message;
      if (error is DioException && error.response == null) {
        message = loc.noInternetConnection;
      } else {
        message = error.toString();
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ErrorRetry(message: message, onRetry: _refresh),
      );
    }

    final favorites = favoritesAsync.asData?.value ?? [];

    if (favorites.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Warning(variant: WarningVariant.info, message: loc.nothingHere),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: PostsGrid(posts: favorites),
    );
  }
}
