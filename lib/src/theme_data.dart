import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTheme = ThemeData(
        textTheme: GoogleFonts.latoTextTheme().copyWith(
          titleLarge: TextStyle()
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFFF37022), // Orange
          onPrimary: const Color(0xFFFFFFFF), // White text/icons on orange
          secondary: const Color(0xFF051951), // Blue
          onSecondary: const Color(0xFFFFFFFF), // White text/icons on blue
          tertiary: const Color(0xFFF37022),
          onTertiary: const Color(0xFF051951),
          error: Colors.red,
          onError: const Color(0xFFFFFFFF), // White text/icons on error
          surface: const Color(0xFFFFFFFF), // White for cards/sheets background
          onSurface: const Color(0xFF051951), // Blue text/icons on surface
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF37022), // Orange
          foregroundColor: const Color(0xFFFFFFFF), // White text/icons in AppBar
          iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)), // White icons
        ),
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );