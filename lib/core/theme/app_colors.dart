import 'package:flutter/material.dart';

class AppColors {
  static bool isDark = true; // Default theme is dark

  // Primary
  static const Color primaryGreen = Color(0xFF00C896);
  static const Color primaryGreenDark = Color(0xFF00A87E);
  static Color get primaryGreenLight => isDark ? const Color(0x2600C896) : const Color(0x1F00C896);

  // Backgrounds
  static Color get bgDark => isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F5F7);
  static Color get bgSurface => isDark ? const Color(0xFF13131A) : const Color(0xFFFFFFFF);
  static Color get bgCard => isDark ? const Color(0xFF1C1C27) : const Color(0xFFECECEF);
  static Color get bgOverlay => isDark ? const Color(0xEB0A0A0F) : const Color(0xEBFFFFFF);

  // Borders
  static Color get border => isDark ? const Color(0xFF2A2A3A) : const Color(0xFFD6D6DF);
  static Color get borderLight => isDark ? const Color(0x992A2A3A) : const Color(0x99D6D6DF);

  // Text
  static Color get textPrimary => isDark ? const Color(0xFFF0F0F5) : const Color(0xFF1C1C27);
  static Color get textSecondary => isDark ? const Color(0xFF7A7A9A) : const Color(0xFF6B7280);
  static const Color textDark = Color(0xFF1A1A2E);
  static Color get textMuted => isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static Color get dangerLight => isDark ? const Color(0x26EF4444) : const Color(0x1FEF4444);

  // Accents
  static const Color accentOrange = Color(0xFFFF5E3A);
  static const Color accentPurple = Color(0xFF6C63FF);
  static const Color driverYellow = Color(0xFFFFB800);
  static Color get driverYellowLight => isDark ? const Color(0x26FFB800) : const Color(0x1FFFB800);

  // Semantic
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Map
  static Color get mapDark => isDark ? const Color(0xFF0E1219) : const Color(0xFFE5E8EC);
  static const Color routeActive = Color(0xFF00C896);
  static const Color routeWaiting = Color(0xFF00C896);
}
