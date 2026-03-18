import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final seedColor = const Color(0xFF22C55E);

final lightBase = ThemeData.light(useMaterial3: true);
final darkBase = ThemeData.dark(useMaterial3: true);
final _lightColorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.light,
);
final _darkColorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.dark,
);

final lightTheme = _buildTheme(
  base: lightBase,
  colorScheme: _lightColorScheme,
  scaffoldBackgroundColor: const Color(0xFFF7F9F8),
  surfaceColor: Colors.white,
  inputFillColor: Colors.white,
);

final darkTheme = _buildTheme(
  base: darkBase,
  colorScheme: _darkColorScheme,
  scaffoldBackgroundColor: const Color(0xFF0B1220),
  surfaceColor: const Color(0xFF111827),
  inputFillColor: const Color(0xFF172033),
);

ThemeData _buildTheme({
  required ThemeData base,
  required ColorScheme colorScheme,
  required Color scaffoldBackgroundColor,
  required Color surfaceColor,
  required Color inputFillColor,
}) {
  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    textTheme: GoogleFonts.beVietnamProTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackgroundColor,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    cardColor: surfaceColor,
    canvasColor: surfaceColor,
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceColor,
      contentTextStyle: TextStyle(color: colorScheme.onSurface),
      behavior: SnackBarBehavior.floating,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFillColor,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    ),
  );
}
