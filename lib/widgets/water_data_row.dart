import 'package:flutter/material.dart';
import 'package:wh2o/config/app_colors.dart';

class WaterDataRow extends StatelessWidget {
  final String label;    // ชื่อข้อมูล (เช่น "Temperature")
  final String value;    // ค่า (เช่น "28.5°C")
  final IconData icon;   // ไอคอน

  const WaterDataRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // ระยะห่างแนวตั้ง
      child: Row(
        children: [
          // Icon สีฟ้า
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 12),

          // Label (ชื่อข้อมูล)
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const Spacer(), // ดันค่าไปขวาสุด

          // Value (ค่าตัวเลข)
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}