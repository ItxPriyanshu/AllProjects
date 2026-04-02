import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _readNotificationsKey = 'read_notifications';

  static Future<void> saveToken(String token) async {
    if (token.isEmpty) {
      await deleteToken();
      return;
    }

    // Directly write the token. Deleting then delaying caused race conditions
    // where reads could happen between delete and write (buffering symptom).
    await _storage.write(key: _tokenKey, value: token);
    developer.log('TokenStorage: saved token (length=${token.length})', name: 'TokenStorage');
  }

  static Future<void> saveUserRole(String? role) async {
    if (role == null || role.isEmpty) {
      await _storage.delete(key: _roleKey);
      developer.log('TokenStorage: saved user role -> deleted (null/empty)', name: 'TokenStorage');
      return;
    }
    await _storage.write(key: _roleKey, value: role);
    developer.log('TokenStorage: saved user role -> $role', name: 'TokenStorage');
  }

  static Future<String?> getToken() async {
    final t = await _storage.read(key: _tokenKey);
    developer.log('TokenStorage: read token ${t == null ? "null" : "(present)"}', name: 'TokenStorage');
    return t;
  }

  static Future<String?> getUserRole() async {
    final r = await _storage.read(key: _roleKey);
    developer.log('TokenStorage: read user role ${r == null ? "null" : r}', name: 'TokenStorage');
    return r;
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    developer.log('TokenStorage: deleted token', name: 'TokenStorage');
  }

  static Future<List<String>> getReadNotificationIds() async {
    final str = await _storage.read(key: _readNotificationsKey);
    if (str == null || str.isEmpty) return [];
    return str.split(',').where((s) => s.isNotEmpty).toList();
  }

  static Future<void> saveReadNotificationIds(List<String> ids) async {
    final str = ids.join(',');
    await _storage.write(key: _readNotificationsKey, value: str);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
