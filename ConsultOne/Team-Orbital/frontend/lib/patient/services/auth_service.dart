import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'dart:developer' as developer;

class AuthService {
  final ApiService _api = ApiService();

  /// Returns null on success, or error message string on failure
  Future<String?> login({required String email, required String password, required bool isDoctor}) async {
    try {
      final endpoint = isDoctor ? '/doctor/signin' : '/patient/login';
      final res = await _api.post(endpoint, {'email': email, 'password': password});
      final token = res['token'] as String?;
      developer.log('🔵 AuthService.login: endpoint=$endpoint, tokenPresent=${token != null}, resKeys=${res.keys.toList()}', name: 'AuthService');
      // save role if provided
      if (res.containsKey('role')) {
        await TokenStorage.saveUserRole(res['role'] as String?);
        developer.log('AuthService.login: saved role from res.role', name: 'AuthService');
      } else if (res.containsKey('user') && res['user'] is Map && (res['user'] as Map).containsKey('role')) {
        await TokenStorage.saveUserRole((res['user'] as Map)['role'] as String?);
        developer.log('AuthService.login: saved role from res.user.role', name: 'AuthService');
      }
      if (token != null && token.isNotEmpty) {
        await TokenStorage.saveToken(token);
        developer.log('✅ AuthService.login: token saved (length=${token.length})', name: 'AuthService');
      }
      return null;
    } catch (e) {
      developer.log('❌ AuthService.login error: $e', name: 'AuthService');
      return e.toString();
    }
  }

  /// signUp returns null on success, or error message on failure
  Future<String?> signUp({required Map<String, dynamic> data, required bool isDoctor}) async {
    try {
      final endpoint = isDoctor ? '/doctor/signup' : '/patient/signup';
      final res = await _api.post(endpoint, data);
      developer.log('AuthService.signUp: endpoint=$endpoint, resKeys=${res.keys.toList()}', name: 'AuthService');
      // For patient signup backend returns token
      if (!isDoctor) {
        // save role if provided
        if (res.containsKey('role')) {
          await TokenStorage.saveUserRole(res['role'] as String?);
          developer.log('AuthService.signUp: saved role from res.role', name: 'AuthService');
        } else if (res.containsKey('user') && res['user'] is Map && (res['user'] as Map).containsKey('role')) {
          await TokenStorage.saveUserRole((res['user'] as Map)['role'] as String?);
          developer.log('AuthService.signUp: saved role from res.user.role', name: 'AuthService');
        }

        final token = res['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await TokenStorage.saveToken(token);
          developer.log('AuthService.signUp: token saved (length=${token.length})', name: 'AuthService');
        }
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    developer.log('🗑️ AuthService.logout: Clearing all authentication data', name: 'AuthService');
    await TokenStorage.deleteToken();
    await TokenStorage.saveUserRole(null);
    developer.log('✅ AuthService.logout: Token and role cleared', name: 'AuthService');
  }
}
