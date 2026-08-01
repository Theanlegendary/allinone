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

// ─── Claymorphism Soft UI Theme Palette ──────────────────────────────────────
const Color clayAccent       = Color(0xFFD4A574); // Warm Sand Clay Accent (#d4a574)
const Color clayText         = Color(0xFF5D4037); // Deep Roasted Espresso (#5d4037)
const Color claySubtext      = Color(0xFF8D6E63); // Terracotta Soil (#8d6e63)
const Color claySurface      = Color(0xFFF9F4EF); // Soft Cream Clay Surface (#f9f4ef)
const Color clayCardBg       = Color(0xFFEADBC8); // Warm Sand Card Background (#eadbc8)
const Color clayDarkCardBg   = Color(0xFFDFCCB7);

// ─── Neumorphism Soft UI Theme Palette (2019-2020 Classic) ───────────────────
const Color neuSurface       = Color(0xFFE0E5EC); // Soft Slate-Blue Off-White Surface (#e0e5ec)
const Color neuAccent        = Color(0xFF6C757D); // Soft Slate Grey Accent (#6c757d)
const Color neuText          = Color(0xFF3D3D3D); // Charcoal Dark Text (#3d3d3d)
const Color neuSubtext       = Color(0xFF888888); // Slate Subtext (#888888)
const Color neuLightShadow   = Color(0xFFFFFFFF); // Top-left soft highlight shadow
const Color neuDarkShadow    = Color(0xFFA3B1C6); // Bottom-right soft depth shadow

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
