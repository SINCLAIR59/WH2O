// ============================================
// 🏠 HOME_PAGE.DART - หน้าแรกของแอป
// ============================================
// หน้าหลักที่แสดงข้อมูลคุณภาพน้ำแบบ Real-time
// 
// Features:
// - แสดงอุณหภูมิแบบใหญ่พร้อม Animation
// - แสดง pH Status Card
// - แสดง Oxygen และ Salinity Cards
// - Auto-refresh ทุก 10 วินาที
// - Bottom Navigation Bar
// - Pull to refresh
// ============================================

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wh2o/services/service.dart';
import 'package:wh2o/models/data.dart';
import 'package:wh2o/constants/app_colors.dart';
import 'package:wh2o/utils/time_formatter.dart';
import 'package:wh2o/widgets/sensor_card.dart';

/// หน้าแรกของแอป - แสดงข้อมูลคุณภาพน้ำแบบ Real-time
class WaterHomePage extends StatefulWidget {
  const WaterHomePage({Key? key}) : super(key: key);

  @override
  State<WaterHomePage> createState() => _WaterHomePageState();
}

class _WaterHomePageState extends State<WaterHomePage> with SingleTickerProviderStateMixin {
  // ==========================================
  // State Variables (ตัวแปรสถานะ)
  // ==========================================
  
  /// Controller สำหรับควบคุม Animation
  late AnimationController _animationController;
  
  /// ข้อมูลน้ำปัจจุบัน (ล่าสุด)
  WaterData? _currentData;
  
  /// Timer สำหรับ auto-refresh ทุก 10 วินาที
  late Timer _updateTimer;

  /// Tab ที่เลือกอยู่ใน Bottom Navigation
  int _selectedTab = 0;
  
  /// สถานะกำลังโหลดข้อมูลหรือไม่
  bool _isLoading = true;

  // ==========================================
  // Lifecycle Methods
  // ==========================================
  
  @override
  void initState() {
    super.initState();

    // ตั้งค่า Animation Controller
    _animationController = AnimationController(
      vsync: this,  // ใช้ SingleTickerProviderStateMixin
      duration: AppConstants.animationDuration,  // 1.5 วินาที
    )..forward();  // เริ่ม animation ทันที

    // โหลดข้อมูลครั้งแรก
    _loadData();

    // ตั้ง Timer ให้ auto-refresh ทุก 10 วินาที
    _updateTimer = Timer.periodic(AppConstants.autoUpdateInterval, (timer) {
      _loadData();
    });
  }

  @override
  void dispose() {
    // ทำความสะอาดเมื่อออกจากหน้านี้
    _animationController.dispose();  // หยุด animation
    _updateTimer.cancel();           // หยุด timer
    super.dispose();
  }

  // ==========================================
  // Data Loading Methods
  // ==========================================
  
  /// โหลดข้อมูลจาก API
  /// 
  /// การทำงาน:
  /// 1. เรียก WaterService.fetchAll()
  /// 2. เอาข้อมูลตัวแรก (ล่าสุด)
  /// 3. แปลงเป็น WaterData object
  /// 4. อัพเดท UI
  Future<void> _loadData() async {
    try {
      // ดึงข้อมูลทั้งหมดจาก Service
      final data = await WaterService.fetchAll();
      
      // เช็คว่า widget ยังอยู่หรือไม่ และมีข้อมูลหรือไม่
      if (mounted && data.isNotEmpty) {
        final latestData = data.first;  // เอาข้อมูลล่าสุด
        
        setState(() {
          // แปลง JSON เป็น WaterData object
          _currentData = WaterData.fromJson(latestData);
          _isLoading = false;  // โหลดเสร็จแล้ว
        });
      }
    } catch (e) {
      // เกิด Error ในการโหลดข้อมูล
      debugPrint('Error loading data: $e');
      
      if (mounted) {
        setState(() {
          _isLoading = false;  // หยุดแสดง loading
        });
      }
    }
  }

  // ==========================================
  // Build Method - Main UI
  // ==========================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // พื้นหลังแบบ Gradient (น้ำเงิน)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ส่วน Header (ด้านบน)
              _buildHeader(),
              
