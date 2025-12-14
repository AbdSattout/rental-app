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
    required List<int> idImageBytes,
    required List<int> profileImageBytes,
  }) async {
    final formData = FormData.fromMap({
      'phone_number': phoneNumber,
      'password': password,
      'password_confirmation': password,
      'first_name': firstName,
      'last_name': lastName,
      'Date_Of_Birth': dateOfBirth,
      // FIXME
      'ID_image': MultipartFile.fromBytes(
        idImageBytes,
        filename: 'id_image.jpg',
      ),
      'profile_image': MultipartFile.fromBytes(
        profileImageBytes,
        filename: 'profile_image.jpg',
      ),
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
}
