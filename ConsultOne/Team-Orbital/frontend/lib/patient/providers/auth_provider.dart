import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifier, StateNotifierProvider;
import 'package:frontend/patient/services/auth_service.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:frontend/patient/services/firebase_service.dart';
import 'dart:developer' as developer;

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? role; // doc ya patient
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.role,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? role,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      error: error, 
    );
  }
}


final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Add timeout to prevent infinite loading
      final token = await TokenStorage.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      final role = await TokenStorage.getUserRole().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      developer.log('AuthController.checkAuthStatus: token ${token == null ? "null" : "present"}, role ${role ?? "null"}', name: 'AuthController');
      if (token != null && token.isNotEmpty) {
        state = AuthState(isAuthenticated: true, role: role, isLoading: false);
        developer.log('AuthController: user authenticated via stored token', name: 'AuthController');
      } else {
        state = AuthState(isAuthenticated: false, isLoading: false);
        developer.log('AuthController: no token found, user not authenticated', name: 'AuthController');
      }
    } catch (e) {
      developer.log('AuthController.checkAuthStatus error: $e', name: 'AuthController');
      state = AuthState(isAuthenticated: false, isLoading: false);
    }
  }

  Future<void> login(String email, String password, bool isDoctor) async {
    state = state.copyWith(isLoading: true, error: null);
    
    // IMPORTANT: Clear any existing token before login to prevent role conflicts
    await TokenStorage.clearAll();
    developer.log('🗑️ AuthController.login: Cleared all stored tokens before fresh login (isDoctor=$isDoctor)', name: 'AuthController');
    
    final error = await _authService.login(
      email: email, 
      password: password, 
      isDoctor: isDoctor
    );

    if (error == null) {
      state = AuthState(
        isAuthenticated: true, 
        role: isDoctor ? 'doctor' : 'patient',
        isLoading: false
      );
      final savedRole = isDoctor ? 'doctor' : 'patient';
      // persist role so startup check can read it
      await TokenStorage.saveUserRole(savedRole);
      developer.log('✅ AuthController.login: login success, role=$savedRole', name: 'AuthController');
      
      // Save FCM token to backend after successful login
      try {
        await FirebaseService.saveFCMTokentobackend();
      } catch (e) {
        print('Error saving FCM token after login: $e');
      }
    } else {
      state = state.copyWith(isLoading: false, error: error);
      developer.log('❌ AuthController.login failed: $error', name: 'AuthController');
    }
  }
  Future<bool> signUp(Map<String,dynamic> data, bool isDoctor) async {
    state = state.copyWith(isLoading: true, error: null);
    final error = await _authService.signUp(data: data, isDoctor: isDoctor);

    if (error == null) {
      // For doctors: signup successful but they need to login (no token returned)
      // For patients: signup returns token, so set authenticated
      if (isDoctor) {
        // Doctor signup successful but no auto-login
        state = state.copyWith(isLoading: false);
        // Don't set isAuthenticated or try to save FCM token
        // Doctor must login separately
        developer.log('AuthController.signUp: signup success (doctor)', name: 'AuthController');
        return true;
      } else {
        // Patient signup returns token, so authenticate them
        state = AuthState(
          isAuthenticated: true, 
          role: 'patient',
          isLoading: false
        );
        
        // Save FCM token to backend after successful patient signup
        try {
          await FirebaseService.saveFCMTokentobackend();
        } catch (e) {
          print('Error saving FCM token after patient signup: $e');
        }
        // persist role for patient so startup check sees it
        await TokenStorage.saveUserRole('patient');
        developer.log('AuthController.signUp: signup success (patient)', name: 'AuthController');
        return true;
      }
    } else {
      state = state.copyWith(isLoading: false, error: error);
      developer.log('AuthController.signUp failed: $error', name: 'AuthController');
      return false;
    }
  }

  Future<void> logout() async {
    developer.log('🗑️ AuthController.logout: Clearing all tokens and user data', name: 'AuthController');
    
    // Clear auth service data
    await _authService.logout();
    
    // Clear persisted role
    await TokenStorage.saveUserRole(null);
    
    // IMPORTANT: Clear the token as well
    await TokenStorage.deleteToken();
    
    developer.log('✅ AuthController.logout: All data cleared', name: 'AuthController');
    state = AuthState(isAuthenticated: false);
  }
}


final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});
