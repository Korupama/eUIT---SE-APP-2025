import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color bluePrimary = Color(0xFF2F6BFF);
  static const Color blueLight = Color(0xFF4D7FFF);
  static const Color blueDark = Color(0xFF1A4FCC);
  
  // Background Colors
  static const Color darkBackground = Color(0xFF0f172a);
  static const Color lightBackground = Colors.white;
  
  // Light Mode Gradient Colors
  static const Color lightGradientStart = Color(0xFF5B9BF3); // Xanh dương
  static const Color lightGradientMid = Color(0xFF6B7FE8);   // Xanh tím
  static const Color lightGradientEnd = Color(0xFF9B7FE8);   // Tím nhạt

  // Light Mode Orb Colors
  static const Color lightOrbBlue1 = Color(0xFF3b82f6);
  static const Color lightOrbBlue2 = Color(0xFF6366f1);
  static const Color lightOrbBlue3 = Color(0xFF4f46e5);
  static const Color lightOrbPurple1 = Color(0xFF8b5cf6);
  static const Color lightOrbPurple2 = Color(0xFFa855f7);
  static const Color lightOrbPurple3 = Color(0xFF9333ea);

  // Card & Surface Colors
  static const Color darkCard = Color(0xFF1e293b);
  static const Color lightCard = Color(0xFFF8FAFC);
  
  // Text Colors
  static const Color darkText = Colors.white;
  static const Color lightText = Color(0xFF0f172a);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color lightTextSecondary = Color(0xFF64748B);
  
  // Border & Input Colors
  static const Color darkBorder = Color(0xFF334155);
  static const Color lightBorder = Color(0xFFE2E8F0);
  
  // Error Color
  static const Color error = Color(0xFFEF4444);
  
  // Success Color
  static const Color success = Color(0xFF10B981);
  
  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [bluePrimary, blueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient lightModeGradient = LinearGradient(
    colors: [Colors.yellow.shade200, Colors.orange.shade200],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadows
  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: bluePrimary.withAlpha(127),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
  
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withAlpha(25),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