              // ส่วนเนื้อหาหลัก
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppConstants.containerRadius),
                  ),
                  child: _isLoading || _currentData == null
                      ? _buildLoadingState()  // แสดง Loading
                      : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        children: [
                          _buildStatusCard(),      // การ์ด pH Status
                          const SizedBox(height: 20),
                          _buildSensorGrid(),      // การ์ด Oxygen + Salinity
                          const SizedBox(height: 20),
                          _buildLastUpdateInfo(),  // ข้อมูลเวลาอัพเดทล่าสุด
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Navigation Bar ด้านล่าง
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ==========================================
  // UI Components - Loading State
  // ==========================================
  
  /// แสดง Loading Indicator
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
          SizedBox(height: 16),
          Text(
            'Loading water quality data...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI Components - Header
  // ==========================================
  
  /// สร้าง Header ส่วนบน
  /// ประกอบด้วย:
  /// - ชื่อแอป + subtitle
  /// - ปุ่ม Refresh
  /// - อุณหภูมิแบบใหญ่พร้อม Animation
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ชื่อแอป
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Water Quality',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Real-time Monitoring System',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              // ปุ่ม Refresh
              GestureDetector(
                onTap: _loadData,  // กดเพื่อโหลดข้อมูลใหม่
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // ==========================================
          // แสดงอุณหภูมิแบบใหญ่พร้อม Animation
          // ==========================================
          if (_currentData != null)
            FadeTransition(
              opacity: _animationController,  // Fade in animation
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon อุณหภูมิ
                  Icon(
                    Icons.thermostat,
                    color: Colors.white.withOpacity(0.9),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  
                  // ตัวเลขอุณหภูมิ (มี Animation นับขึ้น)
                  TweenAnimationBuilder<double>(
                    duration: AppConstants.tweenDuration,
                    tween: Tween(begin: 0, end: _currentData!.temperature),
                    builder: (context, value, child) {
                      return Text(
                        '${value.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // UI Components - Status Card (pH)
  // ==========================================
  
  /// สร้างการ์ดแสดงสถานะ pH
  /// 
  /// การ์ดจะเปลี่ยนสีตามค่า pH:
  /// - Acidic (< 7.5): สีส้ม
  /// - Alkaline (> 8.5): สีม่วง
  /// - Optimal (7.8-8.2): สีเขียว
  /// - Normal: สีน้ำเงิน
  Widget _buildStatusCard() {
    if (_currentData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getPhGradientColors(),  // สีตามค่า pH
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: _getPhGradientColors()[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ด้านซ้าย: ชื่อสถานะ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'pH Level Status',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPhStatus(),  // "Acidic", "Alkaline", "Optimal", "Normal"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // ด้านขวา: ค่า pH
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _currentData!.ph.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'pH',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Helper Methods - pH Status
  // ==========================================
  
  /// คำนวณสถานะ pH
  /// 
  /// กฎ:
  /// - < 7.5: Acidic (เป็นกรด)
  /// - > 8.5: Alkaline (เป็นด่าง)
  /// - 7.8-8.2: Optimal (เหมาะสมที่สุด)
  /// - อื่นๆ: Normal (ปกติ)
  String _getPhStatus() {
    if (_currentData == null) return 'Unknown';
    final ph = _currentData!.ph;
    
    if (ph < 7.5) return 'Acidic';
    if (ph > 8.5) return 'Alkaline';
    if (ph >= 7.8 && ph <= 8.2) return 'Optimal';
    return 'Normal';
  }

  /// เลือกสี Gradient ตามค่า pH
  /// 
  /// สีต่างกัน:
  /// - Acidic: ส้ม
  /// - Alkaline: ม่วง
  /// - Optimal: เขียว
  /// - Normal: น้ำเงิน
  List<Color> _getPhGradientColors() {
    if (_currentData == null) {
      return [const Color(0xFF66D7A7), const Color(0xFF4EC591)];
    }
    
    final ph = _currentData!.ph;
    
    if (ph < 7.5) {
      // Acidic - ส้ม
      return [const Color(0xFFFFB84D), const Color(0xFFFF9500)];
    } else if (ph > 8.5) {
      // Alkaline - ม่วง
      return [const Color(0xFF6C63FF), const Color(0xFF5848E8)];
    } else if (ph >= 7.8 && ph <= 8.2) {
      // Optimal - เขียว
      return [const Color(0xFF66D7A7), const Color(0xFF4EC591)];
    }
    
    // Normal - น้ำเงิน
    return [const Color(0xFF5DADE2), const Color(0xFF3498DB)];
  }
  // ==========================================
  // UI Components - Sensor Grid
  // ==========================================
  
  /// สร้างกริดแสดง Sensor Cards (Oxygen + Salinity)
  Widget _buildSensorGrid() {
    if (_currentData == null) return const SizedBox.shrink();

    // คำนวณ Quality Score (0-100%)
    // ยิ่งใกล้ค่าเหมาะสม ยิ่งได้คะแนนสูง
    double oxygenQuality = (((_currentData!.oxygen - 5) / 3) * 100).clamp(0, 100);
    double salinityQuality = (((_currentData!.salinity - 14) / 2) * 100).clamp(0, 100);

    return Column(
      children: [
        Row(
          children: [
            // ==========================================
            // การ์ด Oxygen (ออกซิเจน)
            // ==========================================
            Expanded(
              child: _buildSensorCard(
                icon: Icons.water,
                title: 'Oxygen',
                value: _currentData!.oxygen.toStringAsFixed(2),
                unit: 'mg/L',
                percentage: '${oxygenQuality.toStringAsFixed(0)}%',
                color: const Color(0xFF5B6FED),
                statusText: _getOxygenStatus(_currentData!.oxygen),
              ),
            ),
            const SizedBox(width: 16),
            
            // ==========================================
            // การ์ด Salinity (ความเค็ม)
            // ==========================================
            Expanded(
              child: _buildSensorCard(
                icon: Icons.grain,
                title: 'Salinity',
                value: _currentData!.salinity.toStringAsFixed(1),
                unit: 'ppt',
                percentage: '${salinityQuality.toStringAsFixed(0)}%',
                color: const Color(0xFFE84393),
                statusText: _getSalinityStatus(_currentData!.salinity),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // Helper Methods - Sensor Status
  // ==========================================
  
  /// คำนวณสถานะออกซิเจน
  /// 
  /// กฎ:
  /// - >= 6.5: Excellent (ดีเยี่ยม)
  /// - >= 6.0: Good (ดี)
  /// - >= 5.5: Fair (พอใช้)
  /// - < 5.5: Low (ต่ำ)
  String _getOxygenStatus(double oxygen) {
    if (oxygen >= 6.5) return 'Excellent';
    if (oxygen >= 6.0) return 'Good';
    if (oxygen >= 5.5) return 'Fair';
    return 'Low';
  }

  /// คำนวณสถานะความเค็ม
  /// 
  /// กฎ:
  /// - 15.3-15.6: Optimal (เหมาะสมที่สุด)
  /// - 15.0-15.3: Good (ดี)
  /// - 14.5-15.0: Fair (พอใช้)
  /// - อื่นๆ: Check (ตรวจสอบ)
  String _getSalinityStatus(double salinity) {
    if (salinity >= 15.3 && salinity <= 15.6) return 'Optimal';
    if (salinity >= 15.0 && salinity < 15.3) return 'Good';
    if (salinity >= 14.5 && salinity < 15.0) return 'Fair';
    return 'Check';
  }

  // ==========================================
  // UI Components - Individual Sensor Card
  // ==========================================
  
  /// สร้างการ์ด Sensor แต่ละตัว
  /// 
  /// Parameters:
  /// - icon: ไอคอน
  /// - title: ชื่อ sensor
  /// - value: ค่าที่วัดได้
  /// - unit: หน่วย
  /// - percentage: เปอร์เซ็นต์คุณภาพ
  /// - color: สีของการ์ด
  /// - statusText: ข้อความสถานะ
  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required String percentage,
    required Color color,
    required String statusText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
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
          // ส่วนบน: Icon + Title
          // ==========================================
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // ==========================================
          // ส่วนกลาง: ค่าที่วัดได้ (มี Animation)
          // ==========================================
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0, end: double.parse(value)),
            builder: (context, animValue, child) {
              return Text(
                animValue.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              );
            },
          ),
          
          const SizedBox(height: 4),
          
          // หน่วย
          Text(
            unit,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // ==========================================
          // ส่วนล่าง: Percentage Badge + Status
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge เปอร์เซ็นต์
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  percentage,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // ข้อความสถานะ
              Text(
                statusText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI Components - Last Update Info
  // ==========================================
  
  /// แสดงข้อมูลเวลาอัพเดทล่าสุด
  Widget _buildLastUpdateInfo() {
    if (_currentData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            // ใช้ TimeFormatter เพื่อแปลงเวลาให้อ่านง่าย
            'Last update: ${TimeFormatter.formatTimeAgo(_currentData!.measuredAt)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI Components - Bottom Navigation Bar
  // ==========================================
  
  /// สร้าง Bottom Navigation Bar
  /// 
  /// มี 4 ปุ่ม:
  /// - Temp (อุณหภูมิ)
  /// - pH
  /// - O₂ (ออกซิเจน)
  /// - Salt (ความเค็ม)
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // ใช้ NavItem widget จาก sensor_card.dart
              NavItem(
                icon: Icons.thermostat,
                label: 'Temp',
                index: 0,
                selectedIndex: _selectedTab,
                onTap: () => setState(() => _selectedTab = 0),
              ),
              NavItem(
                icon: Icons.water_drop,
                label: 'pH',
                index: 1,
                selectedIndex: _selectedTab,
                onTap: () => setState(() => _selectedTab = 1),
              ),
              NavItem(
                icon: Icons.water,
                label: 'O₂',
                index: 2,
                selectedIndex: _selectedTab,
                onTap: () => setState(() => _selectedTab = 2),
              ),
              NavItem(
                icon: Icons.grain,
                label: 'Salt',
                index: 3,
                selectedIndex: _selectedTab,
                onTap: () => setState(() => _selectedTab = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}