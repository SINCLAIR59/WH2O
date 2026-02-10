import 'package:flutter/material.dart';
import 'package:wh2o/config/app_colors.dart';
import 'package:wh2o/pages/home_page.dart';
import 'package:wh2o/pages/history_page.dart';
import 'package:wh2o/pages/login.dart';
import 'package:wh2o/pages/register.dart';

void main() {
  runApp(const WaterMonitorApp());
}

class WaterMonitorApp extends StatelessWidget {
  const WaterMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WH2O Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      initialRoute: '/login', // เริ่มที่หน้า Login
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}