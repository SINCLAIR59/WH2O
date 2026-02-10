import 'package:flutter/material.dart';
import 'package:wh2o/config/app_colors.dart';
import 'package:wh2o/models/water_data.dart';
import 'package:wh2o/utils/status_helper.dart'; // ตรวจสอบว่ามีไฟล์นี้ หรือใช้ logic สีด้านล่าง

class DataDetailPage extends StatelessWidget {
  final WaterData data;

  const DataDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('รายละเอียดข้อมูล'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- ส่วนหัว: วันที่และเวลา ---
            Container(
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
                children: [
                  Text(
                    'บันทึก #${data.id}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.measuredAt.toString().substring(0, 19), // แสดงวันที่และเวลาครบ
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- การ์ดแสดงค่าต่างๆ ---

            // 1. อุณหภูมิ
            _buildDetailCard(
              title: 'อุณหภูมิ',
              value: '${data.temperature}',
              unit: '°C',
              icon: Icons.thermostat,
              color: Colors.orange,
              status: 'ปกติ', // ใส่ Logic เช็คสถานะเพิ่มได้
            ),

            const SizedBox(height: 16),

            // 2. pH (ใช้ StatusHelper ถ้ามี หรือเขียน Logic เอง)
            _buildDetailCard(
              title: 'pH',
              value: '${data.ph}',
              unit: '',
              icon: Icons.water_drop,
              color: _getPhColor(data.ph),
              status: _getPhStatus(data.ph),
            ),

            const SizedBox(height: 16),

            // 3. ออกซิเจน
            _buildDetailCard(
              title: 'ออกซิเจน (DO)',
              value: '${data.oxygen}',
              unit: 'mg/L',
              icon: Icons.air,
              color: _getOxygenColor(data.oxygen),
              status: _getOxygenStatus(data.oxygen),
            ),

            const SizedBox(height: 16),

            // 4. ความเค็ม
            _buildDetailCard(
              title: 'ความเค็ม',
              value: '${data.salinity}',
              unit: 'ppt',
              icon: Icons.grain,
              color: Colors.purple,
              status: 'ปกติ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 6)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),

          // Data
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(unit, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic สีและสถานะ (ใส่ไว้ในหน้านี้เลยเพื่อความชัวร์) ---

  String _getPhStatus(double ph) {
    if (ph >= 7.5 && ph <= 8.5) return 'ดีที่สุด';
    if (ph >= 7.0 && ph < 7.5) return 'ดีมาก';
    if (ph >= 6.5 && ph < 7.0) return 'ดี';
    return 'ควรปรับปรุง';
  }

  Color _getPhColor(double ph) {
    if (ph >= 7.5 && ph <= 8.5) return const Color(0xFF00C853);
    if (ph >= 7.0 && ph < 7.5) return const Color(0xFF64DD17);
    if (ph >= 6.5 && ph < 7.0) return const Color(0xFFFFAB00);
    return const Color(0xFFFF3D00);
  }

  String _getOxygenStatus(double oxygen) {
    if (oxygen >= 6.5) return 'ดีเยี่ยม';
    if (oxygen >= 6.0) return 'ดีมาก';
    if (oxygen >= 5.5) return 'ดี';
    return 'ต่ำ';
  }

  Color _getOxygenColor(double oxygen) {
    if (oxygen >= 6.5) return const Color(0xFF2962FF); // สีน้ำเงินเข้ม
    if (oxygen >= 6.0) return const Color(0xFF448AFF);
    if (oxygen >= 5.5) return const Color(0xFF82B1FF);
    return const Color(0xFFB0BEC5);
  }
}