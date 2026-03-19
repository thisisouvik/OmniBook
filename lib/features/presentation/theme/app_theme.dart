import 'package:flutter/material.dart';
import 'package:omnibook/features/presentation/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
      scaffoldBackgroundColor: const Color(0xFFF7F9FB),
      fontFamily: 'Manrope',
      textTheme: ThemeData.light().textTheme.copyWith(
        bodyLarge: const TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: const TextStyle(fontWeight: FontWeight.w600),
        bodySmall: const TextStyle(fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(fontWeight: FontWeight.w700),
        titleLarge: const TextStyle(fontWeight: FontWeight.w700),
        headlineSmall: const TextStyle(fontWeight: FontWeight.w700),
        labelLarge: const TextStyle(fontWeight: FontWeight.w700),
      ),
      useMaterial3: true,
    );
  }
}
