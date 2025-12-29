import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/presentation/providers/post.dart';

enum FavoriteError { unknown, networkError }

Future<(FavoriteError, String)?> toggleFavorite(
  WidgetRef ref,
  int postId,
) async {
  final repo = ref.read(favoriteRepositoryProvider);
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
  } catch (e) {
    return (FavoriteError.unknown, e.toString());
  }
}
