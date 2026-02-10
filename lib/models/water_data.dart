// lib/models/water_data.dart
class WaterData {
  final int id;
  final double temperature;
  final double ph;
  final double oxygen;
  final double salinity;
  final DateTime measuredAt;

  WaterData({
    required this.id,
    required this.temperature,
    required this.ph,
    required this.oxygen,
    required this.salinity,
    required this.measuredAt,
  });

  factory WaterData.fromJson(Map<String, dynamic> json) {
    return WaterData(
      // เช็คค่า id (ถ้าเป็น null ให้เป็น 0)
      id: _toInt(json['id']),

      // แปลง String "29.00" -> Double 29.0
      temperature: _toDouble(json['temperature']),
      ph: _toDouble(json['ph']),
      oxygen: _toDouble(json['oxygen']),
      salinity: _toDouble(json['salinity']),

      // แปลง String วันที่ -> DateTime Object
      measuredAt: DateTime.tryParse(json['measured_at'] ?? '') ?? DateTime.now(),
    );
  }

  // --- Helper Methods ---

  // แปลงเป็น Int อย่างปลอดภัย
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // แปลงเป็น Double อย่างปลอดภัย (รองรับทั้ง String และ Number)
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    // กรณีค่ามาเป็น String เช่น "29.00"
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}