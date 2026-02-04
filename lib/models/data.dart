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
      measuredAt: DateTime.parse(json['measured_at']),
    );
  }

  /// Helper: แปลงค่าเป็น int (รองรับทั้ง String และ num)
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.parse(value);
    return 0;
  }

  /// Helper: แปลงค่าเป็น double (รองรับทั้ง String และ num)
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }
}