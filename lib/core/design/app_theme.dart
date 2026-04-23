import 'package:flutter/material.dart';
import 'package:meongssam/core/design/app_colors.dart';
import 'package:meongssam/core/design/app_text_styles.dart';

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.light(
    primary: AppColors.brand,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    error: AppColors.danger,
    onPrimary: Colors.white,
    onSecondary: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Pretendard',
    textTheme: const TextTheme(
      displaySmall: AppTextStyles.display,
      titleLarge: AppTextStyles.title,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.body,
      labelMedium: AppTextStyles.caption,
    ),
  );
}
