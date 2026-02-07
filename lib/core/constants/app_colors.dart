import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF7B61FF);
  static const Color primaryLight = Color(0xFF9E8AFF);
  static const Color primaryDark = Color(0xFF5A4BCC);

  // Accent Colors
  static const Color secondary = Color(0xFF00D4AA);
  static const Color accent = Color(0xFFFF6B8B);

  // Neutral Colors
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1D2B);
  static const Color textSecondary = Color(0xFF6E7A8A);
  static const Color textDisabled = Color(0xFFA0A8B8);

  // State Colors
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFFA940);
  static const Color error = Color(0xFFFF647C);
  static const Color info = Color(0xFF00B2FF);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFF00E6C3)],
  );
}