// ============================================
// 🌐 SERVICE.DART - จัดการ API และ Cache
// ============================================
// ไฟล์นี้ทำหน้าที่:
// 1. ดึงข้อมูลจาก API
// 2. จัดการ Cache (เก็บข้อมูลไว้ไม่ต้องดึงซ้ำ)
// 3. จัดการ Error
//
// Cache มี 2 ระดับ:
// - Memory Cache: เก็บในแรม (เร็วที่สุด แต่หายเมื่อปิดแอป)
// - Local Cache: เก็บในเครื่อง (ช้ากว่า แต่อยู่ถาวร)
// ============================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service สำหรับจัดการข้อมูลคุณภาพน้ำ
class WaterService {
  // ==========================================
  // ค่าคงที่ (Constants)
  // ==========================================

  /// Key สำหรับเก็บ cache ใน Local Storage
  static const _cacheKey = 'water_cache';

  /// URL ของ API ที่ดึงข้อมูล
  static const _apiUrl = 'https://home.kongyot.online/api/water_list.php?limit=9999';

  /// API Key สำหรับยืนยันตัวตน
  static const _apiKey = 'y4VkYh2l6e7oxvMZuRSfCKtOcuQuZcJrlWjQLXK9plaFwJxQkNlrHbzz9Pb9cSVd';

  // ==========================================
  // ตัวแปร Cache
  // ==========================================

  /// Memory Cache - เก็บข้อมูลในแรม (เร็วมาก แต่หายเมื่อปิดแอป)
  static List<dynamic>? _memoryCache;

  // ==========================================
  // Methods (ฟังก์ชัน)
  // ==========================================

  /// ดึงข้อมูลทั้งหมด (ใช้ cache ก่อนเพื่อความเร็ว)
  ///
  /// ลำดับการทำงาน:
  /// 1. เช็ค Memory Cache → ถ้ามี ใช้เลย (เร็วที่สุด)
  /// 2. เช็ค Local Cache → ถ้ามี ใช้เลย (เร็วรองลงมา)
  /// 3. ดึงจาก API → ถ้าไม่มี cache (ช้าที่สุด)
  ///
  /// Returns: List ของข้อมูลน้ำทั้งหมด
  static Future<List<dynamic>> fetchAll() async {
    try {
      // ==========================================
      // ขั้นที่ 1: เช็ค Memory Cache
      // ==========================================
      if (_memoryCache != null) {
        print('✅ Using memory cache (${_memoryCache!.length} records)');
        return _memoryCache!; // มี cache ในแรม → คืนเลย (เร็วมาก!)
      }

      // ==========================================
      // ขั้นที่ 2: เช็ค Local Cache
      // ==========================================
      final prefs = await SharedPreferences.getInstance(); // เปิด Local Storage
      final cached = prefs.getString(_cacheKey);           // อ่านข้อมูล cache

      if (cached != null) {
        print('✅ Using local cache');
        final decoded = jsonDecode(cached) as List<dynamic>; // แปลง JSON เป็น List
        _memoryCache = decoded;  // เก็บใน Memory Cache ด้วย (ครั้งต่อไปจะเร็วขึ้น)
        return decoded;
      }

      // ==========================================
      // ขั้นที่ 3: ดึงจาก API (ไม่มี cache)
      // ==========================================
      print('🔄 Fetching from API: $_apiUrl');

      // ส่ง HTTP GET request พร้อม headers
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'X-API-KEY': _apiKey,              // ส่ง API Key ไปด้วย
          'Content-Type': 'application/json', // บอกว่าต้องการ JSON
        },
      ).timeout(
        const Duration(seconds: 10),  // ถ้าเกิน 10 วินาที ให้หมดเวลา
        onTimeout: () {
          throw Exception('API timeout after 10 seconds');
        },
      );

      // ==========================================
      // ตรวจสอบ Response
      // ==========================================
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body length: ${response.body.length}');

      // ถ้า status code ไม่ใช่ 200 (OK) → Error
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      // ถ้า response ว่างเปล่า → Error
      if (response.body.isEmpty) {
        throw Exception('Empty response from API');
      }

      // ==========================================
      // แปลง JSON และตรวจสอบรูปแบบ
      // ==========================================
      final json = jsonDecode(response.body);

      // ตรวจสอบว่ามี key "data" หรือไม่
      if (json is! Map || !json.containsKey('data')) {
        print('⚠️ Unexpected response format');
        throw Exception('API response missing "data" key');
      }

      final data = json['data'];

      // ตรวจสอบว่า data เป็น List หรือไม่
      if (data is! List) {
        throw Exception('Invalid data format. Expected List, got: ${data.runtimeType}');
      }

      print('✅ Fetched ${data.length} records from API');
      if (data.isNotEmpty) {
        print('📊 Sample record: ${data.first}');
      }

      // ==========================================
      // บันทึก Cache (ทั้ง Memory และ Local)
      // ==========================================
      _memoryCache = data;  // เก็บใน Memory Cache
      await prefs.setString(_cacheKey, jsonEncode(data)); // เก็บใน Local Cache

      return data;

    } catch (e, stackTrace) {
      // ==========================================
      // จัดการ Error
      // ==========================================
      print('❌ Error in fetchAll: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow; // โยน Error ออกไปให้ผู้เรียกจัดการต่อ
    }
  }

  /// ล้าง cache ทั้งหมด
  /// ใช้เมื่อ: Pull to refresh หรือต้องการข้อมูลใหม่
  ///
  /// การทำงาน:
  /// 1. ลบ Memory Cache
  /// 2. ลบ Local Cache
  /// 3. ครั้งต่อไปที่เรียก fetchAll() จะดึงจาก API ใหม่
  static Future<void> clearCache() async {
    print('🗑️ Clearing cache...');

    _memoryCache = null;  // ลบ Memory Cache

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);  // ลบ Local Cache

    print('✅ Cache cleared');
  }
}