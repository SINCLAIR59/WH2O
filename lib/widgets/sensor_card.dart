// ============================================
// 🧩 SENSOR_CARD.DART - Widgets ที่ใช้ซ้ำ
// ============================================
// ไฟล์นี้เก็บ Widget ที่ใช้ซ้ำได้หลายที่
// ประกอบด้วย:
// 1. SensorCard - การ์ดแสดงค่า sensor
// 2. WaterDataRow - แถวแสดงข้อมูล
// 3. NavItem - ปุ่ม navigation
// 
// ข้อดี:
// - เขียนครั้งเดียว ใช้ได้หลายที่
// - แก้ไขที่เดียว ทุกที่เปลี่ยน
// ============================================

import 'package:flutter/material.dart';
import 'package:wh2o/constants/app_colors.dart';

// ============================================
// 1️⃣ SENSOR CARD - การ์ดแสดงค่า Sensor
// ============================================

/// การ์ดสำหรับแสดงค่า Sensor (Oxygen, Salinity)
/// 
/// ประกอบด้วย:
/// - Icon พร้อม gradient สี
/// - ชื่อ sensor
/// - ค่าที่วัดได้ (ตัวเลขใหญ่)
/// - หน่วย (mg/L, ppt)
/// - Badge สถานะ (Excellent, Good, etc.)
/// 
/// ตัวอย่างการใช้:
/// ```dart
/// SensorCard(
///   label: 'Oxygen',
///   value: '6.5',
///   unit: 'mg/L',
///   icon: Icons.water,
///   status: 'Excellent',
///   statusColors: AppColors.excellentGradient,
/// )
/// ```
class SensorCard extends StatelessWidget {
  final String label;           // ชื่อ sensor (เช่น "Oxygen")
  final String value;           // ค่าที่วัดได้ (เช่น "6.5")
  final String unit;            // หน่วย (เช่น "mg/L")
  final IconData icon;          // ไอคอน
  final String status;          // สถานะ (เช่น "Excellent")
  final List<Color> statusColors; // สีของ gradient

  const SensorCard({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.status,
    required this.statusColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // ส่วนบน: Icon + Label
          // ==========================================
          Row(
            children: [
              // Icon พร้อม gradient background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: statusColors,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              // ชื่อ sensor
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          // ==========================================
          // ส่วนกลาง: ค่าที่วัดได้ + หน่วย
          // ==========================================
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ค่าที่วัดได้ (ตัวเลขใหญ่)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(width: 4),
              // หน่วย (ตัวเล็ก)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          // ==========================================
          // ส่วนล่าง: Badge สถานะ
          // ==========================================
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: statusColors,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// 2️⃣ WATER DATA ROW - แถวแสดงข้อมูล
// ============================================

/// แถวข้อมูลแบบง่าย สำหรับแสดงในรายการ
/// 
/// ประกอบด้วย:
/// - Icon
/// - Label (ชื่อข้อมูล)
/// - Value (ค่าที่วัดได้)
/// 
/// ตัวอย่างการใช้:
/// ```dart
/// WaterDataRow(
///   label: 'Temperature',
///   value: '28.5°C',
///   icon: Icons.thermostat,
/// )
/// ```
class WaterDataRow extends StatelessWidget {
  final String label;    // ชื่อข้อมูล (เช่น "Temperature")
  final String value;    // ค่า (เช่น "28.5°C")
  final IconData icon;   // ไอคอน

  const WaterDataRow({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Icon
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          
          // Label (ขยายเต็มพื้นที่)
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          
          // Value (ด้านขวาสุด)
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// 3️⃣ NAV ITEM - ปุ่ม Navigation
// ============================================

/// ปุ่ม Navigation ที่แสดงด้านล่าง
/// 
/// มี 2 สถานะ:
/// - Selected: สีน้ำเงิน, ตัวหนา
/// - Not Selected: สีเทา, ตัวปกติ
/// 
/// ตัวอย่างการใช้:
/// ```dart
/// NavItem(
///   icon: Icons.thermostat,
///   label: 'Temp',
///   index: 0,
///   selectedIndex: _selectedTab,
///   onTap: () => setState(() => _selectedTab = 0),
/// )
/// ```
class NavItem extends StatelessWidget {
  final IconData icon;       // ไอคอน
  final String label;        // ชื่อ (เช่น "Temp")
  final int index;           // ลำดับของปุ่มนี้
  final int selectedIndex;   // ลำดับปุ่มที่กำลังเลือกอยู่
  final VoidCallback onTap;  // ฟังก์ชันที่จะทำงานเมื่อกด

  const NavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // เช็คว่าปุ่มนี้ถูกเลือกอยู่หรือไม่
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: onTap,  // เมื่อกดจะทำงานตาม callback
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon (สีเปลี่ยนตามสถานะ)
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBlue : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            
            // Label (สีและน้ำหนักเปลี่ยนตามสถานะ)
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryBlue : Colors.grey[400],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}