import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Theme 1: Luxury Editorial + Neo Minimalism Palette ──────────────────────
const Color tealPrimary     = Color(0xFF52B788); // Apple Fitness/Health Sage Green (#52b788)
const Color tealDark        = Color(0xFF3B8260);
const Color coralAccent     = Color(0xFFE29578); // Soft Warm Terracotta Peach (#e29578)
const Color mintAccent      = Color(0xFF74C69D); // Fresh Soft Spring Mint (#74c69d)
const Color purpleAccent    = Color(0xFFB8B8D1); // Ethereal Dusk Lavender (#b8b8d1)
const Color greenAccent     = Color(0xFF95D5B2);

const Color bgDark          = Color(0xFF050D15); // Deep Navy Midnight Sanctuary (#050d15)
const Color bgMid           = Color(0xFF0A1622); // Deep Oceanic Midnight Navy (#0a1622)
const Color bgSurface       = Color(0xFF0E1E2C);

const Color glassWhite      = Color(0x0CFFFFFF); // Ultra-soft 0.05 glass opacity
const Color glassBorder     = Color(0x1AFFFFFF); // Soft 0.1 border contour
const Color textPrimary     = Color(0xFFF4F8FA); // Warm Editorial Off-White (#f4f8fa)
const Color textSecondary   = Color(0xFF8BA0B2); // Editorial Slate Blue Mist (#8ba0b2)

// ─── Theme ────────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: tealPrimary,
      secondary: coralAccent,
      tertiary: mintAccent,
      surface: bgMid,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.8),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.6),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, height: 1.4),
        bodyMedium: TextStyle(color: textSecondary, height: 1.4),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: textPrimary,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: tealPrimary,
      thumbColor: textPrimary,
      inactiveTrackColor: Colors.white.withOpacity(0.08),
      overlayColor: tealPrimary.withOpacity(0.12),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.black : Colors.white60),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? tealPrimary : Colors.white10),
    ),
  );
}
