import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://sih2k25.onrender.com/api";

  // ---------------- SIGNUP ----------------
  static Future<Map<String, dynamic>> signupUser(
    String name,
    String email,
    String password,
    String language,
    String className,
  ) async {
    final url = Uri.parse("$baseUrl/signup");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "language": language,
        "className": className,
      }),
    );

    print("Signup response (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Signup failed: ${response.body}");
    }
  }

  // ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    print("Login response (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }
}
