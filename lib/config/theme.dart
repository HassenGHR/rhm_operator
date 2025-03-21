import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define custom colors
  static const Color primaryColor = Color(0xFF1E88E5); // Blue
  static const Color secondaryColor = Color(0xFF26A69A); // Teal
  static const Color normalStatusColor = Color(0xFF4CAF50); // Green
  static const Color warningStatusColor = Color(0xFFFFC107); // Amber
  static const Color criticalStatusColor = Color(0xFFF44336); // Red
  static const Color backgroundColor = Color(0xFFF5F5F7); // Light Gray

  // Defines text styles
  static TextTheme _buildTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: -0.5,
      ),
      headlineSmall: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: -0.5,
      ),
      bodyLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0,
      ),
      bodyMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0,
      ),
    );
  }

  // Light theme configuration
  static final ThemeData lightTheme = FlexThemeData.light(
    scheme: FlexScheme.material,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      inputDecoratorRadius: 10,
      inputDecoratorUnfocusedBorderIsColored: false,
      fabRadius: 20,
      chipRadius: 10,
      cardRadius: 10,
      popupMenuRadius: 8,
      dialogRadius: 16,
      timePickerDialogRadius: 16,
      menuBarElevation: 1,
      bottomNavigationBarElevation: 1,
      navigationBarElevation: 1,
      // buttonElevation: 0,
      cardElevation: 2,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
  ).copyWith(
    colorScheme: const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
    ),
    textTheme: _buildTextTheme(),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    ),
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
    ),
  );

  // Dark theme configuration
  static final ThemeData darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.material,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 10,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 15,
      inputDecoratorRadius: 10,
      inputDecoratorUnfocusedBorderIsColored: false,
      fabRadius: 20,
      chipRadius: 10,
      cardRadius: 10,
      popupMenuRadius: 8,
      dialogRadius: 16,
      timePickerDialogRadius: 16,
      menuBarElevation: 1,
      bottomNavigationBarElevation: 1,
      navigationBarElevation: 1,
      // buttonElevation: 0,
      cardElevation: 2,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
  ).copyWith(
    colorScheme: const ColorScheme.dark().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    textTheme: _buildTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
      centerTitle: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    ),
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
    ),
  );
}
