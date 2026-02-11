import 'package:flutter/material.dart';
import 'package:wh2o/config/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (index == 2) {
      // ถ้ากดออกจากระบบ ให้โชว์ Dialog ก่อน
      _showLogoutDialog(context);
    } else {
      // สำหรับเมนูอื่นๆ ให้เปลี่ยนหน้าตามปกติ
      switch (index) {
        case 0: Navigator.pushReplacementNamed(context, '/home'); break;
        case 1: Navigator.pushReplacementNamed(context, '/history'); break;
      }
    }
  }
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการออกจากระบบ'),
          content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // ปิด Dialog
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ปิด Dialog
                Navigator.pushReplacementNamed(context, '/login'); // ไปหน้า Login
              },
              child: const Text('ตกลง', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'แดชบอร์ด'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'ประวัติ'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'ออกจากระบบ'),
        ],
      ),
    );
  }
}