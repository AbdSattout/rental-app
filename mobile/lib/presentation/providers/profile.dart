import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/profile.dart';
import '../../data/repositories/profile.dart';

Duration? _retry(int count, Object error) {
  if (error is DioException && error.response == null) return null;
  if (count > 10) return null;
  return Duration(milliseconds: 200 * count);
}

final getProfile = FutureProvider<Profile>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  final response = await repo.fetchProfile();
  final data = response.data["profile"] ?? response.data;
  return Profile.fromJson(data);
}, retry: _retry);

final getProfileByPost = FutureProvider.family<Profile, int>((
  ref,
  int postId,
) async {
  final repo = ref.read(profileRepositoryProvider);
  final response = await repo.fetchProfileByPost(postId);
  final data = response.data["profile"] ?? response.data;
  return Profile.fromJson(data);
}, retry: _retry);

enum ProfileError { unknown, networkError, badRequest }

Future<({ProfileError type, String message})?> updateProfile(
  WidgetRef ref, {
  String? firstName,
  String? lastName,
  String? dateOfBirth,
  MultipartFile? profileImage,
}) async {
  final repo = ref.read(profileRepositoryProvider);
  try {
    final response = await repo.updateProfile(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      profileImage: profileImage,
    );
    final data = response.data["data"] ?? response.data;
    Profile.fromJson(data);
    return null;
  } on DioException catch (e) {
    final res = e.response;
    if (res == null) {
      return (type: ProfileError.networkError, message: e.toString());
    }
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      return (type: ProfileError.badRequest, message: e.toString());
    }
    rethrow;
  } catch (e) {
    return (type: ProfileError.unknown, message: e.toString());
  }
}
