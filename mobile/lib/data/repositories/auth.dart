import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiServiceProvider).dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Response> login({
    required String phoneNumber,
    required String password,
  }) async {
    return await _dio.post(
      '/login',
      data: {'phone_number': phoneNumber, 'password': password},
    );
  }

  Future<Response> register({
    required String phoneNumber,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String bio,
    required MultipartFile idImage,
    required MultipartFile profileImage,
  }) async {
    final formData = FormData.fromMap({
      'phone_number': phoneNumber,
      'password': password,
      'password_confirmation': password,
      'first_name': firstName,
      'last_name': lastName,
      'Date_Of_Birth': dateOfBirth,
      'Bio': bio,
      'ID_image': idImage,
      'profile_image': profileImage,
    });

    return await _dio.post('/register', data: formData);
  }

  Future<Response> getUser() async {
    return await _dio.get('/user');
  }

  Future<Response> logout() async {
    return await _dio.delete('/logout');
  }

  Future<Response> beHost() async {
    return await _dio.post('/user/beHost');
  }

  Future<Response> updateFcmToken(String fcmToken) async {
    return await _dio.post(
      '/user/update-fcm-token',
      data: {'fcm_token': fcmToken},
    );
  }
}
