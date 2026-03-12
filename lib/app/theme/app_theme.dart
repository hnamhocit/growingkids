import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final seedColor = const Color(0xFF22C55E);

final lightBase = ThemeData.light(useMaterial3: true);
final darkBase = ThemeData.dark(useMaterial3: true);

final lightTheme = lightBase.copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.beVietnamProTextTheme(lightBase.textTheme),
);

final darkTheme = darkBase.copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  ),
  textTheme: GoogleFonts.beVietnamProTextTheme(darkBase.textTheme),
);
