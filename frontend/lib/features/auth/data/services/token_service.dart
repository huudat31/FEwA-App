import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyUserEmail = 'user_email';

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: _keyToken, value: user['token']);
    await _storage.write(key: _keyUserId, value: user['id']);
    await _storage.write(key: _keyUserEmail, value: user['email']);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final token = await _storage.read(key: _keyToken);
    if (token == null) return null;
    return {
      'id': await _storage.read(key: _keyUserId) ?? '',
      'email': await _storage.read(key: _keyUserEmail) ?? '',
      'token': token,
    };
  }

  Future<void> clearUser() async {
    await _storage.deleteAll();
  }
}
