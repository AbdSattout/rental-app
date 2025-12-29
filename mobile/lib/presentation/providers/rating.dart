import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RatingError { unknown, networkError, badRequest }

Future<(RatingError, String)?> storeRating(
  WidgetRef ref, {
  required int postId,
  required int rating,
  String? review,
}) async {
  final repo = ref.read(ratingRepositoryProvider);
  try {
    await repo.storeRating(postId: postId, rating: rating, review: review);
    return null;
  } on DioException catch (e) {
    final res = e.response;
    if (res == null) {
      return (RatingError.networkError, e.toString());
    }
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      return (RatingError.badRequest, e.toString());
    }
    rethrow;
  } catch (e) {
    return (RatingError.unknown, e.toString());
  }
}
