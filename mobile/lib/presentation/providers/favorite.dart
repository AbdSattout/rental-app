import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/presentation/providers/post.dart';

import '../../data/models/post.dart';
import '../../data/repositories/favorite.dart';

Duration? _retry(int count, Object error) {
  if (error is DioException && error.response == null) return null;
  if (count > 10) return null;
  return Duration(milliseconds: 200 * count);
}

List<Post> parseFavorites(List list) =>
    list.map((e) => Post.fromJson(e)).toList();

final getFavorites = FutureProvider<List<Post>>((ref) async {
  try {
    final repo = ref.read(favoriteRepositoryProvider);
    final response = await repo.showFavorites();
    final data = response.data['favorites'] ?? [];
    return parseFavorites(data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      return [];
    }
    rethrow;
  }
}, retry: _retry);

enum FavoriteError { unknown, networkError }

Future<(FavoriteError, String)?> toggleFavorite(
  WidgetRef ref,
  int postId,
) async {
  final repo = ref.read(favoriteRepositoryProvider);
  try {
    try {
      await repo.toggleFavorite(postId);
      ref.invalidate(getFavorites);
      // TODO: optimistic update
      ref.invalidate(getPostDetails(postId));
      return null;
    } on DioException catch (e) {
      final res = e.response;
      if (res == null) {
        return (FavoriteError.networkError, e.toString());
      }
      rethrow;
    }
  } catch (e) {
    return (FavoriteError.unknown, e.toString());
  }
}
