import 'package:flutter/material.dart';

class AppColors {
  // --- Main Colors ---
  static const Color primaryBlue = Color(0xFF0077BE);
  static const Color background = Color(0xFFF5F7FA);

  // --- Gradients ---
  static const List<Color> primaryGradient = [Color(0xFF0077BE), Color(0xFF005A8D)];

  // --- Status Colors & Gradients ---
  static const List<Color> excellentGradient = [Color(0xFF4ADE80), Color(0xFF22C55E)];
  static const List<Color> goodGradient = [Color(0xFF60A5FA), Color(0xFF3B82F6)];
  static const List<Color> fairGradient = [Color(0xFFFFB020), Color(0xFFF59E0B)];
  static const List<Color> poorGradient = [Color(0xFFF87171), Color(0xFFEF4444)];
  static const List<Color> criticalGradient = [Color(0xFFD50000), Color(0xFFFF1744)];
}