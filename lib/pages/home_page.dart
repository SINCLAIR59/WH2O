// ============================================
// 🏠 HOME_PAGE.DART - หน้าแรกของแอป (ปรับปรุงแล้ว)
// ============================================
// หน้าหลักที่แสดงข้อมูลคุณภาพน้ำแบบ Real-time
//
// Features:
// - แสดงอุณหภูมิแบบใหญ่พร้อม Animation
// - แสดง pH Status Card
// - แสดง Oxygen และ Salinity Cards
// - 📊 กราฟแสดงข้อมูล 7 วัน (ใหม่!)
// - Auto-refresh ทุก 10 วินาที (ใช้ cache)
// - Pull to refresh
// ============================================

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wh2o/services/service.dart';
import 'package:wh2o/models/data.dart';
import 'package:wh2o/constants/app_colors.dart';
import 'package:wh2o/utils/time_formatter.dart';
import 'package:wh2o/widgets/sensor_card.dart';
import 'package:wh2o/widgets/chart_widget.dart'; // 👈 เพิ่มบรรทัดนี้

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

  /// 📊 ข้อมูลทั้งหมดสำหรับกราฟ (ใหม่!)
  List<dynamic> _allData = [];

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
      vsync: this,
      duration: AppConstants.animationDuration,
    )..forward();

    // โหลดข้อมูลครั้งแรก
    _loadData();

    // ตั้ง Timer ให้ auto-refresh ทุก 10 วินาที
    // ⚡ ระบบนี้จะดึงจาก cache ก่อน (เร็วมาก!)
    // ถ้าไม่มี cache ถึงจะเรียก API
    _updateTimer = Timer.periodic(AppConstants.autoUpdateInterval, (timer) {
      debugPrint('⏰ Auto-refresh triggered (10s timer)');
      _loadDataFromCache();
    });

    debugPrint('✅ Auto-refresh system initialized (every 10 seconds)');
  }

  @override
  void dispose() {
    // ทำความสะอาดเมื่อออกจากหน้านี้
    _animationController.dispose();
    _updateTimer.cancel();
    debugPrint('🛑 Auto-refresh system stopped');
    super.dispose();
  }

  // ==========================================
  // Data Loading Methods
  // ==========================================
  int _currentIndex = 0;
  int _cursor = 0;
  static const int _windowSize = 10;


  /// โหลดข้อมูลจาก Service (ใช้ Cache ก่อน!)
  ///
  /// ลำดับการทำงาน:
  /// 1. เรียก WaterService.fetchAll()
  ///    - ถ้ามี Memory Cache → ใช้เลย (เร็วมาก! <1ms)
  ///    - ถ้ามี Local Cache → ใช้เลย (เร็ว ~50ms)
  ///    - ถ้าไม่มี Cache → เรียก API (~500-2000ms)
  /// 2. เอาข้อมูลตัวแรก (ล่าสุด)
  /// 3. แปลงเป็น WaterData object
  /// 4. อัพเดท UI
  Future<void> _loadData() async {
    try {
      final startTime = DateTime.now();

      // 📥 ดึงข้อมูลทั้งหมดจาก Service (จะใช้ cache ถ้ามี)
      final data = await WaterService.fetchAll();

      final loadTime = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('📊 Data loaded in ${loadTime}ms');

      // เช็คว่า widget ยังอยู่หรือไม่ และมีข้อมูลหรือไม่
      if (mounted && data.isNotEmpty) {
        final latestData = data.first;  // เอาข้อมูลล่าสุด

        setState(() {
          // แปลง JSON เป็น WaterData object
          _currentData = WaterData.fromJson(latestData);

          // 📊 เก็บข้อมูลทั้งหมดสำหรับกราฟ (ใหม่!)
          _allData = data;

          _isLoading = false;
        });

        debugPrint('✅ UI updated with latest data');
      }
    } catch (e) {
      debugPrint('❌ Error loading data: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadDataFromCache() {
    final data = WaterService.getCachedData();

    if (data.isEmpty) return;

    // 🧠 วน index ถ้าถึงท้าย
    if (_currentIndex >= data.length) {
      _currentIndex = 0;
    }

    final record = data[_currentIndex];

    setState(() {
      _currentData = WaterData.fromJson(record);

      // ถ้าอยากให้กราฟเลื่อนไปด้วย
      _allData = data.sublist(
        (_currentIndex - 50).clamp(0, data.length),
        _currentIndex + 1,
      );

      _isLoading = false;
    });

    _currentIndex++; // 👉 ขยับไปตัวถัดไป
  }


  /// Refresh แบบบังคับ (ลบ cache และดึงข้อมูลใหม่จาก API)
  /// ใช้เมื่อ: กดปุ่ม Refresh หรือ Pull to Refresh
  Future<void> _forceRefresh() async {
    debugPrint('🔄 Force refresh - clearing cache and fetching from API');
    await WaterService.clearCache();  // ลบ cache
    await _loadData();  // โหลดใหม่จาก API
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
                      ? _buildLoadingState()
                      : RefreshIndicator(
                    // 👇 Pull to Refresh (บังคับดึงข้อมูลใหม่)
                    onRefresh: _forceRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        child: Column(
                          children: [
                            _buildStatusCard(),      // การ์ด pH Status
                            const SizedBox(height: 20),
                            _buildSensorGrid(),      // การ์ด Oxygen + Salinity
                            const SizedBox(height: 20),

                            // 📊 กราฟ 7 วัน (ใหม่!)
                            if (_allData.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              SevenDayChart(waterData: _allData),
                            ],
                            _buildLastUpdateInfo(),  // ข้อมูลเวลาอัพเดทล่าสุด
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // UI Components - Loading State
  // ==========================================

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

              // ปุ่ม Refresh (บังคับดึงข้อมูลใหม่)
              GestureDetector(
                onTap: _forceRefresh,
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

          // อุณหภูมิแบบใหญ่ (พร้อม Animation)
          if (_currentData != null)
            Center(
              child: TweenAnimationBuilder<double>(
                duration: AppConstants.tweenDuration,
                tween: Tween(begin: 0, end: _currentData!.temperature),
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.thermostat,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '°C',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // UI Components - Status Card
  // ==========================================

  Widget _buildStatusCard() {
    if (_currentData == null) return const SizedBox.shrink();

    final phStatus = _getPhStatus(_currentData!.ph);
    final statusColors = _getPhStatusColors(_currentData!.ph);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: statusColors,
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: statusColors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'pH Level Status',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Optimal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentData!.ph.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: statusColors.first,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI Components - Sensor Grid
  // ==========================================

  Widget _buildSensorGrid() {
    if (_currentData == null) return const SizedBox.shrink();

    final oxygenStatus = _getOxygenStatus(_currentData!.oxygen);
    final oxygenColors = _getOxygenStatusColors(_currentData!.oxygen);

    final salinityStatus = _getSalinityStatus(_currentData!.salinity);
    final salinityColors = _getSalinityStatusColors(_currentData!.salinity);

    return Row(
      children: [
        Expanded(
          child: SensorCard(
            label: 'Oxygen',
            value: _currentData!.oxygen.toStringAsFixed(2),
            unit: 'mg/L',
            icon: Icons.water,
            status: oxygenStatus,
            statusColors: oxygenColors,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SensorCard(
            label: 'Salinity',
            value: _currentData!.salinity.toStringAsFixed(2),
            unit: 'ppt',
            icon: Icons.grain,
            status: salinityStatus,
            statusColors: salinityColors,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Helper Methods - Status Calculation
  // ==========================================

  String _getPhStatus(double ph) {
    if (ph >= 7.5 && ph <= 8.5) return 'Optimal';
    if (ph >= 7.0 && ph < 7.5) return 'Good';
    if (ph >= 6.5 && ph < 7.0) return 'Fair';
    return 'Check';
  }

  List<Color> _getPhStatusColors(double ph) {
    if (ph >= 7.5 && ph <= 8.5) return AppColors.excellentGradient;
    if (ph >= 7.0 && ph < 7.5) return AppColors.goodGradient;
    if (ph >= 6.5 && ph < 7.0) return AppColors.fairGradient;
    return AppColors.poorGradient;
  }

  String _getOxygenStatus(double oxygen) {
    if (oxygen >= 6.5) return 'Excellent';
    if (oxygen >= 6.0) return 'Good';
    if (oxygen >= 5.5) return 'Fair';
    return 'Low';
  }

  List<Color> _getOxygenStatusColors(double oxygen) {
    if (oxygen >= 6.5) return AppColors.excellentGradient;
    if (oxygen >= 6.0) return AppColors.goodGradient;
    if (oxygen >= 5.5) return AppColors.fairGradient;
    return AppColors.poorGradient;
  }

  String _getSalinityStatus(double salinity) {
    if (salinity >= 15.3 && salinity <= 15.6) return 'Optimal';
    if (salinity >= 15.0 && salinity < 15.3) return 'Good';
    if (salinity >= 14.5 && salinity < 15.0) return 'Fair';
    return 'Check';
  }

  List<Color> _getSalinityStatusColors(double salinity) {
    if (salinity >= 15.3 && salinity <= 15.6) return AppColors.excellentGradient;
    if (salinity >= 15.0 && salinity < 15.3) return AppColors.goodGradient;
    if (salinity >= 14.5 && salinity < 15.0) return AppColors.fairGradient;
    return AppColors.poorGradient;
  }

  // ==========================================
  // UI Components - Last Update Info
  // ==========================================

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
}