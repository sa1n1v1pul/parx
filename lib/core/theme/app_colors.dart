import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Enhanced 3D Theme with Cool Colors
  static const Color primaryBlue = Color(0xFF0F73F7); // Cool blue from resort app
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color coolBlue = Color(0xFF3B82F6);
  static const Color coolBlueLight = Color(0xFF60A5FA);
  static const Color coolBlueDark = Color(0xFF1E40AF);
  static const Color coolPurple = Color(0xFF9333EA);
  static const Color coolCyan = Color(0xFF22D3EE);

  // Gradient Colors - 3D Effect with Cool Combinations
  static const Color gradientStart = Color(0xFF0F73F7); // Cool blue start
  static const Color gradientEnd = Color(0xFF8B5CF6); // Purple end
  static const Color gradientBlueStart = Color(0xFF0F73F7);
  static const Color gradientBlueEnd = Color(0xFF3B82F6);
  static const Color gradientPurpleStart = Color(0xFF8B5CF6);
  static const Color gradientPurpleEnd = Color(0xFF9333EA);
  static const Color gradientCyanStart = Color(0xFF06B6D4);
  static const Color gradientCyanEnd = Color(0xFF22D3EE);

  // Accent Colors
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPink = Color(0xFFEC4899);

  // Light Mode Colors
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardBackgroundDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Common Colors
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // 3D Effect Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientBlueEnd, gradientPurpleEnd, coolCyan],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static LinearGradient get blueGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientBlueStart, gradientBlueEnd],
  );

  static LinearGradient get purpleGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientPurpleStart, gradientPurpleEnd],
  );

  static LinearGradient get successGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static LinearGradient get coolBlueGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coolBlue, coolBlueLight, coolCyan],
  );

  static LinearGradient get coolPurpleGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coolPurple, primaryPurple, coolCyan],
  );

  static LinearGradient get premiumGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientBlueEnd, gradientPurpleEnd],
  );

  // 3D Shadow
  static List<BoxShadow> get shadow3D => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get shadow3DLight => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 15,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
}
