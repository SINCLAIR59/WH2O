import 'package:flutter/material.dart';
import 'package:wh2o/services/service.dart';
import 'package:wh2o/constants/app_colors.dart';
import 'package:wh2o/widgets/sensor_card.dart';

class WaterListPage extends StatefulWidget {
  const WaterListPage({Key? key}) : super(key: key);

  @override
  State<WaterListPage> createState() => _WaterListPageState();
}

class _WaterListPageState extends State<WaterListPage> {
  late Future<List<dynamic>> _futureWater;

  @override
  void initState() {
    super.initState();
    _futureWater = WaterService.fetchAll();
  }

  Future<void> _refreshData() async {
    await WaterService.clearCache();
    setState(() {
      _futureWater = WaterService.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Data List'),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureWater,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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
                                color: AppColors.primaryBlue,
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
                        WaterDataRow(
                          label: 'Temperature',
                          value: '${water['temperature'] ?? 'N/A'}°C',
                          icon: Icons.thermostat,
                        ),
                        WaterDataRow(
                          label: 'pH',
                          value: '${water['ph'] ?? 'N/A'}',
                          icon: Icons.water_drop,
                        ),
                        WaterDataRow(
                          label: 'Oxygen',
                          value: '${water['oxygen'] ?? 'N/A'} mg/L',
                          icon: Icons.water,
                        ),
                        WaterDataRow(
                          label: 'Salinity',
                          value: '${water['salinity'] ?? 'N/A'} ppt',
                          icon: Icons.grain,
                        ),
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
}