import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: const Color(0xFF217D3E),
  secondaryHeaderColor: const Color(0xFF009f67),
  disabledColor: const Color(0xFFA0A4A8),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF217D3E))),
  colorScheme: const ColorScheme.light(
          primary: Color(0xFF217D3E), secondary: Color(0xFF449B47))
      .copyWith(error: const Color(0xFFE84D4F)),
);
