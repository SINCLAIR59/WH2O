# Water Quality Monitor (ฉบับอ่านง่าย + ปรับแต่งง่าย)

เอกสารนี้สรุปโครงสร้างโปรเจกต์แบบสั้น กระชับ และแก้ไขได้ง่าย โดยโฟกัสว่า **ถ้าอยากแก้อะไร ต้องไปแก้ไฟล์ไหน**

---

## โครงสร้างโปรเจกต์

```text
lib/
├── main.dart
├── constants/
│   └── app_colors.dart
├── models/
│   └── data.dart
├── services/
│   └── service.dart
├── pages/
│   ├── home_page.dart
│   └── water_list_page.dart
├── widgets/
│   └── sensor_card.dart
└── utils/
    └── time_formatter.dart
```

---

## แก้อะไร ไปที่ไฟล์ไหน

| สิ่งที่อยากปรับ | ไฟล์ที่ควรแก้ |
|---|---|
| สีหลัก / สีสถานะ / padding / radius | `constants/app_colors.dart` |
| รูปแบบข้อมูลน้ำ (WaterData) | `models/data.dart` |
| ดึงข้อมูลจาก API / cache / refresh | `services/service.dart` |
| หน้า Dashboard หลัก | `pages/home_page.dart` |
| หน้ารายการข้อมูลทั้งหมด | `pages/water_list_page.dart` |
| หน้าตาการ์ด sensor และปุ่มนำทาง | `widgets/sensor_card.dart` |
| รูปแบบการแสดงเวลา | `utils/time_formatter.dart` |
| ตั้งค่าเริ่มต้นแอป / route หลัก | `main.dart` |

---

## วิธีปรับแต่งยอดฮิต (แก้ได้เร็ว)

### 1) เปลี่ยนธีมสีทั้งแอป
แก้ที่ไฟล์เดียว: `constants/app_colors.dart`

```dart
static const Color primaryBlue = Color(0xFF0077BE);
```

> แนะนำ: รวมค่าสีไว้ที่ไฟล์นี้ทั้งหมด จะทำให้เปลี่ยนธีมได้เร็วและไม่หลุดหลายไฟล์

### 2) ปรับหน้าการ์ด sensor
แก้ที่ `widgets/sensor_card.dart`
- ตัวอักษรใหญ่/เล็ก
- spacing
- สีและเงาของการ์ด

### 3) เพิ่มหน้าใหม่
1. สร้างไฟล์ใหม่ใน `pages/` (เช่น `settings_page.dart`)
2. เรียกใช้ widget ที่มีอยู่แล้วจาก `widgets/`
3. เพิ่มจุดนำทางจาก `home_page.dart` หรือ `main.dart`

### 4) เปลี่ยน logic การดึงข้อมูล
แก้ที่ `services/service.dart` เพื่อให้ UI ไม่ปนกับ business logic

---

## แนวทางแก้ไขให้ดูแลง่ายระยะยาว

- แก้เรื่อง “หน้าตา” ใน `widgets/` และ `pages/`
- แก้เรื่อง “ข้อมูล” ใน `models/` และ `services/`
- แก้ค่ากลาง (สี/ขนาด/เวลา) ใน `constants/` และ `utils/`
- พยายามให้แต่ละไฟล์มีหน้าที่เดียว (Single Responsibility)

---

## Quick Start สำหรับคนมาใหม่

```dart
// main.dart
import 'package:wh2o/pages/home_page.dart';

// home_page.dart
import 'package:wh2o/services/service.dart';
import 'package:wh2o/models/data.dart';
import 'package:wh2o/constants/app_colors.dart';
import 'package:wh2o/utils/time_formatter.dart';
import 'package:wh2o/widgets/sensor_card.dart';
```

---

## สรุปสั้น

โครงสร้างนี้ถูกออกแบบให้:
- อ่านง่าย
- แยกหน้าที่ชัดเจน
- ปรับแต่งเร็ว
- เพิ่มฟีเจอร์ใหม่ได้โดยไม่กระทบไฟล์อื่นมาก
