// ============================================
// 📋 WATER_LIST_PAGE.DART - หน้ารายการข้อมูล
// ============================================
// หน้านี้แสดงรายการข้อมูลคุณภาพน้ำทั้งหมด
// 
// Features:
// - แสดงข้อมูลย้อนหลังทั้งหมด
// - Pull to refresh (ดึงลงเพื่ออัพเดท)
// - Loading state
// - Error handling
// - Empty state
// ============================================

import 'package:flutter/material.dart';
import 'package:wh2o/services/service.dart';
import 'package:wh2o/config/app_colors.dart';
import 'package:wh2o/widgets/sensor_card.dart';
import 'package:wh2o/widgets/water_data_row.dart';
/// หน้าแสดงรายการข้อมูลทั้งหมด
class WaterListPage extends StatefulWidget {
  const WaterListPage({super.key});

  @override
  State<WaterListPage> createState() => _WaterListPageState();
}

class _WaterListPageState extends State<WaterListPage> {
  // ==========================================
  // State Variables
  // ==========================================
  
  /// Future สำหรับดึงข้อมูล
  /// เก็บไว้เป็นตัวแปรเพื่อไม่ให้เรียก API ซ้ำทุกครั้งที่ rebuild
  late Future<List<dynamic>> _futureWater;

  // ==========================================
  // Lifecycle Methods
  // ==========================================
  
  @override
  void initState() {
    super.initState();
    // เรียก API แค่ครั้งเดียวตอน init
    _futureWater = WaterService.fetchAll();
  }

  // ==========================================
  // Helper Methods
  // ==========================================
  
  /// ฟังก์ชัน Refresh ข้อมูล
  /// เรียกใช้เมื่อ: Pull to refresh หรือกดปุ่ม refresh
  Future<void> _refreshData() async {
    await WaterService.clearCache();  // ลบ cache เก่า
    setState(() {
      _futureWater = WaterService.fetchAll();  // สร้าง Future ใหม่
    });
  }

  // ==========================================
  // Build Method
  // ==========================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ==========================================
      // App Bar
      // ==========================================
      appBar: AppBar(
        title: const Text('Water Data List'),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          // ปุ่ม Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      
      // ==========================================
      // Body - FutureBuilder
      // ==========================================
      // FutureBuilder จะจัดการ 3 สถานะ:
      // 1. Loading (กำลังดึงข้อมูล)
      // 2. Error (เกิดข้อผิดพลาด)
      // 3. Success (ได้ข้อมูลแล้ว)
      body: FutureBuilder<List<dynamic>>(
        future: _futureWater,
        builder: (context, snapshot) {
          
          // ==========================================
          // สถานะที่ 1: Loading
          // ==========================================
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ==========================================
          // สถานะที่ 2: Error
          // ==========================================
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Error
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  
                  // ข้อความ Error
                  Text(
                    'เกิดข้อผิดพลาด: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // ปุ่มลองใหม่
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          // ==========================================
          // สถานะที่ 3a: Empty (ไม่มีข้อมูล)
          // ==========================================
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    color: Colors.grey,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ไม่มีข้อมูล',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ==========================================
          // สถานะที่ 3b: Success (มีข้อมูล)
          // ==========================================
          final waters = snapshot.data!;  // ข้อมูลทั้งหมด
          
          return RefreshIndicator(
            onRefresh: _refreshData,  // Pull to refresh
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: waters.length,  // จำนวนรายการ
              
              // ==========================================
              // สร้างการ์ดแต่ละรายการ
              // ==========================================
              itemBuilder: (context, index) {
                final water = waters[index];  // ข้อมูลแต่ละตัว
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==========================================
                        // ส่วนบน: หมายเลขและเวลา
                        // ==========================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // หมายเลข Record
                            Text(
                              'Record #${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            // เวลาที่วัด
                            Text(
                              water['measured_at'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        
                        const Divider(height: 20),
                        
                        // ==========================================
                        // ข้อมูลแต่ละตัว
                        // ==========================================
                        // ใช้ WaterDataRow widget สำหรับแสดงข้อมูล
                        
                        // อุณหภูมิ
                        WaterDataRow(
                          label: 'Temperature',
                          value: '${water['temperature'] ?? 'N/A'}°C',
                          icon: Icons.thermostat,
                        ),
                        
                        // ค่า pH
                        WaterDataRow(
                          label: 'pH',
                          value: '${water['ph'] ?? 'N/A'}',
                          icon: Icons.water_drop,
                        ),
                        
                        // ออกซิเจน
                        WaterDataRow(
                          label: 'Oxygen',
                          value: '${water['oxygen'] ?? 'N/A'} mg/L',
                          icon: Icons.water,
                        ),
                        
                        // ความเค็ม
                        WaterDataRow(
                          label: 'Salinity',
                          value: '${water['salinity'] ?? 'N/A'} ppt',
                          icon: Icons.grain,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}