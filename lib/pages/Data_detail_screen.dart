
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DataDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const DataDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<DataDetailScreen> createState() => _DataDetailScreenState();
}

class _DataDetailScreenState extends State<DataDetailScreen> {
  String selectedFilter = 'ทั้งหมด';
  final List<String> filterOptions = ['ทั้งหมด', 'สัปดาห์นี้', 'เดือนนี้'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5B4EF5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ข้อมูลย้อนหลัง',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              // Handle menu selection
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'export',
                child: Text('ส่งออกข้อมูล'),
              ),
              const PopupMenuItem<String>(
                value: 'share',
                child: Text('แชร์'),
              ),
              const PopupMenuItem<String>(
                value: 'print',
                child: Text('พิมพ์'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Date and Dropdown
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF5B4EF5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['date'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5B4EF5)),
                        style: const TextStyle(
                          color: Color(0xFF5B4EF5),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        items: filterOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedFilter = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Data Cards Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Temperature Card
                  _buildDataCard(
                    title: 'Temperature',
                    value: widget.data['temp'] ?? '28.5',
                    unit: '°C',
                    color: const Color(0xFFFF9066),
                    gradientColors: [
                      const Color(0xFFFFE0B2),
                      const Color(0xFFFFCC80),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // PH Card
                  _buildDataCard(
                    title: 'ค่าระดับ PH',
                    value: widget.data['ph'] ?? '6.8',
                    unit: 'ระดับกรด',
                    color: const Color(0xFF10B981),
                    gradientColors: [
                      const Color(0xFFDCFCE7),
                      const Color(0xFFA7F3D0),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Oxygen Card
                  _buildDataCard(
                    title: 'Oxygen',
                    value: widget.data['oxygen'] ?? '5.72',
                    unit: 'mg/L',
                    color: const Color(0xFF3B82F6),
                    gradientColors: [
                      const Color(0xFFDBEAFE),
                      const Color(0xFFBFDBFE),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Salinity Card
                  _buildDataCard(
                    title: 'Salinity',
                    value: widget.data['salinity'] ?? '35',
                    unit: 'ppt',
                    color: const Color(0xFF8B5CF6),
                    gradientColors: [
                      const Color(0xFFEDE9FE),
                      const Color(0xFFDDD6FE),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5B4EF5),
          unselectedItemColor: Colors.grey,
          currentIndex: 1,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              activeIcon: Icon(Icons.home),
              label: 'แดชบอร์ด',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              activeIcon: Icon(Icons.show_chart),
              label: 'ประวัติ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              activeIcon: Icon(Icons.location_on),
              label: 'ออกจากระบบ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required List<Color> gradientColors,
  }) {
    // Generate sample data for chart
    List<FlSpot> chartData = _generateChartData();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: false,
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.5)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: gradientColors.map((c) => c.withOpacity(0.3)).toList(),
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartData() {
    // Generate random-looking but smooth data
    return [
      const FlSpot(0, 5),
      const FlSpot(1, 6),
      const FlSpot(2, 4.5),
      const FlSpot(3, 7),
      const FlSpot(4, 6.5),
      const FlSpot(5, 5.5),
      const FlSpot(6, 6),
    ];
  }
}