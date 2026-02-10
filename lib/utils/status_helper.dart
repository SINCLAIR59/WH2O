import 'package:flutter/material.dart';
import 'package:wh2o/config/app_colors.dart';

class StatusHelper {
  // --- pH Logic ---
  static String getPhStatus(double ph) {
    if (ph >= 7.5 && ph <= 8.5) return 'ดีที่สุด';
    if (ph >= 7.0 && ph < 7.5) return 'ดีมาก';
    if (ph >= 6.5 && ph < 7.0) return 'ดี';
    return 'ควรปรับปรุง';
  }

  static List<Color> getPhColor(double ph) {
    if (ph >= 7.5 && ph <= 8.5) return AppColors.excellentGradient;
    if (ph >= 7.0 && ph < 7.5) return AppColors.goodGradient;
    if (ph >= 6.5 && ph < 7.0) return AppColors.fairGradient;
    return AppColors.poorGradient;
  }

  // --- Oxygen Logic ---
  static String getOxygenStatus(double oxygen) {
    if (oxygen >= 6.5) return 'ดีเยี่ยม';
    if (oxygen >= 6.0) return 'ดีมาก';
    if (oxygen >= 5.5) return 'ดี';
    return 'ต่ำ';
  }

  static List<Color> getOxygenColor(double oxygen) {
    if (oxygen >= 6.5) return AppColors.excellentGradient;
    if (oxygen >= 6.0) return AppColors.goodGradient;
    if (oxygen >= 5.5) return AppColors.fairGradient;
    return AppColors.poorGradient;
  }

  // --- Salinity Logic ---
  static String getSalinityStatus(double salinity) {
    if (salinity >= 15.3 && salinity <= 15.6) return 'ดีที่สุด';
    if (salinity >= 15.0 && salinity < 15.3) return 'ดีมาก';
    if (salinity >= 14.5 && salinity < 15.0) return 'ดี';
    return 'ผิดปกติ';
  }

  static List<Color> getSalinityColor(double salinity) {
    if (salinity >= 15.3 && salinity <= 15.6) return AppColors.excellentGradient;
    if (salinity >= 15.0 && salinity < 15.3) return AppColors.goodGradient;
    if (salinity >= 14.5 && salinity < 15.0) return AppColors.fairGradient;
    return AppColors.poorGradient;
  }
}