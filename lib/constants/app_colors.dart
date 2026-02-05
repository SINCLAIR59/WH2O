import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF0077BE);
  static const Color primaryBlueDark = Color(0xFF005A8D);
  static const Color background = Color(0xFFF5F7FA);

  // Status Colors
  static const Color excellent = Color(0xFF00C853);
  static const Color good = Color(0xFF64DD17);
  static const Color fair = Color(0xFFFFAB00);
  static const Color poor = Color(0xFFFF6D00);
  static const Color critical = Color(0xFFD50000);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF0077BE),
    Color(0xFF005A8D),
  ];

  static const List<Color> excellentGradient = [
    Color(0xFF00C853),
    Color(0xFF00E676),
  ];

  static const List<Color> goodGradient = [
    Color(0xFF64DD17),
    Color(0xFF76FF03),
  ];

  static const List<Color> fairGradient = [
    Color(0xFFFFAB00),
    Color(0xFFFFD600),
  ];

  static const List<Color> poorGradient = [
    Color(0xFFFF6D00),
    Color(0xFFFF9100),
  ];

  static const List<Color> criticalGradient = [
    Color(0xFFD50000),
    Color(0xFFFF1744),
  ];
}

class AppConstants {
  // Update intervals
  static const Duration autoUpdateInterval = Duration(seconds: 10);

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 1500);
  static const Duration tweenDuration = Duration(milliseconds: 800);

  // Border radius
  static const double cardRadius = 20.0;
  static const double containerRadius = 30.0;

  // Padding
  static const double defaultPadding = 20.0;
}