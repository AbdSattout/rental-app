import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service.dart';
import '../models/post.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.read(apiServiceProvider).dio);
});

class PostFilter {
  PostType? type;
  double? minPrice;
  double? maxPrice;
  int? minBathrooms;
  int? maxBathrooms;
  int? minRooms;
  int? maxRooms;
  int? minSpace;
  int? maxSpace;
  double? userLatitude;
  double? userLongitude;
  int? radius;

  PostFilter({
    this.type,
    this.minPrice,
    this.maxPrice,
    this.minBathrooms,
    this.maxBathrooms,
    this.minRooms,
    this.maxRooms,
    this.minSpace,
    this.maxSpace,
    this.userLatitude,
    this.userLongitude,
    this.radius,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostFilter) return false;
    return type == other.type &&
        minPrice == other.minPrice &&
        maxPrice == other.maxPrice &&
        minBathrooms == other.minBathrooms &&
        maxBathrooms == other.maxBathrooms &&
        minRooms == other.minRooms &&
        maxRooms == other.maxRooms &&
        minSpace == other.minSpace &&
        maxSpace == other.maxSpace &&
        userLatitude == other.userLatitude &&
        userLongitude == other.userLongitude &&
        radius == other.radius;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        minPrice.hashCode ^
        maxPrice.hashCode ^
        minBathrooms.hashCode ^
        maxBathrooms.hashCode ^
        minRooms.hashCode ^
        maxRooms.hashCode ^
        minSpace.hashCode ^
        maxSpace.hashCode ^
        userLatitude.hashCode ^
        userLongitude.hashCode ^
        radius.hashCode;
  }
}

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
    required PostFilter filter,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    final PostFilter(
      :type,
      :minPrice,
      :maxPrice,
      :minRooms,
      :maxRooms,
      :minBathrooms,
      :maxBathrooms,
      :minSpace,
      :maxSpace,
      :userLatitude,
      :userLongitude,
      :radius,
    ) = filter;

    if (type != null) queryParams['type'] = type.name;
    if (minPrice != null) queryParams['min_price'] = minPrice;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;
    if (minRooms != null) queryParams['min_rooms'] = minRooms;
    if (maxRooms != null) queryParams['max_rooms'] = maxRooms;
    if (minBathrooms != null) queryParams['min_bathrooms'] = minBathrooms;
    if (maxBathrooms != null) queryParams['max_bathrooms'] = maxBathrooms;
    if (minSpace != null) queryParams['min_space'] = minSpace;
    if (maxSpace != null) queryParams['max_space'] = maxSpace;
    if (userLatitude != null) queryParams['user_lat'] = userLatitude;
    if (userLongitude != null) queryParams['user_lng'] = userLongitude;
    if (radius != null) queryParams['radius'] = radius;

    return await _dio.get('/filter', queryParameters: queryParams);
  }

  Future<Response> createPost({
    required PostType type,
    required double space,
    required int rooms,
    required int bathrooms,
    required double price,
    required double latitude,
    required double longitude,
    required List<MultipartFile> featured,
    required List<MultipartFile> gallery,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': type.name,
        'space': space,
        'rooms': rooms,
        'bathrooms': bathrooms,
        'price': price,
        'latitude': latitude,
        'longitude': longitude,
        for (int i = 0; i < featured.length; i++)
          'outside_photos[$i]': featured[i],
        for (int i = 0; i < gallery.length; i++)
          'inside_photos[$i]': gallery[i],
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
    List<MultipartFile>? featured,
    List<MultipartFile>? gallery,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': type.name,
        'space': space,
        'rooms': rooms,
        'bathrooms': bathrooms,
        'price': price,
        'latitude': latitude,
        'longitude': longitude,
        for (int i = 0; i < (featured?.length ?? 0); i++)
          'outside_photos[$i]': featured![i],
        for (int i = 0; i < (gallery?.length ?? 0); i++)
          'inside_photos[$i]': gallery![i],
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
