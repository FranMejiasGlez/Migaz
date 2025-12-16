import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryYellow = Color(0xFFFEC601);
  static const Color tealGreen = Color(0xFF25CCAD);
  static const Color orange = Color(0xFFEA7317);

  static LinearGradient get appGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment(0.8, 1),
      colors: [
        Color.fromARGB(255, 255, 255, 255),
        Color.fromARGB(255, 255, 255, 255),
        Color.fromARGB(255, 255, 255, 255),
      ],
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryYellow,
      scaffoldBackgroundColor: Colors.white,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryYellow,
      scaffoldBackgroundColor: const Color.fromARGB(
        255,
        116,
        121,
        160,
      ), // Gris oscuro premium, no negro
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 46, 46, 46),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Mantenemos colores consistentes pero adaptados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
