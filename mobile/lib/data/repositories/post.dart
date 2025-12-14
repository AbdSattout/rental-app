import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service.dart';
import '../models/post.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.read(apiServiceProvider).dio);
});

class PostRepository {
  final Dio _dio;

  PostRepository(this._dio);

  Future<Response> getHomepageFeed({int page = 1}) async {
    return await _dio.get('/homepage', queryParameters: {'page': page});
  }

  Future<Response> getPostDetails(int postId) async {
    return await _dio.get('/detailed/$postId/post');
  }

  Future<Response> filterPosts({
    PostType? type,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
    int? maxRooms,
    int? minBathrooms,
    int? maxBathrooms,
    double? userLatitude,
    double? userLongitude,
    int? radius,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (type != null) {
        queryParams['type'] = type.name;
      }
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (minRooms != null) queryParams['min_rooms'] = minRooms;
      if (maxRooms != null) queryParams['max_rooms'] = maxRooms;
      if (minBathrooms != null) queryParams['min_bathrooms'] = minBathrooms;
      if (maxBathrooms != null) queryParams['max_bathrooms'] = maxBathrooms;
      if (userLatitude != null) queryParams['user_lat'] = userLatitude;
      if (userLongitude != null) queryParams['user_lng'] = userLongitude;
      if (radius != null) queryParams['radius'] = radius;

      return await _dio.get('/filter', queryParameters: queryParams);
    } on DioException catch (_) {
      rethrow;
    }
  }

  // FIXME
  Future<Response> createPost({
    required PostType type,
    required double space,
    required int rooms,
    required int bathrooms,
    required double price,
    required double latitude,
    required double longitude,
    required List<MultipartFile> photos,
  }) async {
    try {
      final renamedPhotos = <MultipartFile>[];

      for (int i = 0; i < photos.length; i++) {
        final original = photos[i];

        renamedPhotos.add(
          MultipartFile.fromStream(
            original.clone().finalize,
            original.length,
            filename: 'photo_$i.jpg',
            contentType: original.contentType,
          ),
        );
      }

      final formData = FormData.fromMap({
        'type': type.name,
        'space': space,
        'rooms': rooms,
        'bathrooms': bathrooms,
        'price': price,
        'latitude': latitude,
        'longitude': longitude,
        for (int i = 0; i < renamedPhotos.length; i++)
          'photos[$i]': renamedPhotos[i],
      });

      return await _dio.post('/posts', data: formData);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> updatePost({
    required int postId,
    required PostType type,
    required double space,
    required int rooms,
    required int bathrooms,
    required double price,
    required double latitude,
    required double longitude,
    List<MultipartFile>? photos,
  }) async {
    try {
      final renamedPhotos = <MultipartFile>[];

      for (int i = 0; i < (photos?.length ?? 0); i++) {
        final original = photos![i];

        renamedPhotos.add(
          MultipartFile.fromStream(
            original.clone().finalize,
            original.length,
            filename: 'photo_$i.jpg',
            contentType: original.contentType,
          ),
        );
      }

      final formData = FormData.fromMap({
        'type': type.name,
        'space': space,
        'rooms': rooms,
        'bathrooms': bathrooms,
        'price': price,
        'latitude': latitude,
        'longitude': longitude,
        for (int i = 0; i < renamedPhotos.length; i++)
          'photos[$i]': renamedPhotos[i],
      });

      return await _dio.post('/update/$postId/post', data: formData);
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<Response> deletePost(int postId) async {
    return await _dio.delete('/delete/$postId/post');
  }

  Future<Response> getUserPosts(int userId, {int page = 1}) async {
    return await _dio.get(
      '/user/$userId/posts',
      queryParameters: {'page': page},
    );
  }

  Future<Response> getOwnPosts({int page = 1}) async {
    return await _dio.get('/user/posts', queryParameters: {'page': page});
  }
}
