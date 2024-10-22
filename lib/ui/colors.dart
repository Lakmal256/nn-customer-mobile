import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Insee Red
  static const MaterialColor red = MaterialColor(
    0xFFDA4540,
    <int, Color>{
      50: Color(0xFFFBE9E8),
      100: Color(0xFFF4C7C6),
      200: Color(0xFFEDA2A0),
      300: Color(0xFFE57D79),
      400: Color(0xFFE0615D),
      500: Color(0xFFDA4540),
      600: Color(0xFFD63E3A),
      700: Color(0xFFD03632),
      800: Color(0xFFCB2E2A),
      900: Color(0xFFC21F1C),
    },
  );

  /// Insee Blue
  static const MaterialColor blue = MaterialColor(
    0xFF173C79,
    <int, Color>{
      50: Color(0xFFE3E8EF),
      100: Color(0xFFB9C5D7),
      200: Color(0xFF8B9EBC),
      300: Color(0xFF5D77A1),
      400: Color(0xFF3A598D),
      500: Color(0xFF173C79),
      600: Color(0xFF143671),
      700: Color(0xFF112E66),
      800: Color(0xFF0D275C),
      900: Color(0xFF071A49),
    },
  );
}
