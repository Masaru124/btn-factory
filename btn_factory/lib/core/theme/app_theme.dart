import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    // We override light() to actually deliver a premium dark theme as requested by the user,
    // ensuring unified visual language throughout the entire application.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF14B8A6), // Teal accent
      brightness: Brightness.dark, // Sleek dark mode
      primary: const Color(0xFF14B8A6),
      onPrimary: Colors.black,
      secondary: const Color(0xFF6366F1), // Indigo accent
      surface: const Color(0xFF111827), // Slate 800
      error: const Color(0xFFEF4444),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF090D16),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF090D16),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFFF8FAFC)),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF111827),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1F2937), width: 1), // subtle boundary
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: const Color(0xFF14B8A6).withValues(alpha: 0.25),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.w600, fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF94A3B8), fontSize: 11);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF14B8A6), size: 24);
          }
          return const IconThemeData(color: Color(0xFF94A3B8), size: 22);
        }),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111827),
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1F2937), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF14B8A6),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF14B8A6),
          side: const BorderSide(color: Color(0xFF14B8A6), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF94A3B8),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1F2937),
        disabledColor: const Color(0xFF111827),
        selectedColor: const Color(0xFF14B8A6).withValues(alpha: 0.2),
        secondarySelectedColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: Color(0xFFF8FAFC)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Color(0xFFE2E8F0)),
        bodyMedium: TextStyle(color: Color(0xFF94A3B8)),
        labelMedium: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
      ),
    );
  }
}

