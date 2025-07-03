import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class AppTheme {
  // White and Blue Color Scheme
  static const Color primaryColor = Color(0xFF1976D2); // Material Blue 700
  static const Color primaryVariant = Color(0xFF1565C0); // Material Blue 800
  static const Color secondaryColor = Color(0xFF42A5F5); // Material Blue 400
  static const Color backgroundColor = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceColor = Color(0xFFFAFAFA); // Very Light Gray
  static const Color errorColor = Color(0xFFD32F2F); // Material Red 700
  static const Color onPrimaryColor = Color(0xFFFFFFFF); // White on Blue
  static const Color onSecondaryColor = Color(0xFFFFFFFF); // White on Blue
  static const Color onBackgroundColor = Color(0xFF212121); // Dark Gray on White
  static const Color onSurfaceColor = Color(0xFF424242); // Medium Gray on Light Surface
  static const Color onErrorColor = Color(0xFFFFFFFF); // White on Red

  // Additional Blue Shades for Accents
  static const Color lightBlue = Color(0xFFE3F2FD); // Very Light Blue
  static const Color mediumBlue = Color(0xFF90CAF9); // Light Blue 300
  static const Color darkBlue = Color(0xFF0D47A1); // Dark Blue 900

  // Dark Theme Colors (Blue and Dark Background)
  static const Color darkPrimaryColor = Color(0xFF64B5F6); // Light Blue 300
  static const Color darkBackgroundColor = Color(0xFF121212); // Material Dark Background
  static const Color darkSurfaceColor = Color(0xFF1E1E1E); // Dark Surface
  static const Color darkOnPrimaryColor = Color(0xFF0D47A1); // Dark Blue on Light Blue
  static const Color darkOnBackgroundColor = Color(0xFFFFFFFF); // White on Dark
  static const Color darkOnSurfaceColor = Color(0xFFE0E0E0); // Light Gray on Dark

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppAssets.primaryFont,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: onPrimaryColor,
      onSecondary: onSecondaryColor,
      onBackground: onBackgroundColor,
      onSurface: onSurfaceColor,
      onError: onErrorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: onBackgroundColor,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: surfaceColor,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppAssets.primaryFont,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: secondaryColor,
      background: darkBackgroundColor,
      surface: darkSurfaceColor,
      error: errorColor,
      onPrimary: darkOnPrimaryColor,
      onSecondary: onSecondaryColor,
      onBackground: darkOnBackgroundColor,
      onSurface: darkOnSurfaceColor,
      onError: onErrorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: darkOnBackgroundColor,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: darkSurfaceColor,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkPrimaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );
}
