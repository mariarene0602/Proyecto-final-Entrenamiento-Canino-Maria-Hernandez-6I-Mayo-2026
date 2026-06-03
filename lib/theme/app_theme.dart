// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color azulMarino = Color(0xFF0A192F);
  static const Color azulMarinoClaro = Color(0xFF112240);
  static const Color azulMarinoMedio = Color(0xFF1A365D);
  static const Color dorado = Color(0xFFD4AF37);
  static const Color doradoClaro = Color(0xFFF4D03F);
  static const Color doradoOscuro = Color(0xFFB8960F);
  static const Color grisClaro = Color(0xFFF5F5F5);
  static const Color grisMedio = Color(0xFFE0E0E0);
  static const Color textoOscuro = Color(0xFF1A1A1A);
  static const Color textoClaro = Color(0xFF757575);
  static const Color exito = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color advertencia = Color(0xFFFFA726);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.blanco,
      textTheme: GoogleFonts.poppinsTextTheme(),
      colorScheme: const ColorScheme.light(
        primary: AppColors.azulMarino,
        secondary: AppColors.dorado,
        surface: AppColors.blanco,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.azulMarino,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.dorado),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.blanco,
        selectedItemColor: AppColors.dorado,
        unselectedItemColor: AppColors.azulMarinoClaro,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dorado,
          foregroundColor: AppColors.azulMarino,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.azulMarino,
          side: const BorderSide(color: AppColors.azulMarino),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanco,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.azulMarino),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.azulMarinoClaro),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dorado, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.azulMarino),
      ),
      cardTheme: CardThemeData(
        color: AppColors.blanco,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.dorado,
        foregroundColor: AppColors.azulMarino,
      ),
    );
  }
}