import 'package:dio/dio.dart';
import 'package:frontend/patient/services/tokenstorage.dart';

class FcmApi {
  // Use the production URL; this avoids emulator connection issues
  static const String baseUrl = 'https://team-orbital.onrender.com/doctor';

  /// Registers the FCM token for the currently logged-in doctor
  static Future<void> registerToken(String fcmToken) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      print('Cannot register FCM Token: Doctor is not authenticated');
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/fcm',
        data: {'fcmToken': fcmToken},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        print('Successfully registered FCM Token to backend');
      } else {
        print('Failed to register FCM Token. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error registering FCM Token: $e');
    }
  }
}
