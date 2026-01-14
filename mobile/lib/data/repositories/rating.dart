import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service.dart';

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepository(ref.read(apiServiceProvider).dio);
});

class RatingRepository {
  final Dio _dio;

  RatingRepository(this._dio);

  Future<Response> storeRating({
    required int postId,
    required int rating,
    String? review,
  }) async {
    return await _dio.post(
      '/posts/$postId/rate',
      data: {'rating': rating, if (review != null) 'review': review},
    );
  }
}
