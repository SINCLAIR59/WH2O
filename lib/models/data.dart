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
      id: _toInt(json['id']),
      temperature: _toDouble(json['temperature']),
      ph: _toDouble(json['ph']),
      oxygen: _toDouble(json['oxygen']),
      salinity: _toDouble(json['salinity']),
      measuredAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper เพื่อป้องกัน Error เวลา Server ส่ง String มาแทนตัวเลข
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}