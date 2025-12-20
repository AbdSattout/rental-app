import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:homio/presentation/screens/loading.dart';

import '../../config/constants.dart';
import 'secure_storage.dart';

class ApiService {
  late final Dio dio;
  final SecureStorageService _secureStorage;
  final GlobalKey<NavigatorState> _navigatorKey;

  ApiService(this._secureStorage, this._navigatorKey) {
    final apiUrl = const String.fromEnvironment(
      'API_URL',
      defaultValue: defaultApiUrl,
    );

    dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _secureStorage.deleteToken();
            final nav = _navigatorKey.currentState!;
            while (nav.canPop()) {
              nav.pop();
            }
            nav.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoadingScreen()),
              (_) => false,
            );
          }
          return handler.next(error);
        },
      ),
    );
  }
}
