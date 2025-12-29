import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository(ref.read(apiServiceProvider).dio);
});

class FavoriteRepository {
  final Dio _dio;

  FavoriteRepository(this._dio);

  Future<Response> showFavorites() async {
    return await _dio.get('/user/favorites');
  }

  Future<Response> toggleFavorite(int postId) async {
    return await _dio.post('/posts/$postId/favorites');
  }
}
