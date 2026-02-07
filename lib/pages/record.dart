import 'package:flutter/material.dart';
import 'data_detail_screen.dart';

class HistoricalDataScreen extends StatefulWidget {
  const HistoricalDataScreen({Key? key}) : super(key: key);

  @override
  State<HistoricalDataScreen> createState() => _HistoricalDataScreenState();
}

class _HistoricalDataScreenState extends State<HistoricalDataScreen> {
  String selectedFilter = 'ทั้งหมด';
  final List<String> filterOptions = ['ทั้งหมด', 'สัปดาห์นี้', 'เดือนนี้'];

  final List<Map<String, dynamic>> historicalData = [
    {'date': '24/5/2569', 'ph': '6.8', 'oxygen': '5.2', 'salinity': '32', 'temp': '28.5'},
    {'date': '25/5/2569', 'ph': '7.0', 'oxygen': '5.5', 'salinity': '33', 'temp': '28.2'},
    {'date': '26/5/2569', 'ph': '6.9', 'oxygen': '5.4', 'salinity': '34', 'temp': '28.8'},
    {'date': '27/5/2569', 'ph': '7.1', 'oxygen': '5.6', 'salinity': '35', 'temp': '29.0'},
    {'date': '28/5/2569', 'ph': '6.7', 'oxygen': '5.3', 'salinity': '33', 'temp': '28.3'},
    {'date': '29/5/2569', 'ph': '6.9', 'oxygen': '5.5', 'salinity': '34', 'temp': '28.7'},
    {'date': '30/5/2569', 'ph': '7.0', 'oxygen': '5.7', 'salinity': '35', 'temp': '29.2'},
  ];

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
      ),
      body: Column(
        children: [
          // Header Section with Dropdown
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
                const Text(
                  'กรองข้อมูล',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
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

          // Data List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: historicalData.length,
              itemBuilder: (context, index) {
                final data = historicalData[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DataDetailScreen(data: data),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
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
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Calendar Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B4EF5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF5B4EF5),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Date and Quick Stats
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['date'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PH ${data['ph']} • O₂ ${data['oxygen']} mg/L',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow Icon
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar (ตรงกับหน้าอื่น)
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
}