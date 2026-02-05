// ============================================
// ⏰ TIME_FORMATTER.DART - จัดรูปแบบเวลา
// ============================================
// ไฟล์นี้มีฟังก์ชันช่วยแปลงเวลาให้อ่านง่าย
// เช่น: "Just now", "5m ago", "2h ago"
// 
// ข้อดี:
// - อ่านง่ายกว่าแสดงเวลาเต็ม
// - ใช้ซ้ำได้ทั่วทั้งแอป
// ============================================

/// คลาสสำหรับจัดรูปแบบเวลา
class TimeFormatter {
  /// แปลงเวลาเป็นข้อความที่อ่านง่าย
  /// 
  /// กฎการแปลง:
  /// - น้อยกว่า 1 นาที → "Just now"
  /// - น้อยกว่า 1 ชั่วโมง → "Xm ago" (เช่น "5m ago")
  /// - น้อยกว่า 24 ชั่วโมง → "Xh ago" (เช่น "2h ago")
  /// - มากกว่า 24 ชั่วโมง → แสดงวันที่และเวลา (เช่น "5/2 14:30")
  /// 
  /// ตัวอย่าง:
  /// ```dart
  /// TimeFormatter.formatTimeAgo(DateTime.now())
  /// // Output: "Just now"
  /// 
  /// TimeFormatter.formatTimeAgo(DateTime.now().subtract(Duration(minutes: 30)))
  /// // Output: "30m ago"
  /// 
  /// TimeFormatter.formatTimeAgo(DateTime.now().subtract(Duration(hours: 5)))
  /// // Output: "5h ago"
  /// ```
  static String formatTimeAgo(DateTime time) {
    final now = DateTime.now();                // เวลาปัจจุบัน
    final difference = now.difference(time);   // คำนวณความต่างของเวลา

    // ==========================================
    // กรณีที่ 1: น้อยกว่า 1 นาที
    // ==========================================
    if (difference.inMinutes < 1) {
      return 'Just now';
    } 
    
    // ==========================================
    // กรณีที่ 2: น้อยกว่า 1 ชั่วโมง
    // ==========================================
    else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';  // เช่น "30m ago"
    } 
    
    // ==========================================
    // กรณีที่ 3: น้อยกว่า 24 ชั่วโมง
    // ==========================================
    else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';    // เช่น "5h ago"
    } 
    
    // ==========================================
    // กรณีที่ 4: มากกว่า 24 ชั่วโมง
    // ==========================================
    else {
      // แสดงรูปแบบ: "วัน/เดือน ชั่วโมง:นาที"
      // เช่น: "5/2 14:30"
      return '${time.day}/${time.month} '
             '${time.hour.toString().padLeft(2, '0')}:'  // เติม 0 ข้างหน้า (09:00)
             '${time.minute.toString().padLeft(2, '0')}';
    }
  }
}