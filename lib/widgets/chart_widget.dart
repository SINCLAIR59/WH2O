// ============================================
// 📊 CHART_WIDGET.DART - กราฟข้อมูล 7 วัน
// ============================================
// Widget นี้แสดงกราฟเส้นย้อนหลัง 7 วัน
// Features:
// - แสดงข้อมูล 4 ค่า: Temperature, pH, Oxygen, Salinity
// - สลับดูแต่ละค่าได้
// - แสดงจุดข้อมูลพร้อมค่า
// - Gradient สวยงาม
// ============================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wh2o/constants/app_colors.dart';

/// Widget กราฟแสดงข้อมูลย้อนหลัง 7 วัน
class SevenDayChart extends StatefulWidget {
  final List<dynamic> waterData; // ข้อมูลทั้งหมดจาก API

  const SevenDayChart({
    Key? key,
    required this.waterData,
  }) : super(key: key);

  @override
  State<SevenDayChart> createState() => _SevenDayChartState();
}

class _SevenDayChartState extends State<SevenDayChart> {
  // ==========================================
  // State Variables
  // ==========================================

  /// Tab ที่เลือกอยู่ (0=Temp, 1=pH, 2=O2, 3=Salt)
  int _selectedTab = 0;

  // ==========================================
  // Helper Methods
  // ==========================================

  /// ดึงข้อมูล 7 วันล่าสุด และจัดกลุ่มตามวัน
  List<Map<String, dynamic>> _getLast7DaysData() {
    if (widget.waterData.isEmpty) return [];

    // สร้าง Map เก็บข้อมูลแต่ละวัน (วัน -> ค่าเฉลี่ย)
    Map<String, List<double>> dayData = {
      'temperature': [],
      'ph': [],
      'oxygen': [],
      'salinity': [],
    };

    // เอาข้อมูลย้อนหลัง 7 วัน (สมมติ API ส่งมาเรียงตามเวลาล่าสุดก่อน)
    final last7Days = widget.waterData.take(7).toList().reversed.toList();

    for (var data in last7Days) {
      dayData['temperature']!.add(_toDouble(data['temperature']));
      dayData['ph']!.add(_toDouble(data['ph']));
      dayData['oxygen']!.add(_toDouble(data['oxygen']));
      dayData['salinity']!.add(_toDouble(data['salinity']));
    }

    // แปลงเป็น List<Map> สำหรับแสดงในกราฟ
    List<Map<String, dynamic>> result = [];
    for (int i = 0; i < last7Days.length; i++) {
      result.add({
        'day': i,
        'temperature': dayData['temperature']![i],
        'ph': dayData['ph']![i],
        'oxygen': dayData['oxygen']![i],
        'salinity': dayData['salinity']![i],
      });
    }

    return result;
  }

  /// แปลงค่าเป็น double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// ข้อมูลของแต่ละ Tab
  Map<String, dynamic> _getTabConfig(int index) {
    switch (index) {
      case 0: // Temperature
        return {
          'label': 'Temperature',
          'unit': '°C',
          'key': 'temperature',
          'color': Colors.orange,
          'gradientColors': [Colors.orange.shade300, Colors.orange.shade600],
          'minY': 20.0,
          'maxY': 35.0,
        };
      case 1: // pH
        return {
          'label': 'pH Level',
          'unit': '',
          'key': 'ph',
          'color': Colors.green,
          'gradientColors': [Colors.green.shade300, Colors.green.shade600],
          'minY': 6.0,
          'maxY': 9.0,
        };
      case 2: // Oxygen
        return {
          'label': 'Oxygen',
          'unit': 'mg/L',
          'key': 'oxygen',
          'color': Colors.blue,
          'gradientColors': [Colors.blue.shade300, Colors.blue.shade600],
          'minY': 4.0,
          'maxY': 8.0,
        };
      case 3: // Salinity
        return {
          'label': 'Salinity',
          'unit': 'ppt',
          'key': 'salinity',
          'color': Colors.purple,
          'gradientColors': [Colors.purple.shade300, Colors.purple.shade600],
          'minY': 10.0,
          'maxY': 20.0,
        };
      default:
        return _getTabConfig(0);
    }
  }

  /// สร้างข้อมูลจุดบนกราฟ
  List<FlSpot> _getChartData() {
    final data = _getLast7DaysData();
    final config = _getTabConfig(_selectedTab);
    final key = config['key'];

    return data.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        _toDouble(entry.value[key]),
      );
    }).toList();
  }

  // ==========================================
  // Build Method
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final config = _getTabConfig(_selectedTab);
    final chartData = _getChartData();

    // ถ้าไม่มีข้อมูล แสดงข้อความ
    if (chartData.isEmpty) {
      return Container(
        height: 300,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'ไม่มีข้อมูลย้อนหลัง',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // ส่วนหัว: ชื่อกราฟ
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '7 Days History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config['label'],
                    style: TextStyle(
                      fontSize: 14,
                      color: config['color'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // แสดงค่าล่าสุด
              if (chartData.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (config['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${chartData.last.y.toStringAsFixed(1)} ${config['unit']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: config['color'],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ==========================================
          // กราฟ
          // ==========================================
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                // กำหนดช่วงข้อมูล
                minY: config['minY'],
                maxY: config['maxY'],
                minX: 0,
                maxX: chartData.length - 1.0,

                // ตั้งค่า Grid
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (config['maxY'] - config['minY']) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),

                // ตั้งค่าขอบ
                titlesData: FlTitlesData(
                  // แกน Y (ซ้าย)
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: (config['maxY'] - config['minY']) / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                  // แกน X (ล่าง)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // แสดง "Day 1", "Day 2", ...
                        final dayNum = value.toInt() + 1;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Day $dayNum',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ซ่อนแกนอื่น
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                // ซ่อนเส้นขอบ
                borderData: FlBorderData(show: false),

                // ตั้งค่าเส้นกราฟ
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: config['color'],
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: config['color'],
                        );
                      },
                    ),
                    // Gradient ใต้เส้น
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (config['color'] as Color).withOpacity(0.3),
                          (config['color'] as Color).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],

                // แสดงค่าเมื่อแตะ
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} ${config['unit']}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ==========================================
          // Tab สำหรับเลือกดูข้อมูล
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton(0, 'Temp', Icons.thermostat, Colors.orange),
              _buildTabButton(1, 'pH', Icons.water_drop, Colors.green),
              _buildTabButton(2, 'O₂', Icons.air, Colors.blue),
              _buildTabButton(3, 'Salt', Icons.grain, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  /// สร้างปุ่ม Tab
  Widget _buildTabButton(int index, String label, IconData icon, Color color) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}