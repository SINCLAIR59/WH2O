import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wh2o/config/app_config.dart';

class WaterService {
  static const _cacheKey = 'water_cache';

  // Cache ใน Memory (RAM)
  static List<dynamic>? _memoryCache;

  // ดึงข้อมูลทั้งหมด
  static Future<List<dynamic>> fetchAll() async {
    try {
      // 1. ลองดึงจาก Memory ก่อน (ถ้ามี)
      if (_memoryCache != null && _memoryCache!.isNotEmpty) return _memoryCache!;

      // 2. ถ้าไม่มีใน RAM ให้ลองดึงจาก API
      final response = await http.get(
        Uri.parse(AppConfig.apiUrl),
        // ✅ [แก้ไข] ต้องเปิดบรรทัดนี้ เพื่อส่งกุญแจให้ Server
        headers: {'X-API-KEY': AppConfig.apiKey},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // เช็ค Status และดึงข้อมูลจาก key "data"
        if (json['status'] == 'ok' && json['data'] != null) {
          final List<dynamic> data = json['data'];

          // บันทึก Cache
          _memoryCache = data;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, jsonEncode(data));

          return data;
        } else {
          return [];
        }
      } else {
        // แจ้งเตือนถ้า Server Error (เช่น 401, 404, 500)
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      // 3. ถ้าเน็ตหลุด/Server พัง ให้ลองดึงจาก Local Storage (ข้อมูลเก่า)
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        _memoryCache = jsonDecode(cached);
        return _memoryCache!;
      }
      rethrow;
    }
  }

  // ล้าง Cache (ใช้เมื่อกด Refresh)
  static Future<void> clearCache() async {
    _memoryCache = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}