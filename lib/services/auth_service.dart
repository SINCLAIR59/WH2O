import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ⚠️ เช็ค URL ให้ตรงกับ Server ของคุณ
  static const String _baseUrl = 'https://home.kongyot.online/api';

  // --- Login ---
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login.php'),
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', data['user']['id'].toString());
        await prefs.setString('username', data['user']['username']);
        await prefs.setString('email', data['user']['email']);
        await prefs.setString('role', data['user']['role']);
      }

      return data;
    } catch (e) {
      return {"status": "error", "message": "Connection error: $e"};
    }
  }

  // --- Register (เพิ่มส่วนนี้เข้าไปครับ) ---
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register.php'),
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Connection error: $e"};
    }
  }

  // --- Logout ---
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // --- Check Role ---
  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    return role == 'admin';
  }
}