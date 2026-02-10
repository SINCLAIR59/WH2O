import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wh2o/models/water_data.dart';

class DailyChart extends StatefulWidget {
  final List<WaterData> dailyData;

  const DailyChart({super.key, required this.dailyData});

  @override
  State<DailyChart> createState() => _DailyChartState();
}

class _DailyChartState extends State<DailyChart> {
  int _selectedTab = 0; // 0=Temp, 1=pH, 2=O2, 3=Salinity

  // ตั้งค่าสีและช่วงข้อมูลของแต่ละ Tab
  Map<String, dynamic> _getTabConfig(int index) {
    switch (index) {
      case 0: return {
        'label': 'อุณหภูมิ', 'unit': '°C',
        'color': Colors.orange, 'minY': 20.0, 'maxY': 40.0,
        'getter': (WaterData d) => d.temperature
      };
      case 1: return {
        'label': 'pH', 'unit': '',
        'color': Colors.green, 'minY': 5.0, 'maxY': 10.0,
        'getter': (WaterData d) => d.ph
      };
      case 2: return {
        'label': 'ออกซิเจน', 'unit': 'mg/L',
        'color': Colors.blue, 'minY': 0.0, 'maxY': 10.0,
        'getter': (WaterData d) => d.oxygen
      };
      case 3: return {
        'label': 'ความเค็ม', 'unit': 'ppt',
        'color': Colors.purple, 'minY': 0.0, 'maxY': 30.0,
        'getter': (WaterData d) => d.salinity
      };
      default: return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getTabConfig(_selectedTab);
    final color = config['color'] as Color;

    // เรียงข้อมูลตามเวลา
    final sortedData = List<WaterData>.from(widget.dailyData)
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    // สร้างจุดกราฟ (กรองเอาเฉพาะข้อมูลช่วง 06:00 - 18:00 มาแสดง)
    final spots = sortedData.where((data) {
      final hour = data.measuredAt.hour;
      return hour >= 6 && hour <= 18; // ✅ กรองข้อมูลเฉพาะช่วงเวลาที่กำหนด
    }).map((data) {
      final x = data.measuredAt.hour + (data.measuredAt.minute / 60.0);
      final y = (config['getter'] as Function(WaterData))(data) as double;
      return FlSpot(x, y);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Header กราฟ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ช่วงเวลา 06:00 - 18:00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              Text('${config['label']} (${config['unit']})', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),

          // ตัวกราฟ
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                // ✅ กำหนดช่วงแกน X เป็น 6 ถึง 18
                minX: 6,
                maxX: 18,

                minY: config['minY'],
                maxY: config['maxY'],

                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (config['maxY'] - config['minY']) / 5
                ),

                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 3, // ✅ แสดงเลขแกน X ทุกๆ 3 ชั่วโมง (6, 9, 12, 15, 18)
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('${value.toInt()}:00', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final hour = spot.x.floor();
                        final minute = ((spot.x - hour) * 60).round();
                        final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                        return LineTooltipItem(
                          '$timeStr น.\n${spot.y.toStringAsFixed(2)} ${config['unit']}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ปุ่มเลือก Tab
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabIcon(0, Icons.thermostat, Colors.orange),
              _buildTabIcon(1, Icons.water_drop, Colors.green),
              _buildTabIcon(2, Icons.air, Colors.blue),
              _buildTabIcon(3, Icons.grain, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabIcon(int index, IconData icon, Color color) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: color) : null,
        ),
        child: Icon(icon, color: isSelected ? color : Colors.grey),
      ),
    );
  }
}