import 'package:flutter/material.dart';
import 'package:wh2o/config/app_colors.dart';
import 'package:wh2o/models/water_data.dart';
import 'package:wh2o/pages/data_detail_page.dart';
import 'package:wh2o/widgets/daily_chart.dart'; // ✅ Import Widget กราฟใหม่

class DailyLevelPage extends StatelessWidget {
  final String dateLabel;
  final List<WaterData> dailyRecords;

  const DailyLevelPage({
    super.key,
    required this.dateLabel,
    required this.dailyRecords,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('ข้อมูลวันที่ $dateLabel'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView( // เปลี่ยนเป็น SingleChildScrollView เพื่อให้เลื่อนได้ทั้งหน้า
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 📊 ส่วนกราฟ (แสดงเฉพาะเมื่อมีข้อมูล)
            if (dailyRecords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DailyChart(dailyData: dailyRecords),
              ),

            const SizedBox(height: 16),

            // หัวข้อรายการ
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('รายการช่วงเวลา', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),

            // 📋 รายการข้อมูล (ListView.builder ใน Column ต้องใช้ shrinkWrap)
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(), // ปิด Scroll ของ List ให้ไปใช้ Scroll หลักแทน
              shrinkWrap: true,
              itemCount: dailyRecords.length,
              itemBuilder: (context, index) {
                final data = dailyRecords[index];
                final timeString = data.measuredAt.toString().split(' ')[1].substring(0, 5);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.access_time, color: AppColors.primaryBlue),
                    ),
                    title: Text('เวลา $timeString น.', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('pH: ${data.ph}  |  Temp: ${data.temperature}°C'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DataDetailPage(data: data)),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}