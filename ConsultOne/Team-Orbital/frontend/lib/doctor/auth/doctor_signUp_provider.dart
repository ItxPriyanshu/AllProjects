import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/doctor/auth/doctor_signUp_model.dart';
import 'package:frontend/patient/services/apiservice.dart';
import 'package:frontend/patient/services/tokenstorage.dart';
import 'dart:developer' as developer;

final doctorAuthProvider = NotifierProvider<DoctorAuthNotifier, bool>(() {
  return DoctorAuthNotifier();
});

class DoctorAuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<Map<String, dynamic>> signupDoctor(DoctorSignupModel model) async {
    state = true; // loading

    try {
      // Clear any existing token before signup to prevent role conflicts
      await TokenStorage.clearAll();
      developer.log('🗑️ Doctor Signup: Cleared all stored tokens before fresh signup',
          name: 'DoctorSignup');

      final requestBody = model.toJson();
      developer.log('🔵 Doctor Signup Request: $requestBody',
          name: 'DoctorSignup');

      final response = await ApiService().post(
        "/doctor/signup",
        requestBody,
      );

      developer.log('🟢 Doctor Signup Response: $response',
          name: 'DoctorSignup');

      state = false;

      // Backend returns { msg: "...", ... } on success or error
      final msg = response['msg'] as String?;

      // Successful response has 201 status and contains success message
      if (msg != null &&
          (msg.contains('successfully') ||
              msg.contains('signed up') ||
              msg.contains('Account created'))) {
        // Save token if provided
        if (response['token'] != null) {
          await TokenStorage.saveToken(response['token']);
          await TokenStorage.saveUserRole('doctor');
          developer.log('✅ Token saved successfully', name: 'TokenStorage');
        }
        return {
          'success': true,
          'message': msg,
        };
      }

      // Error response
      String errorMsg = msg ?? 'Signup failed. Please try again.';

      // Check if there's detailed error info
      if (response['error'] != null) {
        final error = response['error'];
        if (error is Map) {
          developer.log('🔴 Backend validation error: $error',
              name: 'DoctorSignup');
          final errors = error['errors'] as List?;
          if (errors != null && errors.isNotEmpty) {
            errorMsg =
                '${errors[0]['message']}';
          }
        } else if (error is String) {
          errorMsg = error;
        }
      }

      developer.log('❌ Signup failed: $errorMsg', name: 'DoctorSignup');
      return {'success': false, 'message': errorMsg};
    } catch (e) {
      state = false;
      String errorMessage = 'An error occurred. Please try again.';

      developer.log('🔴 Exception during signup: $e', name: 'DoctorSignup');

      if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Cannot connect to server. Check internet.';
      } else if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }

      developer.log('📋 Final error message: $errorMessage',
          name: 'DoctorSignup');
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<Map<String, dynamic>> loginDoctor(String email, String password) async {
    state = true; // loading

    try {
      // IMPORTANT: Clear any existing token before login to prevent using old patient token
      await TokenStorage.clearAll();
      developer.log('🗑️ Doctor Login: Cleared all stored tokens before fresh login',
          name: 'DoctorLogin');

      final requestBody = {"email": email, "password": password};
      developer.log('🔵 Doctor Login Request: $requestBody',
          name: 'DoctorLogin');

      final response = await ApiService().post(
        "/doctor/signin",
        requestBody,
      );

      developer.log('🟢 Doctor Login Response: $response',
          name: 'DoctorLogin');

      state = false;

      if (response['token'] != null) {
        // Save fresh token and doctor role
        await TokenStorage.saveToken(response['token']);
        await TokenStorage.saveUserRole('doctor');
        developer.log('✅ Doctor Login: Token and role saved successfully',
            name: 'DoctorLogin');
        return {
          'success': true,
          'message': 'Login successful!',
          'token': response['token']
        };
      }
      return {
        'success': false,
        'message': response['msg'] ?? 'Invalid credentials'
      };
    } catch (e) {
      state = false;
      String errorMessage = 'An error occurred. Please try again.';

      developer.log('🔴 Exception during login: $e', name: 'DoctorLogin');

      if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  Future<void> logout() async {
    try {
      developer.log('🗑️ Doctor Logout: Clearing all tokens and user data',
          name: 'DoctorLogout');
      
      // Clear all tokens and user data
      await TokenStorage.clearAll();
      
      developer.log('✅ Doctor Logout: All data cleared successfully',
          name: 'DoctorLogout');
      state = false;
    } catch (e) {
      developer.log('🔴 Error during logout: $e', name: 'DoctorLogout');
    }
  }
}
