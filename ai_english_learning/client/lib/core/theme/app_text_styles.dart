import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 应用文本样式配置
class AppTextStyles {
  // 私有构造函数，防止实例化
  AppTextStyles._();
  
  // ============ 字体家族 ============
  
  /// 默认字体
  static const String defaultFontFamily = 'Roboto';
  
  /// 中文字体
  static const String chineseFontFamily = 'PingFang SC';
  
  /// 等宽字体
  static const String monospaceFontFamily = 'Roboto Mono';
  
  // ============ 字体权重 ============
  
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  
  // ============ 基础文本样式 ============
  
  /// 标题样式
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: bold,
    letterSpacing: -0.25,
    height: 1.12,
    color: AppColors.onSurface,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: bold,
    letterSpacing: 0,
    height: 1.16,
    color: AppColors.onSurface,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: bold,
    letterSpacing: 0,
    height: 1.22,
    color: AppColors.onSurface,
  );
  
  /// 标题样式
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: 0,
    height: 1.25,
    color: AppColors.onSurface,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.29,
    color: AppColors.onSurface,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.onSurface,
  );
  
  /// 标题样式
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.27,
    color: AppColors.onSurface,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0.15,
    height: 1.50,
    color: AppColors.onSurface,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.onSurface,
  );
  
  /// 标签样式
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.onSurface,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.onSurface,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.onSurface,
  );
  
  /// 正文样式
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0.5,
    height: 1.50,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.onSurfaceVariant,
  );
  
  // ============ 自定义文本样式 ============
  
  /// 按钮文本样式
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
    letterSpacing: 0.1,
    height: 1.25,
    color: AppColors.onPrimary,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: semiBold,
    letterSpacing: 0.1,
    height: 1.29,
    color: AppColors.onPrimary,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.onPrimary,
  );
  
  /// 输入框文本样式
  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0.5,
    height: 1.50,
    color: AppColors.onSurface,
  );
  
  static const TextStyle inputLabel = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0.15,
    height: 1.50,
    color: AppColors.onSurfaceVariant,
  );
  
  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0.5,
    height: 1.50,
    color: AppColors.onSurfaceVariant,
  );
  
  static const TextStyle inputError = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.error,
  );
  
  /// 导航文本样式
  static const TextStyle navigationLabel = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.onSurface,
  );
  
  static const TextStyle tabLabel = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.onSurface,
  );
  
  /// 卡片文本样式
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.onSurface,
  );
  
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.onSurfaceVariant,
  );
  
  static const TextStyle cardBody = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.onSurface,
  );
  
  /// 列表文本样式
  static const TextStyle listTitle = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0.15,
    height: 1.50,
    color: AppColors.onSurface,
  );
  
  static const TextStyle listSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.onSurfaceVariant,
  );
  
  /// 学习相关文本样式
  static const TextStyle wordText = TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.onSurface,
  );
  
  static const TextStyle phoneticText = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0.5,
    height: 1.50,
    color: AppColors.onSurfaceVariant,
    fontFamily: monospaceFontFamily,
  );
  
  static const TextStyle definitionText = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0.5,
    height: 1.50,
    color: AppColors.onSurface,
  );
  
  static const TextStyle exampleText = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.onSurfaceVariant,
    fontStyle: FontStyle.italic,
  );
  
  /// 分数和统计文本样式
  static const TextStyle scoreText = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: 0,
    height: 1.25,
    color: AppColors.primary,
  );
  
  static const TextStyle statisticNumber = TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.onSurface,
  );
  
  static const TextStyle statisticLabel = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.onSurfaceVariant,
  );
  
  /// 状态文本样式
  static const TextStyle successText = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.success,
  );
  
  static const TextStyle warningText = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.warning,
  );
  
  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.error,
  );
  
  static const TextStyle infoText = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.info,
  );
  
  // ============ Material 3 文本主题 ============
  
  /// Material 3 文本主题
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
  );
  
  // ============ 辅助方法 ============
  
  /// 根据主题亮度调整文本颜色
  static TextStyle adaptiveTextStyle(TextStyle style, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return style.copyWith(
        color: _adaptColorForDarkTheme(style.color ?? AppColors.onSurface),
      );
    }
    return style;
  }
  
  /// 为深色主题调整颜色
  static Color _adaptColorForDarkTheme(Color color) {
    if (color == AppColors.onSurface) {
      return AppColors.onSurfaceDark;
    } else if (color == AppColors.onSurfaceVariant) {
      return AppColors.onSurfaceVariantDark;
    } else if (color == AppColors.primary) {
      return AppColors.primaryDark;
    }
    return color;
  }
  
  /// 创建带有特定颜色的文本样式
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// 创建带有特定字体大小的文本样式
  static TextStyle withFontSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }
  
  /// 创建带有特定字体权重的文本样式
  static TextStyle withFontWeight(TextStyle style, FontWeight fontWeight) {
    return style.copyWith(fontWeight: fontWeight);
  }
  
  /// 创建带有特定行高的文本样式
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }
  
  /// 创建带有特定字母间距的文本样式
  static TextStyle withLetterSpacing(TextStyle style, double letterSpacing) {
    return style.copyWith(letterSpacing: letterSpacing);
  }
}