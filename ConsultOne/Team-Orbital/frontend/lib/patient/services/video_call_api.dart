import 'package:frontend/patient/services/tokenstorage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/patient/services/apiservice.dart';

class VideoCallApi {
  static final ApiService _api = ApiService();

  static Future<void> requestVideoCall(String doctorId, String consultationId) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('Patient not authenticated');
    }

    try {
      final response = await _api.post(
        '/patient/request-video-call',
        {
          'doctorId': doctorId,
          'consultationId': consultationId,
        },
        token: token,
      );

      if (response['meetLink'] != null) {
        final meetLink = response['meetLink'];
        final Uri url = Uri.parse(meetLink);
        
        // Launch Jitsi / Meet Link for the Patient
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not launch video call link');
        }
      } else {
         throw Exception('Failed to get video call link');
      }
    } catch (e) {
      throw Exception('Failed to request video call: $e');
    }
  }
}
