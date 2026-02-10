import 'package:flutter/material.dart';
import 'package:wh2o/config/app_colors.dart';
import 'package:wh2o/services/water_service.dart';
import 'package:wh2o/models/water_data.dart';
import 'package:wh2o/widgets/app_bottom_nav.dart';
import 'package:wh2o/pages/daily_level_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<dynamic>> _dataFuture;
  DateTime? _selectedDate; // 🗓️ ตัวแปรเก็บวันที่ที่เลือก

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dataFuture = WaterService.fetchAll();
    });
  }

  Future<void> _refreshData() async {
    await WaterService.clearCache();
    _loadData();
  }

  // 🗓️ ฟังก์ชันเลือกวันที่ (นำกลับมาแล้ว)
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedDate = null;
    });
  }

  // จัดกลุ่มข้อมูลตามวันที่
  Map<String, List<WaterData>> _groupDataByDate(List<dynamic> list) {
    Map<String, List<WaterData>> grouped = {};

    for (var item in list) {
      final data = WaterData.fromJson(item);
      final dateKey = data.measuredAt.toString().split(' ')[0]; // Key: "2026-02-01"

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(data);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ประวัติย้อนหลัง'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          // 🔎 ปุ่มค้นหา (กลับมาแล้ว!)
          IconButton(
            icon: Icon(
              _selectedDate != null ? Icons.calendar_month : Icons.calendar_month_outlined,
              color: _selectedDate != null ? AppColors.primaryBlue : Colors.grey[700],
            ),
            onPressed: _pickDate,
            tooltip: 'เลือกวันที่',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            onPressed: _refreshData,
            tooltip: 'รีเฟรช',
          )
        ],
      ),
      body: Column(
        children: [
          // 🏷️ แถบแสดงว่ากำลังกรองวันที่ไหนอยู่
          if (_selectedDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.primaryBlue.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 18, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'ผลการค้นหา: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _clearFilter,
                    child: const Row(
                      children: [
                        Icon(Icons.close, size: 16, color: Colors.red),
                        SizedBox(width: 4),
                        Text('ล้างตัวกรอง', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),

          // รายการข้อมูล
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: FutureBuilder<List<dynamic>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('ไม่พบข้อมูล'));
                  }

                  // 1. จัดกลุ่มข้อมูลทั้งหมด
                  final groupedData = _groupDataByDate(snapshot.data!);
                  var dateKeys = groupedData.keys.toList();

                  // 2. ถ้ามีการเลือกวันที่ -> กรอง list key ให้เหลือแค่วันที่เลือก
                  if (_selectedDate != null) {
                    final filterKey = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                    dateKeys = dateKeys.where((k) => k == filterKey).toList();
                  }

                  // 3. กรณีค้นหาแล้วไม่เจอ
                  if (dateKeys.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('ไม่พบข้อมูลของวันที่เลือก', style: TextStyle(color: Colors.grey[600])),
                          TextButton(onPressed: _clearFilter, child: const Text('ดูทั้งหมด'))
                        ],
                      ),
                    );
                  }

                  // 4. แสดงรายการ
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dateKeys.length,
                    itemBuilder: (context, index) {
                      final dateKey = dateKeys[index];
                      final records = groupedData[dateKey]!;

                      // แปลงวันที่ให้สวยงาม
                      final dateParts = dateKey.split('-');
                      final prettyDate = '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                          ),
                          title: Text(
                            'วันที่ $prettyDate',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text('มีข้อมูลบันทึก ${records.length} รายการ'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            // ไปหน้ารายละเอียดรายวัน (DailyLevelPage)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DailyLevelPage(
                                  dateLabel: prettyDate,
                                  dailyRecords: records,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}