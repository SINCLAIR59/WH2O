import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const SensorApp());
}

class SensorApp extends StatelessWidget {
  const SensorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Sensor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const SensorHomePage(),
    );
  }
}

// Sensor Data Model
class SensorData {
  final double temperature;
  final double oxygen;
  final double salinity;
  final double ph;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.oxygen,
    required this.salinity,
    required this.ph,
    required this.timestamp,
  });

  String get phStatus {
    if (ph < 6.5) return 'เป็นกรด';
    if (ph > 7.5) return 'เป็นด่าง';
    return 'เป็นกลาง';
  }
}

// Simulated Sensor Service
class SensorService {
  final Random _random = Random();

  SensorData getCurrentReading() {
    return SensorData(
      temperature: 20.0 + _random.nextDouble() * 2, // 20-22°C
      oxygen: 5.5 + _random.nextDouble() * 0.5,     // 5.5-6.0 mg/L
      salinity: 34.0 + _random.nextDouble() * 2,    // 34-36 ppt
      ph: 6.8 + _random.nextDouble() * 0.6,         // 6.8-7.4
      timestamp: DateTime.now(),
    );
  }
}

class SensorHomePage extends StatefulWidget {
  const SensorHomePage({Key? key}) : super(key: key);

  @override
  State<SensorHomePage> createState() => _SensorHomePageState();
}

class _SensorHomePageState extends State<SensorHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late SensorService _sensorService;
  late SensorData _currentData;
  late Timer _updateTimer;

  int _selectedTab = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _sensorService = SensorService();
    _currentData = _sensorService.getCurrentReading();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Simulate real-time updates every 5 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentData = _sensorService.getCurrentReading();
      });
    });

    // Simulate initial loading
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
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
            colors: [Color(0xFF5B6FED), Color(0xFF4E5FE1)],
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
                  child: _isLoading
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B6FED)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading sensor data...',
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
                    'My Sensor App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Real-time Environmental Monitoring',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentData = _sensorService.getCurrentReading();
                  });
                },
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
                  tween: Tween(begin: 0, end: _currentData.temperature),
                  builder: (context, value, child) {
                    return Text(
                      '${value.toStringAsFixed(2)}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Temperature',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สถานะ PH',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentData.phStatus,
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
                  _currentData.ph.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'PH',
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

  List<Color> _getPhGradientColors() {
    if (_currentData.ph < 6.5) {
      return [const Color(0xFFFFB84D), const Color(0xFFFF9500)]; // Orange for acidic
    } else if (_currentData.ph > 7.5) {
      return [const Color(0xFF6C63FF), const Color(0xFF5848E8)]; // Purple for alkaline
    }
    return [const Color(0xFF66D7A7), const Color(0xFF4EC591)]; // Green for neutral
  }

  Widget _buildSensorGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildSensorCard(
            icon: Icons.water,
            title: 'Oxygen',
            value: _currentData.oxygen.toStringAsFixed(2),
            unit: 'mg/L',
            percentage: '${(_currentData.oxygen / 9 * 100).toStringAsFixed(1)}%',
            color: const Color(0xFF5B6FED),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSensorCard(
            icon: Icons.grain,
            title: 'Salinity',
            value: _currentData.salinity.toStringAsFixed(0),
            unit: 'ppt',
            percentage: '${(_currentData.salinity / 1000 * 100).toStringAsFixed(1)}%',
            color: const Color(0xFFE84393),
          ),
        ),
      ],
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required String percentage,
    required Color color,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              percentage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdateInfo() {
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
            'Last update: ${_formatTime(_currentData.timestamp)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
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
              _buildNavItem(Icons.thermostat, 'Temperature', 0),
              _buildNavItem(Icons.water_drop, 'PH', 1),
              _buildNavItem(Icons.water, 'Oxygen', 2),
              _buildNavItem(Icons.grain, 'Salinity', 3),
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
              color: isSelected ? const Color(0xFF5B6FED) : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF5B6FED) : Colors.grey[400],
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