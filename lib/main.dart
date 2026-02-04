import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wh2o/services/service.dart';
import 'package:wh2o/models/data.dart';

void main() {
  runApp(const WaterMonitorApp());
}

class WaterMonitorApp extends StatelessWidget {
  const WaterMonitorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Quality Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const WaterHomePage(),
    );
  }
}

class WaterHomePage extends StatefulWidget {
  const WaterHomePage({Key? key}) : super(key: key);

  @override
  State<WaterHomePage> createState() => _WaterHomePageState();
}

class _WaterHomePageState extends State<WaterHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  WaterData? _currentData;
  late Timer _updateTimer;

  int _selectedTab = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _loadData();

    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final data = await WaterService.fetchAll();
      if (mounted && data.isNotEmpty) {
        // แปลง dynamic เป็น WaterData โดยใช้ fromJson
        final latestData = data.first;
        setState(() {
          _currentData = WaterData.fromJson(latestData);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0077BE), Color(0xFF005A8D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading || _currentData == null
                      ? _buildLoadingState()
                      : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildStatusCard(),
                          const SizedBox(height: 20),
                          _buildSensorGrid(),
                          const SizedBox(height: 20),
                          _buildLastUpdateInfo(),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0077BE)),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              GestureDetector(
                onTap: _loadData,
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
          if (_currentData != null)
            FadeTransition(
              opacity: _animationController,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.thermostat,
                    color: Colors.white.withOpacity(0.9),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
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

  Widget _buildStatusCard() {
    if (_currentData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getPhGradientColors(),
        ),
        borderRadius: BorderRadius.circular(20),
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
                  _getPhStatus(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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

  String _getPhStatus() {
    if (_currentData == null) return 'Unknown';
    final ph = _currentData!.ph;
    if (ph < 7.5) return 'Acidic';
    if (ph > 8.5) return 'Alkaline';
    if (ph >= 7.8 && ph <= 8.2) return 'Optimal';
    return 'Normal';
  }

  List<Color> _getPhGradientColors() {
    if (_currentData == null) {
      return [const Color(0xFF66D7A7), const Color(0xFF4EC591)];
    }
    if (_currentData!.ph < 7.5) {
      return [const Color(0xFFFFB84D), const Color(0xFFFF9500)]; // Orange for acidic
    } else if (_currentData!.ph > 8.5) {
      return [const Color(0xFF6C63FF), const Color(0xFF5848E8)]; // Purple for alkaline
    } else if (_currentData!.ph >= 7.8 && _currentData!.ph <= 8.2) {
      return [const Color(0xFF66D7A7), const Color(0xFF4EC591)]; // Green for optimal
    }
    return [const Color(0xFF5DADE2), const Color(0xFF3498DB)]; // Blue for normal
  }

  Widget _buildSensorGrid() {
    if (_currentData == null) return const SizedBox.shrink();

    // Calculate quality indicators based on ideal ranges
    double oxygenQuality = (((_currentData!.oxygen - 5) / 3) * 100).clamp(0, 100);
    double salinityQuality = (((_currentData!.salinity - 14) / 2) * 100).clamp(0, 100);

    return Column(
      children: [
        Row(
          children: [
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

  String _getOxygenStatus(double oxygen) {
    if (oxygen >= 6.5) return 'Excellent';
    if (oxygen >= 6.0) return 'Good';
    if (oxygen >= 5.5) return 'Fair';
    return 'Low';
  }

  String _getSalinityStatus(double salinity) {
    if (salinity >= 15.3 && salinity <= 15.6) return 'Optimal';
    if (salinity >= 15.0 && salinity < 15.3) return 'Good';
    if (salinity >= 14.5 && salinity < 15.0) return 'Fair';
    return 'Check';
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            unit,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
            'Last update: ${_formatDateTime(_currentData!.measuredAt)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

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
              _buildNavItem(Icons.thermostat, 'Temp', 0),
              _buildNavItem(Icons.water_drop, 'pH', 1),
              _buildNavItem(Icons.water, 'O₂', 2),
              _buildNavItem(Icons.grain, 'Salt', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0077BE) : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0077BE) : Colors.grey[400],
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
// ============================================
// ✅ WaterPage - แก้ไขแล้ว (StatefulWidget)
// ============================================
class WaterPage extends StatefulWidget {
  const WaterPage({Key? key}) : super(key: key);

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  // ✅ 1. เพิ่มตัวแปร Future เพื่อ cache
  late Future<List<dynamic>> _futureWater;

  @override
  void initState() {
    super.initState();
    // ✅ 2. เรียก API แค่ครั้งเดียวใน initState
    _futureWater = WaterService.fetchAll();
  }

  // ฟังก์ชัน Refresh (ถ้าต้องการ)
  Future<void> _refreshData() async {
    await WaterService.clearCache(); // ลบ cache เก่า
    setState(() {
      _futureWater = WaterService.fetchAll(); // สร้าง Future ใหม่
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Data List'),
        backgroundColor: const Color(0xFF0077BE),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        // ✅ 3. ใช้ตัวแปร _futureWater แทนการเรียก API ตรง ๆ
        future: _futureWater,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'เกิดข้อผิดพลาด: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          // ✅ 4. เช็ค empty data
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

          // Success state - แสดงข้อมูล
          final waters = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: waters.length,
              itemBuilder: (context, index) {
                final water = waters[index];
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Record #${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0077BE),
                              ),
                            ),
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
                        _buildDataRow('Temperature', '${water['temperature'] ?? 'N/A'}°C', Icons.thermostat),
                        _buildDataRow('pH', '${water['ph'] ?? 'N/A'}', Icons.water_drop),
                        _buildDataRow('Oxygen', '${water['oxygen'] ?? 'N/A'} mg/L', Icons.water),
                        _buildDataRow('Salinity', '${water['salinity'] ?? 'N/A'} ppt', Icons.grain),
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

  Widget _buildDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0077BE)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
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