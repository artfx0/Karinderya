import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand & Primary
  static const Color primary = Color(0xFFC93500);
  static const Color primaryPressed = Color(0xFF9E2800);
  static const Color brandOrange = Color(0xFFF74100);

  // Backgrounds & Surfaces
  static const Color warmCream = Color(0xFFFFF6E5);
  static const Color paperCard = Color(0xFFFFFDF8);
  static const Color darkBrown = Color(0xFF3A2417);
  static const Color mutedBrown = Color(0xFF6A4F3F);
  static const Color line = Color(0xFFE8D7B9);

  // Accents / Status
  static const Color leafGreen = Color(0xFF1F7A3F);
  static const Color mustard = Color(0xFFF2B705);
  static const Color chiliRed = Color(0xFFB3261E);

  // Category Rings
  static const Color categoryUlam = Color(0xFFC93500);
  static const Color categoryRice = Color(0xFFF2B705);
  static const Color categorySoup = Color(0xFF1F7A3F);
  static const Color categoryDrinks = Color(0xFF0277BD);

  // Kitchen Mode Overrides
  static const Color kitchenBg = Color(0xFFFFFFFF);
  static const Color kitchenSurface = Color(0xFFFFFFFF);
  static const Color kitchenBorder = Color(0xFF21150F);
  static const Color kitchenText = Color(0xFF1A0E08);
}

class AppTheme {
  static ThemeData lightTheme({bool kitchenMode = false}) {
    final bgColor = kitchenMode ? AppColors.kitchenBg : AppColors.warmCream;
    final cardColor = kitchenMode ? AppColors.kitchenSurface : AppColors.paperCard;
    final textColor = kitchenMode ? AppColors.kitchenText : AppColors.darkBrown;
    final baseFontSize = kitchenMode ? 18.0 : 14.0;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.brandOrange,
        surface: cardColor,
        onSurface: textColor,
        error: AppColors.chiliRed,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: kitchenMode ? 0 : 2,
        shadowColor: kitchenMode ? Colors.transparent : AppColors.darkBrown.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: kitchenMode ? AppColors.kitchenBorder : AppColors.line,
            width: kitchenMode ? 2.5 : 1.0,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.fredoka(
          fontSize: baseFontSize + 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: GoogleFonts.fredoka(
          fontSize: baseFontSize + 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displaySmall: GoogleFonts.fredoka(
          fontSize: baseFontSize + 8,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: GoogleFonts.fredoka(
          fontSize: baseFontSize + 6,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: GoogleFonts.fredoka(
          fontSize: baseFontSize + 4,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: baseFontSize + 2,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: baseFontSize + 2,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: baseFontSize,
          color: textColor,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: baseFontSize - 2,
          color: kitchenMode ? AppColors.kitchenText : AppColors.mutedBrown,
        ),
      ),
    );
  }
}
