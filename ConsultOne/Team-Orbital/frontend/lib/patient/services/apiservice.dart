import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://team-orbital.onrender.com";
  static const Duration timeout = Duration(seconds: 30);

  /// Submit consultation form with optional file (multipart). [fileBytes] and [fileName] can be null if no file.
  Future<Map<String, dynamic>> postForm(
    String endpoint,
    Map<String, String> fields, {
    String? token,
    List<int>? fileBytes,
    String? fileName,
    String fileFieldName = 'patientForm',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl$endpoint"),
      );
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      for (final e in fields.entries) {
        request.fields[e.key] = e.value;
      }
      if (fileBytes != null && fileBytes.isNotEmpty && fileName != null && fileName.isNotEmpty) {
        request.files.add(http.MultipartFile.fromBytes(
          fileFieldName,
          fileBytes,
          filename: fileName,
        ));
      }
      final streamed = await request.send().timeout(
        timeout,
        onTimeout: () {
          throw Exception(
            'Request timeout - backend may be starting up, please try again',
          );
        },
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 400) {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(
            errorData["error"] ?? 'Error: ${response.statusCode}',
          );
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Error: ${response.statusCode} - ${response.body}');
        }
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl$endpoint"),
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
            body: jsonEncode(body),
          )
          .timeout(
            timeout,
            onTimeout: () {
              throw Exception(
                'Request timeout - backend may be starting up, please try again',
              );
            },
          );

      if (response.statusCode >= 400) {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(
            errorData["error"] ?? 'Error: ${response.statusCode}',
          );
        } catch (e) {
          throw Exception('Error: ${response.statusCode} - ${response.body}');
        }
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl$endpoint"),
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
          )
          .timeout(
            timeout,
            onTimeout: () {
              throw Exception(
                'Request timeout - backend may be starting up, please try again',
              );
            },
          );

      if (response.statusCode >= 400) {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(
            errorData["error"] ?? 'Error: ${response.statusCode}',
          );
        } catch (e) {
          throw Exception('Error: ${response.statusCode} - ${response.body}');
        }
      }

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl$endpoint"),
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
            body: jsonEncode(body),
          )
          .timeout(
            timeout,
            onTimeout: () {
              throw Exception(
                'Request timeout - backend may be starting up, please try again',
              );
            },
          );

      if (response.statusCode >= 400) {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(
            errorData["error"] ?? 'Error: ${response.statusCode}',
          );
        } catch (e) {
          throw Exception('Error: ${response.statusCode} - ${response.body}');
        }
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
