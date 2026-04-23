import 'package:flutter/material.dart';
import 'package:meongssam/core/design/app_colors.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static const title = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 21,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textSecondary,
  );
}
