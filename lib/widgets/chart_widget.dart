// ============================================
// 📊 CHART_WIDGET.DART - กราฟแสดงแนวโน้ม (ตามเวลาจริง)
// ============================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wh2o/models/water_data.dart'; // ตรวจสอบว่า Import Model ถูกต้อง

class SevenDayChart extends StatefulWidget {
  final List<dynamic> waterData;

  const SevenDayChart({super.key, required this.waterData});

  @override
  State<SevenDayChart> createState() => _SevenDayChartState();
}

class _SevenDayChartState extends State<SevenDayChart> {
  int _selectedTab = 0; // 0=Temp, 1=pH, 2=O2, 3=Salinity

  // แปลงข้อมูลและเรียงลำดับ
  List<WaterData> _getChartDataPoints() {
    if (widget.waterData.isEmpty) return [];

    // 1. แปลงเป็น WaterData Objects
    List<WaterData> dataList = widget.waterData.map((d) {
      if (d is WaterData) return d;
      return WaterData.fromJson(d);
    }).toList();

    // 2. เรียงตามเวลา (เก่า -> ใหม่)
    dataList.sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    // 3. ตัดเอาเฉพาะ N ตัวล่าสุด (เช่น 7-10 ตัวล่าสุด) เพื่อให้กราฟไม่แน่นเกินไป
    // ถ้าอยากได้เยอะกว่านี้ แก้เลข 7 เป็น 10 หรือ 20 ได้เลยครับ
    int count = 7;
    if (dataList.length > count) {
      dataList = dataList.sublist(dataList.length - count);
    }

    return dataList;
  }

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
    final chartData = _getChartDataPoints();
    final config = _getTabConfig(_selectedTab);
    final color = config['color'] as Color;

    if (chartData.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('ไม่มีข้อมูลกราฟ')));
    }

    // สร้างจุดกราฟ
    final spots = chartData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final val = (config['getter'] as Function(WaterData))(entry.value) as double;
      return FlSpot(index, val);
    }).toList();

    return Container(
      margin: const EdgeInsets.all(16),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('แนวโน้มล่าสุด', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              Text('${config['label']} (${config['unit']})', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: config['minY'],
                maxY: config['maxY'],
                minX: 0,
                maxX: (chartData.length - 1).toDouble(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (config['maxY'] - config['minY']) / 5,
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)))),

                  // แกนล่าง (เวลา)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1, // โชว์ทุกจุด
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= chartData.length) return const SizedBox();

                        final date = chartData[index].measuredAt;
                        // แสดงเวลา HH:mm (เช่น 12:00)
                        final timeStr = '${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
                  ),
                ],
                // Tooltip แสดงวันและเวลา
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final date = chartData[index].measuredAt;
                        final dateStr = '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2,'0')}';
                        return LineTooltipItem(
                          '$dateStr\n${spot.y.toStringAsFixed(2)} ${config['unit']}',
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

          // Tabs
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

  Widget _buildTabButton(int index, String label, IconData icon, Color color) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Colors.grey),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ]
          ],
        ),
      ),
    );
  }
}