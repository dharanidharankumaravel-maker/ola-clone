import 'package:flutter/material.dart';

class AppColors {
  static bool isDark = true; // Default theme is dark

  // Primary
  static const Color primaryGreen = Color(0xFF00B14F);
  
  // Primary Variant
  static Color get primaryGreenDark => isDark ? const Color(0xFF00D95F) : const Color(0xFF009944);
  
  // Primary variant with opacity
  static Color get primaryGreenLight => isDark ? const Color(0x2600B14F) : const Color(0x1F00B14F);

  // Backgrounds
  static Color get bgDark => isDark ? const Color(0xFF0F1115) : const Color(0xFFF8F9FA);
  static Color get bgSurface => isDark ? const Color(0xFF181B20) : const Color(0xFFFFFFFF);
  static Color get bgCard => isDark ? const Color(0xFF20242B) : const Color(0xFFFFFFFF);
  static Color get bgOverlay => isDark ? const Color(0xEB0F1115) : const Color(0xEBF8F9FA);

  // Borders & Dividers
  static Color get border => isDark ? const Color(0xFF2C313A) : const Color(0xFFE5E7EB);
  static Color get borderLight => isDark ? const Color(0x992C313A) : const Color(0x99E5E7EB);

  // Text
  static Color get textPrimary => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
  static Color get textSecondary => isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  static const Color textDark = Color(0xFF1A1A2E);
  static Color get textMuted => isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static Color get warning => isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
  static Color get danger => isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
  static Color get dangerLight => isDark ? const Color(0x26F87171) : const Color(0x1FEF4444);

  // Accents
  static Color get accentColor => isDark ? const Color(0xFF34D399) : const Color(0xFF00D95F);
  
  // Secondary color / accents
  static const Color accentOrange = Color(0xFF222222); // Secondary color
  static const Color accentPurple = Color(0xFF6C63FF);
  static const Color driverYellow = Color(0xFFFFB800);
  static Color get driverYellowLight => isDark ? const Color(0x26FFB800) : const Color(0x1FFFB800);

  // Semantic
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Map
  static Color get mapDark => isDark ? const Color(0xFF0F1115) : const Color(0xFFE5E8EC);
  static const Color routeActive = Color(0xFF00B14F);
  static const Color routeWaiting = Color(0xFF00B14F);

  // Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [Color(0xFF00B14F), Color(0xFF00D95F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  static LinearGradient get bannerGradient => const LinearGradient(
        colors: [Color(0xFF00B14F), Color(0xFF34D399)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  static LinearGradient get darkGradient => const LinearGradient(
        colors: [Color(0xFF181B20), Color(0xFF0F1115)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
