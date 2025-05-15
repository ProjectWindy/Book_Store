import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: 0.15,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: 0.15,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.15,
  );

  // Body text
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyTextLight = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  // Small text
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
    letterSpacing: 0.4,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
    letterSpacing: 1.0,
  );

  // Price text
  static const TextStyle price = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );
}
