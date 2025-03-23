import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light theme
  static final ThemeData lightTheme = FlexThemeData.light(
    scheme: FlexScheme.blue,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 9,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      inputDecoratorRadius: 10.0,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      cardRadius: 12.0,
      popupMenuRadius: 8.0,
      bottomNavigationBarElevation: 0,
      navigationBarLabelBehavior:
          NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
  ).copyWith(
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    chipTheme: const ChipThemeData(
      shape: StadiumBorder(),
      elevation: 0,
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.blue,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 15,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      inputDecoratorRadius: 10.0,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      cardRadius: 12.0,
      popupMenuRadius: 8.0,
      bottomNavigationBarElevation: 0,
      navigationBarLabelBehavior:
          NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
  ).copyWith(
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    chipTheme: const ChipThemeData(
      shape: StadiumBorder(),
      elevation: 0,
    ),
  );
}
