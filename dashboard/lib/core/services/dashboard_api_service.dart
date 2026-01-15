import 'package:dio/dio.dart';

class DashboardApiService {
  late final Dio _dio;
  static String? _adminToken;

  static const String defaultApiUrl = 'http://127.0.0.1:8000/api';

  DashboardApiService() {
    final apiUrl = const String.fromEnvironment(
      'API_URL',
      defaultValue: defaultApiUrl,
    );

    _dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        contentType: 'application/json',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_adminToken != null) {
            options.headers['Authorization'] = 'Bearer $_adminToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _adminToken = null;
            // Navigate to login screen when 401 occurs
            // This will be handled by the UI layer
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String token) {
    _adminToken = token;
  }

  void clearToken() {
    _adminToken = null;
  }

  Future<Response> adminLogin({
    required String number,
    required String password,
  }) async {
    return await _dio.post(
      '/login',
      data: {'phone_number': number, 'password': password},
    );
  }

  Future<Response> getPendingUsers() async {
    return await _dio.get('/admin/users/pending');
  }

  Future<Response> approveUser(int userId) async {
    return await _dio.put('/admin/users/$userId/approve');
  }

  Future<Response> rejectUser(int userId) async {
    return await _dio.delete('/admin/users/$userId/reject');
  }

  Future<Response> getHostRequests() async {
    return await _dio.get('/admin/hostRequests');
  }

  Future<Response> approveHostRequest(int userId) async {
    return await _dio.put('/admin/users/$userId/approveHost');
  }

  Future<Response> rejectHostRequest(int userId) async {
    return await _dio.put('/admin/users/$userId/rejectHost');
  }

  Future<Response> getDashboardStats() async {
    return await _dio.get('/admin/');
  }

  Future<Response> getTenants() async {
    return await _dio.get('/admin/users/getTenants');
  }

  Future<Response> getHosts() async {
    return await _dio.get('/admin/users/getHosts');
  }

  Future<Response> removeUser(int userId) async {
    return await _dio.delete('/admin/user/$userId/remove');
  }
}
