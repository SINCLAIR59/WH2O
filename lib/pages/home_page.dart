import 'package:flutter/material.dart';
import 'package:wh2o/config/app_colors.dart';
import 'package:wh2o/models/water_data.dart';
import 'package:wh2o/services/water_service.dart';
import 'package:wh2o/utils/status_helper.dart';
import 'package:wh2o/utils/time_formatter.dart';
import 'package:wh2o/widgets/app_bottom_nav.dart';
import 'package:wh2o/widgets/chart_widget.dart';
import 'package:wh2o/widgets/sensor_card.dart';

// ✅ ประกาศ Class HomePage อย่างถูกต้องที่นี่
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WaterData? _currentData;
  List<dynamic> _allData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final rawData = await WaterService.fetchAll();
      if (rawData.isNotEmpty) {
        setState(() {
          _allData = rawData;
          // แปลงข้อมูลล่าสุดมาแสดง
          _currentData = WaterData.fromJson(rawData.first);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error loading data: $e");
    }
  }

  Future<void> _refresh() async {
    await WaterService.clearCache();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ส่วนเนื้อหา
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentData == null
          ? Center(child: TextButton(onPressed: _refresh, child: const Text("ไม่มีข้อมูล - แตะเพื่อโหลดใหม่")))
          : RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(), // ส่วนหัวสีฟ้า

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // การ์ด pH
                    _buildPhStatusCard(),

                    const SizedBox(height: 20),

                    // Grid: Oxygen & Salinity
                    Row(
                      children: [
                        Expanded(
                          child: SensorCard(
                            label: 'ออกซิเจน',
                            value: _currentData!.oxygen.toStringAsFixed(2),
                            unit: 'mg/L',
                            icon: Icons.water,
                            status: StatusHelper.getOxygenStatus(_currentData!.oxygen),
                            statusColors: StatusHelper.getOxygenColor(_currentData!.oxygen),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SensorCard(
                            label: 'ความเค็ม',
                            value: _currentData!.salinity.toStringAsFixed(2),
                            unit: 'ppt',
                            icon: Icons.grain,
                            status: StatusHelper.getSalinityStatus(_currentData!.salinity),
                            statusColors: StatusHelper.getSalinityColor(_currentData!.salinity),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // กราฟ
                    SevenDayChart(waterData: _allData),

                    const SizedBox(height: 20),

                    // เวลาอัปเดต
                    Text(
                      'อัปเดตล่าสุด: ${TimeFormatter.formatTimeAgo(_currentData!.measuredAt)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ เมนูด้านล่าง (Index 0 คือหน้า Home)
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  // Widget ส่วนหัว
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primaryGradient),
      ),
      child: Column(
        children: [
          const Text(
              'WH2O Monitor',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 10),
          Text(
              '${_currentData?.temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)
          ),
          const Text('อุณหภูมิน้ำ', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // Widget การ์ด pH
  Widget _buildPhStatusCard() {
    final status = StatusHelper.getPhStatus(_currentData!.ph);
    final colors = StatusHelper.getPhColor(_currentData!.ph);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('สถานะระดับ pH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(status, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ]
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)
            ),
            child: Text(
                _currentData!.ph.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}