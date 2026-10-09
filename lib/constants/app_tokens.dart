import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTokens {
  // Figma Variables
  static const Color displayCanvas = Color(0xFF070B14);
  static const Color signalAction = Color(0xFFFCD232);
  static const Color signalSuccess = Color(0xFF10B981);
  static const Color signalInfo = Color(0xFF38BDF8);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderSubtle = Color(0xFF26354A);

  // Layout Metric Constraints (1920 x 1080 baseline)
  static const double designWidth = 1920.0;
  static const double designHeight = 1080.0;

  // Typography - English (IBM Plex Sans with Tabular Figures)
  static TextStyle plexSans({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = textPrimary,
    double? letterSpacing,
    double? height,
    bool glow = false,
  }) {
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
                color: color.withValues(alpha: 0.6),
                blurRadius: 16.0,
                spreadRadius: 4.0,
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 32.0,
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
  }) {
    return GoogleFonts.ibmPlexSansThai(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}

