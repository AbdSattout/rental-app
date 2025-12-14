import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _phoneKey = 'phone_number';
  static const String _passwordKey = 'password';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveCredentials(String phone, String password) async {
    await _storage.write(key: _phoneKey, value: phone);
    await _storage.write(key: _passwordKey, value: password);
  }

  Future<Map<String, String>?> getCredentials() async {
    final phone = await _storage.read(key: _phoneKey);
    final password = await _storage.read(key: _passwordKey);

    if (phone != null && password != null) {
      return {'phone': phone, 'password': password};
    }
    return null;
  }

  Future<void> deleteCredentials() async {
    await _storage.delete(key: _phoneKey);
    await _storage.delete(key: _passwordKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
