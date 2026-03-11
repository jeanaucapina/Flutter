import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  double _textScale = 1.0;

  bool get isDarkMode => _isDarkMode;
  double get textScale => _textScale;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTextScale(double scale) {
    _textScale = scale.clamp(0.8, 1.5);
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue,
        elevation: 2,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.poppins(fontSize: 14 * _textScale),
        labelLarge: GoogleFonts.poppins(fontSize: 16 * _textScale),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16 * _textScale,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 2,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14 * _textScale,
          color: Colors.white70,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 16 * _textScale,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16 * _textScale,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}
