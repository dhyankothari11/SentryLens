import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Backgrounds
  static const Color bgPrimary = Color(0xFF0F172A); // Midnight Navy
  static const Color bgSurface = Color(0xFF1E293B); // Slate Gray
  static const Color bgCard = Color(0xFF243347); // slightly lighter card

  // Accents
  static const Color accent = Color(0xFFE11D48); // Crimson Red
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC); // Soft White
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textHint = Color(0xFF64748B); // Slate 500

  // Border / Divider
  static const Color border = Color(0xFF334155);

  // Gradients
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
