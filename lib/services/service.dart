import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WaterService {
  static const _cacheKey = 'water_cache';
  static const _apiUrl =
      'https://home.kongyot.online/api/water_list.php?limit=9999';
  static const _apiKey = 'y4VkYh2l6e7oxvMZuRSfCKtOcuQuZcJrlWjQLXK9plaFwJxQkNlrHbzz9Pb9cSVd';

  static List<dynamic>? _memoryCache;

  /// โหลดข้อมูล (ใช้ cache ก่อน)
  static Future<List<dynamic>> fetchAll() async {
    try {
      // 1. Memory cache
      if (_memoryCache != null) {
        print('✅ Using memory cache (${_memoryCache!.length} records)');
        return _memoryCache!;
      }

      // 2. Local cache
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        print('✅ Using local cache');
        final decoded = jsonDecode(cached) as List<dynamic>;
        _memoryCache = decoded;
        return decoded;
      }

      // 3. API
      print('🔄 Fetching from API: $_apiUrl');
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'X-API-KEY': _apiKey,
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('API timeout after 10 seconds');
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body length: ${response.body.length}');

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      if (response.body.isEmpty) {
        throw Exception('Empty response from API');
      }

      final json = jsonDecode(response.body);

      if (json is! Map || !json.containsKey('data')) {
        print('⚠️ Unexpected response format');
        throw Exception('API response missing "data" key');
      }

      final data = json['data'];

      if (data is! List) {
        throw Exception('Invalid data format. Expected List, got: ${data.runtimeType}');
      }

      print('✅ Fetched ${data.length} records from API');
      if (data.isNotEmpty) {
        print('📊 Sample record: ${data.first}');
      }

      // save cache
      _memoryCache = data;
      await prefs.setString(_cacheKey, jsonEncode(data));

      return data;
    } catch (e, stackTrace) {
      print('❌ Error in fetchAll: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// ล้าง cache (เช่น pull to refresh)
  static Future<void> clearCache() async {
    print('🗑️ Clearing cache...');
    _memoryCache = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    print('✅ Cache cleared');
  }
}