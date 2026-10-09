import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTokens {
  // Brand & Signal Color Palette (Figma Design Tokens)
  static const Color displayCanvas = Color(0xFF070B14);
  static const Color panelBackground = Color(0xFF0C1322);
  static const Color cardBackground = Color(0xFF111C30);
  static const Color borderSubtle = Color(0xFF26354A);
  static const Color borderStrong = Color(0xFF3B5274);

  // Status Signals
  static const Color signalAction = Color(0xFFFCD232); // Amber gold (Call to Counter)
  static const Color signalAmber = Color(0xFFFFB800);  // Deep airport amber
  static const Color signalWarning = Color(0xFFF59E0B); // Caution / Lunch break
  static const Color signalSuccess = Color(0xFF10B981); // Emerald green (Passport ready)
  static const Color signalInfo = Color(0xFF38BDF8);    // Sky blue (Next buffer, QR)

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDim = Color(0xFF64748B);

  // Layout Metric Constraints (1920 x 1080 Native Kiosk Grid)
  static const double designWidth = 1920.0;
  static const double designHeight = 1080.0;
  static const double panelGap = 96.0;
  static const double horizontalPadding = 64.0;
  static const double verticalPadding = 48.0;
  static const double footerHeight = 98.0;

  // Animation Timings (Physics-aligned Durations)
  static const Duration durationFast = Duration(milliseconds: 250);
  static const Duration durationNormal = Duration(milliseconds: 400);
  static const Duration durationLong = Duration(milliseconds: 650);
  static const Duration durationHighlight = Duration(milliseconds: 4000);
  static const Duration durationPulseCycle = Duration(milliseconds: 1000);

  // Typography - English (IBM Plex Sans with Tabular Figures)
  static TextStyle plexSans({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = textPrimary,
    double? letterSpacing,
    double? height,
    bool glow = false,
    Color? glowColor,
  }) {
    final effectiveGlowColor = glowColor ?? color;
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: const [FontFeature.tabularFigures()],
      shadows: glow
          ? [
              BoxShadow(
                color: effectiveGlowColor.withValues(alpha: 0.65),
                blurRadius: 18.0,
                spreadRadius: 4.0,
              ),
              BoxShadow(
                color: effectiveGlowColor.withValues(alpha: 0.35),
                blurRadius: 36.0,
                spreadRadius: 8.0,
              ),
            ]
          : null,
    );
  }

  // Typography - Thai (IBM Plex Sans Thai)
  static TextStyle plexSansThai({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = textMuted,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.ibmPlexSansThai(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Box Shadow Styles
  static List<BoxShadow> amberGlow({double intensity = 1.0}) {
    return [
      BoxShadow(
        color: signalAction.withValues(alpha: 0.25 * intensity),
        blurRadius: 28,
        spreadRadius: 3 * intensity,
      ),
      BoxShadow(
        color: signalAction.withValues(alpha: 0.12 * intensity),
        blurRadius: 48,
        spreadRadius: 6 * intensity,
      ),
    ];
  }

  static List<BoxShadow> emeraldGlow({double intensity = 1.0}) {
    return [
      BoxShadow(
        color: signalSuccess.withValues(alpha: 0.25 * intensity),
        blurRadius: 28,
        spreadRadius: 3 * intensity,
      ),
      BoxShadow(
        color: signalSuccess.withValues(alpha: 0.12 * intensity),
        blurRadius: 48,
        spreadRadius: 6 * intensity,
      ),
    ];
  }
}
