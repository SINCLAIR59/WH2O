// ============================================
// 🏠 HOME_PAGE.DART - หน้าแรกของแอป
// ============================================

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wh2o/services/service.dart';
import 'package:wh2o/models/data.dart';
import 'package:wh2o/constants/app_colors.dart';
import 'package:wh2o/utils/time_formatter.dart';
import 'package:wh2o/widgets/sensor_card.dart';
import 'package:wh2o/widgets/chart_widget.dart';

// ============================================
// Main Widget
// ============================================

class WaterHomePage extends StatefulWidget {
  const WaterHomePage({super.key});

  @override
  State<WaterHomePage> createState() => _WaterHomePageState();
}

class _WaterHomePageState extends State<WaterHomePage>
    with SingleTickerProviderStateMixin {

  // ============================================
  // 📦 State Variables
  // ============================================

  // Animation
  late AnimationController _animationController;

  // Data
  WaterData? _currentData;
  List<dynamic> _allData = [];
  int _currentIndex = 0;

  // UI State
  int _selectedTab = 0;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Auto-refresh
  Timer? _updateTimer;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const int _refreshIntervalSeconds = 2;

  // ============================================
  // 🔄 Lifecycle Methods
  // ============================================

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadInitialData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _updateTimer?.cancel();
    debugPrint('🛑 Page disposed');
    super.dispose();
  }

  // ============================================
  // 🎬 Initialization Methods
  // ============================================

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
    )..forward();
  }

  void _loadInitialData() {
    debugPrint('📥 Loading initial data...');
    _loadData();
  }

  void _startAutoRefresh() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      Duration(seconds: _refreshIntervalSeconds),
          (timer) {
        if (!_isRefreshing) {
          debugPrint('⏰ Auto-refresh triggered');
          _loadDataFromCache();
        } else {
          debugPrint('⏸️ Auto-refresh skipped (busy)');
        }
      },
    );
    debugPrint('✅ Auto-refresh started ($_refreshIntervalSeconds seconds)');
  }

  // ============================================
  // 📡 Data Loading Methods
  // ============================================

  /// โหลดข้อมูลจาก API (มี retry logic)
  Future<void> _loadData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      final data = await WaterService.fetchAll();
      _retryCount = 0; // Reset on success

      if (mounted && data.isNotEmpty) {
        setState(() {
          _currentData = WaterData.fromJson(data.first);
          _allData = data;
          _isLoading = false;
          _errorMessage = null;
        });
        debugPrint('✅ Data loaded successfully');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      await _handleLoadError(e);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  /// โหลดข้อมูลจาก cache (ไม่มี retry)
  void _loadDataFromCache() {
    final data = WaterService.getCachedData();

    if (data.isEmpty) {
      debugPrint('📭 No cache available');
      return;
    }

    // วน index กลับเมื่อถึงท้าย
    if (_currentIndex >= data.length) {
      _currentIndex = 0;
    }

    setState(() {
      _currentData = WaterData.fromJson(data[_currentIndex]);
      _allData = _getChartData(data);
      _isLoading = false;
      _errorMessage = null;
    });

    _currentIndex++;
    debugPrint('📊 Cache loaded (index: ${_currentIndex - 1})');
  }

  /// Force refresh (ลบ cache แล้วโหลดใหม่)
  Future<void> _forceRefresh() async {
    if (_isRefreshing) {
      debugPrint('⏸️ Already refreshing');
      return;
    }

    debugPrint('🔄 Force refresh...');
    _retryCount = 0;
    await WaterService.clearCache();
    await _loadData();
  }

  // ============================================
  // 🔧 Helper Methods
  // ============================================

  /// Handle loading error with retry logic
  Future<void> _handleLoadError(dynamic error) async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      debugPrint('🔄 Retry $_retryCount/$_maxRetries');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) return _loadData();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = _parseErrorMessage(error);
      });
    }
  }

  /// แปลง error message ให้อ่านง่าย
  String _parseErrorMessage(dynamic error) {
    final msg = error.toString();
    if (msg.contains('530') || msg.contains('1033')) {
      return 'เซิร์ฟเวอร์ปฏิเสธการเชื่อมต่อ\nกรุณาลองใหม่อีกครั้ง';
    }
    if (msg.contains('SocketException')) {
      return 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ต';
    }
    if (msg.contains('TimeoutException')) {
      return 'หมดเวลาการเชื่อมต่อ';
    }
    return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
  }

  /// ดึงข้อมูลสำหรับกราฟ (50 รายการล่าสุด)
  List<dynamic> _getChartData(List<dynamic> data) {
    final start = (_currentIndex - 50).clamp(0, data.length);
    final end = _currentIndex + 1;
    return data.sublist(start, end);
  }

  // ============================================
  // 🎨 Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    return Container(
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
            _buildHeader(),
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.containerRadius),
      ),
      child: _buildContentByState(),
    );
  }

  Widget _buildContentByState() {
    // Loading state
    if (_isLoading && _currentData == null) {
      return _buildLoadingState();
    }

    // Error state (no data)
    if (_errorMessage != null && _currentData == null) {
      return _buildErrorState();
    }

    // Normal state with data
    return _buildDataContent();
  }

  Widget _buildDataContent() {
    return RefreshIndicator(
      onRefresh: _forceRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Error banner (if error but has old data)
              if (_errorMessage != null && _currentData != null)
                _buildErrorBanner(),

              // Main content
              _buildStatusCard(),
              const SizedBox(height: 20),
              _buildSensorGrid(),
              const SizedBox(height: 20),

              // Chart
              if (_allData.isNotEmpty) ...[
                const SizedBox(height: 4),
                SevenDayChart(waterData: _allData),
              ],

              // Footer
              _buildLastUpdateInfo(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // 📱 UI Components - States
  // ============================================

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'กำลังโหลดข้อมูล...',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (_retryCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              'กำลังลองครั้งที่ $_retryCount/$_maxRetries',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'เกิดข้อผิดพลาด',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _forceRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange[800]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'ไม่สามารถอัพเดทข้อมูลใหม่\nแสดงข้อมูลเก่าที่มีอยู่',
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _forceRefresh,
            color: Colors.orange[800],
          ),
        ],
      ),
    );
  }

  // ============================================
  // 📱 UI Components - Header
  // ============================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeaderTop(),
          const SizedBox(height: 24),
          _buildTemperatureDisplay(),
        ],
      ),
    );
  }

  Widget _buildHeaderTop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WH2O',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'การตรวจสอบคุณภาพน้ำแบบเรียลไทม์',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        _buildRefreshButton(),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: _isRefreshing
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.refresh, color: Colors.white),
        onPressed: _isRefreshing ? null : _forceRefresh,
      ),
    );
  }

  Widget _buildTemperatureDisplay() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        if (_currentData == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.thermostat,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                '${_currentData!.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'อุณหภูมิ',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================
  // 📱 UI Components - Cards
  // ============================================

  Widget _buildStatusCard() {
    if (_currentData == null) return const SizedBox.shrink();

    final phStatus = _getPhStatus(_currentData!.ph);
    final statusColors = _getPhStatusColors(_currentData!.ph);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: statusColors),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'สถานะระดับ pH',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w900
                ),
              ),
              const SizedBox(height: 8),
              Text(
                phStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
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

  Widget _buildSensorGrid() {
    if (_currentData == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: SensorCard(
            label: 'ออกซิเจน',
            value: _currentData!.oxygen.toStringAsFixed(2),
            unit: 'mg/L',
            icon: Icons.water,
            status: _getOxygenStatus(_currentData!.oxygen),
            statusColors: _getOxygenStatusColors(_currentData!.oxygen),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SensorCard(
            label: 'ความเค็ม',
            value: _currentData!.salinity.toStringAsFixed(2),
            unit: 'ppt',
            icon: Icons.grain,
            status: _getSalinityStatus(_currentData!.salinity),
            statusColors: _getSalinityStatusColors(_currentData!.salinity),
          ),
        ),
      ],
    );
  }

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
            'อัปเดตล่าสุด : ${TimeFormatter.formatTimeAgo(_currentData!.measuredAt)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 📱 UI Components - Bottom Navigation
  // ============================================

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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                icon: Icons.dashboard,
                label: 'แดชบอร์ด',
                index: 0,
                selectedIndex: _selectedTab,
                onTap: () => setState(() => _selectedTab = 0),
              ),
              NavItem(
                icon: Icons.clear_all,
                label: 'รายการ',
                index: 1,
                selectedIndex: _selectedTab,
                onTap: () => setState(() => _selectedTab = 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // 🎯 Status Helper Methods
  // ============================================

  // pH Status
  String _getPhStatus(double ph) {
    if (ph >= 7.5 && ph <= 8.5) return 'ดีที่สุด';
    if (ph >= 7.0 && ph < 7.5) return 'ดีมาก';
    if (ph >= 6.5 && ph < 7.0) return 'ดี';
    return 'กำลังตรวจสอบ';
  }

  List<Color> _getPhStatusColors(double ph) {
    if (ph >= 7.5 && ph <= 8.5) return AppColors.excellentGradient;
    if (ph >= 7.0 && ph < 7.5) return AppColors.goodGradient;
    if (ph >= 6.5 && ph < 7.0) return AppColors.fairGradient;
    return AppColors.poorGradient;
  }

  // Oxygen Status
  String _getOxygenStatus(double oxygen) {
    if (oxygen >= 6.5) return 'ดีเยี่ยม';
    if (oxygen >= 6.0) return 'ดีมาก';
    if (oxygen >= 5.5) return 'ดี';
    return 'ต่ำ';
  }

  List<Color> _getOxygenStatusColors(double oxygen) {
    if (oxygen >= 6.5) return AppColors.excellentGradient;
    if (oxygen >= 6.0) return AppColors.goodGradient;
    if (oxygen >= 5.5) return AppColors.fairGradient;
    return AppColors.poorGradient;
  }

  // Salinity Status
  String _getSalinityStatus(double salinity) {
    if (salinity >= 15.3 && salinity <= 15.6) return 'ดีที่สุด';
    if (salinity >= 15.0 && salinity < 15.3) return 'ดีมาก';
    if (salinity >= 14.5 && salinity < 15.0) return 'ดี';
    return 'กำลังตรวจสอบ';
  }

  List<Color> _getSalinityStatusColors(double salinity) {
    if (salinity >= 15.3 && salinity <= 15.6) return AppColors.excellentGradient;
    if (salinity >= 15.0 && salinity < 15.3) return AppColors.goodGradient;
    if (salinity >= 14.5 && salinity < 15.0) return AppColors.fairGradient;
    return AppColors.poorGradient;
  }
}