import 'package:flutter/material.dart';

///
/// SenseRx App Theme
///
class AppTheme {
  static final ThemeData themeData = ThemeData(
    primaryColor: const Color(0xFF001D40),
    canvasColor: Colors.black45,
    colorScheme: const ColorScheme(
      primary: Color(0xFF001D40),
      secondary: Color(0xFF004B5B),
      tertiary: Color(0xFF6CA03B),
      surface: Colors.white,
      background: Colors.white,
      error: Color(0xFFE71D36),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    fontFamily: 'OpenSans',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: Color(0xFF001D40),
      ),
      displayMedium: TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF001D40),
      ),
      displaySmall: TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 16,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 14,
        color: Colors.black,
      ),
      labelMedium: TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: const Color(0xFF001D40),
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF001D40),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF001D40),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF001D40)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF004B5B), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE71D36)),
      ),
    ),
  );
}