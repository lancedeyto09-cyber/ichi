import 'package:flutter/material.dart';

class AppColors {
  // Primary Gradient Colors
  static const Color primaryDark = Color(0xFF7D57D7);
  static const Color primaryMid = Color(0xFF9B59FF);
  static const Color primaryLight = Color(0xFFC6B3FA);

  // Secondary Colors
  static const Color accentColor = Color(0xFF6C63FF);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  // Neutral Colors
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMedium = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFB0B0B0);
  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color bgLighter = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryDark,
      primaryMid,
      primaryLight,
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFAFAFA),
    ],
  );

  static LinearGradient featureCardGradient(Color startColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        startColor.withOpacity(0.1),
        startColor.withOpacity(0.05),
      ],
    );
  }

  // Shadow
  static final BoxShadow heavyShadow = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 24,
    offset: const Offset(0, 12),
  );

  static final BoxShadow mediumShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );

  static final BoxShadow lightShadow = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
}
