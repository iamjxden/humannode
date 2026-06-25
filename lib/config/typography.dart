import 'package:flutter/material.dart';

class HumanNodeTypography {
  static const String fontFamily = 'Inter';
  static const String monoFamily = 'JetBrainsMono';

  static const TextStyle displayLarge = TextStyle(
      fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.5);
  static const TextStyle displayMedium = TextStyle(
      fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.5);
  static const TextStyle headlineLarge = TextStyle(
      fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w700, height: 1.3);
  static const TextStyle headlineMedium = TextStyle(
      fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle titleLarge = TextStyle(
      fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle titleMedium = TextStyle(
      fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle titleSmall = TextStyle(
      fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle bodyLarge = TextStyle(
      fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodyMedium = TextStyle(
      fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodySmall = TextStyle(
      fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);
  static const TextStyle labelLarge = TextStyle(
      fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: 0.5);
  static const TextStyle labelMedium = TextStyle(
      fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4, letterSpacing: 0.5);
  static const TextStyle labelSmall = TextStyle(
      fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.5);
  static const TextStyle codeLarge = TextStyle(
      fontFamily: monoFamily, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle codeMedium = TextStyle(
      fontFamily: monoFamily, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle codeSmall = TextStyle(
      fontFamily: monoFamily, fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);
}
