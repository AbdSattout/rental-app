import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(apiServiceProvider).dio);
});

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<Response> fetchProfile() async {
    try {
      return await _dio.get('/user/profile');
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<Response> fetchProfileByPost(int postId) async {
    try {
      return await _dio.get('/post/$postId/profile');
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<Response> updateProfile({
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    List<int>? profileImageBytes,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (dateOfBirth != null) 'Date_Of_Birth': dateOfBirth,
        if (profileImageBytes != null)
          'profile_image': MultipartFile.fromBytes(
            profileImageBytes,
            filename: 'profile_image.jpg',
          ),
      });

      return await _dio.post('/profile', data: formData);
    } on DioException catch (_) {
      rethrow;
    }
  }
}
