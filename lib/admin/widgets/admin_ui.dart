import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AdminUI {
  static const double radiusLg = 24;
  static const double radiusMd = 18;
  static const double radiusSm = 14;

  static const EdgeInsets pagePadding = EdgeInsets.all(24);

  static const LinearGradient shellGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7F2FF),
      Color(0xFFF3EDFF),
      Color(0xFFEEE6FF),
    ],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primaryDark,
      AppColors.primaryMid,
    ],
  );

  static BoxDecoration glassCard({
    double radius = radiusMd,
    Color color = Colors.white,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.72),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(0.55),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryDark.withOpacity(0.06),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Widget glass({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
    double radius = radiusMd,
    Color color = Colors.white,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: glassCard(radius: radius, color: color),
          child: child,
        ),
      ),
    );
  }

  static InputDecoration inputDecoration({
    required String hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textLight,
        fontSize: 13,
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.85),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: BorderSide(
          color: AppColors.primaryLight.withOpacity(0.35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(
          color: AppColors.primaryDark,
          width: 1.3,
        ),
      ),
    );
  }

  static TextStyle get pageTitle => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      );

  static TextStyle get pageSubtitle => const TextStyle(
        fontSize: 13,
        color: AppColors.textMedium,
        height: 1.35,
      );

  static Widget sectionHeader({
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: pageTitle),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle, style: pageSubtitle),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  static Widget badge({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
