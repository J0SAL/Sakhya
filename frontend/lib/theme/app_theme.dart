import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary warm palette for rural Indian women
  static const cream = Color(0xFFFFF9F0);
  static const turmeric = Color(0xFFF5A623);
  static const kumkum = Color(0xFFE8401C);
  static const maatiBrown = Color(0xFF8B5E3C);
  static const leafGreen = Color(0xFF4CAF50);
  static const deepGreen = Color(0xFF2E7D32);
  static const softGold = Color(0xFFFFC107);
  static const warmGrey = Color(0xFF795548);
  static const lightCream = Color(0xFFFFF3E0);
  static const cardSurface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF3E2723);
  static const textSecondary = Color(0xFF6D4C41);
  static const divider = Color(0xFFD7CCC8);
  static const successGreen = Color(0xFF388E3C);
  static const errorRed = Color(0xFFD32F2F);
  static const shadowColor = Color(0x1A8B5E3C);
}

class AppTheme {
  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.leafGreen,
        onPrimary: Colors.white,
        secondary: AppColors.turmeric,
        onSecondary: Colors.white,
        error: AppColors.errorRed,
        onError: Colors.white,
        surface: AppColors.cream,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      cardColor: AppColors.cardSurface,
    );

    return base.copyWith(
      textTheme: GoogleFonts.hindTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.hind(fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.hind(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.hind(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.hind(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.hind(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.hind(fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.hind(fontSize: 14, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.hind(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.leafGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.hind(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.leafGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.hind(fontSize: 18, fontWeight: FontWeight.w600),
          elevation: 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 3,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.leafGreen,
        unselectedItemColor: AppColors.warmGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCream,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.leafGreen, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightCream,
        selectedColor: AppColors.leafGreen.withAlpha(50),
        labelStyle: GoogleFonts.hind(fontSize: 14, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: AppColors.divider),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.cardSurface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.hind(color: Colors.white, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Reusable decoration helpers
  static BoxDecoration warmCard({Color? color, double radius = 20}) => BoxDecoration(
    color: color ?? AppColors.cardSurface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 12, offset: const Offset(0, 4))],
  );

  static BoxDecoration gradientBanner(List<Color> colors) => BoxDecoration(
    gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
    borderRadius: BorderRadius.circular(20),
  );
}
