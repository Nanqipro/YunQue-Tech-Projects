import 'package:flutter/material.dart';

/// 应用颜色常量
class AppColors {
  // 私有构造函数，防止实例化
  AppColors._();
  
  // ============ 浅色主题颜色 ============
  
  /// 主色调
  static const Color primary = Color(0xFF1976D2);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFBBDEFB);
  static const Color onPrimaryContainer = Color(0xFF0D47A1);
  
  /// 次要色调
  static const Color secondary = Color(0xFF03DAC6);
  static const Color onSecondary = Color(0xFF000000);
  static const Color secondaryContainer = Color(0xFFB2DFDB);
  static const Color onSecondaryContainer = Color(0xFF004D40);
  
  /// 第三色调
  static const Color tertiary = Color(0xFF9C27B0);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFE1BEE7);
  static const Color onTertiaryContainer = Color(0xFF4A148C);
  
  /// 错误色
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onErrorContainer = Color(0xFFB71C1C);
  
  /// 背景颜色
  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = Color(0xFF1C1B1F);
  
  /// 表面色
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color surfaceTint = Color(0xFF1976D2);
  
  /// 表面变体色
  static const Color surfaceVariant = Color(0xFFF3F3F3);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  
  /// 轮廓色
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  
  /// 阴影颜色
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  
  /// 反转颜色
  static const Color inverseSurface = Color(0xFF313033);
  static const Color onInverseSurface = Color(0xFFF4EFF4);
  static const Color inversePrimary = Color(0xFF90CAF9);
  
  // ============ 深色主题颜色 ============
  
  /// 主色调 - 深色
  static const Color primaryDark = Color(0xFF90CAF9);
  static const Color onPrimaryDark = Color(0xFF003C8F);
  static const Color primaryContainerDark = Color(0xFF1565C0);
  static const Color onPrimaryContainerDark = Color(0xFFE3F2FD);
  
  /// 次要色调 - 深色
  static const Color secondaryDark = Color(0xFF80CBC4);
  static const Color onSecondaryDark = Color(0xFF00251A);
  static const Color secondaryContainerDark = Color(0xFF00695C);
  static const Color onSecondaryContainerDark = Color(0xFFE0F2F1);
  
  /// 第三色调 - 深色
  static const Color tertiaryDark = Color(0xFFCE93D8);
  static const Color onTertiaryDark = Color(0xFF4A148C);
  static const Color tertiaryContainerDark = Color(0xFF7B1FA2);
  static const Color onTertiaryContainerDark = Color(0xFFF3E5F5);
  
  /// 错误色 - 深色
  static const Color errorDark = Color(0xFFEF5350);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorContainerDark = Color(0xFFD32F2F);
  static const Color onErrorContainerDark = Color(0xFFFFEBEE);
  
  /// 背景颜色 - 深色
  static const Color backgroundDark = Color(0xFF1C1B1F);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);
  
  /// 表面色 - 深色
  static const Color surfaceDark = Color(0xFF121212);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color surfaceTintDark = Color(0xFF90CAF9);
  
  /// 表面变体色 - 深色
  static const Color surfaceVariantDark = Color(0xFF49454F);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);
  
  /// 轮廓色 - 深色
  static const Color outlineDark = Color(0xFF938F99);
  static const Color outlineVariantDark = Color(0xFF49454F);
  
  /// 阴影颜色 - 深色
  static const Color shadowDark = Color(0xFF000000);
  static const Color scrimDark = Color(0xFF000000);
  
  /// 反转色 - 深色
  static const Color inverseSurfaceDark = Color(0xFFE6E1E5);
  static const Color onInverseSurfaceDark = Color(0xFF313033);
  static const Color inversePrimaryDark = Color(0xFF1976D2);
  
  // ============ 功能性颜色 ============
  
  /// 成功色
  static const Color success = Color(0xFF4CAF50);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFE8F5E8);
  static const Color onSuccessContainer = Color(0xFF1B5E20);
  
  /// 警告色
  static const Color warning = Color(0xFFFF9800);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarningContainer = Color(0xFFE65100);
  
  /// 信息色
  static const Color info = Color(0xFF2196F3);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFE3F2FD);
  static const Color onInfoContainer = Color(0xFF0D47A1);
  
  // ============ 学习模块颜色 ============
  
  /// 词汇学习
  static const Color vocabulary = Color(0xFF9C27B0);
  static const Color onVocabulary = Color(0xFFFFFFFF);
  static const Color vocabularyContainer = Color(0xFFF3E5F5);
  static const Color onVocabularyContainer = Color(0xFF4A148C);
  static const Color vocabularyDark = Color(0xFFBA68C8);
  
  /// 听力训练
  static const Color listening = Color(0xFF00BCD4);
  static const Color onListening = Color(0xFFFFFFFF);
  static const Color listeningContainer = Color(0xFFE0F7FA);
  static const Color onListeningContainer = Color(0xFF006064);
  static const Color listeningDark = Color(0xFF4DD0E1);
  
  /// 阅读理解
  static const Color reading = Color(0xFF4CAF50);
  static const Color onReading = Color(0xFFFFFFFF);
  static const Color readingContainer = Color(0xFFE8F5E8);
  static const Color onReadingContainer = Color(0xFF1B5E20);
  static const Color readingDark = Color(0xFF81C784);
  
  /// 写作练习
  static const Color writing = Color(0xFFFF5722);
  static const Color onWriting = Color(0xFFFFFFFF);
  static const Color writingContainer = Color(0xFFFBE9E7);
  static const Color onWritingContainer = Color(0xFFBF360C);
  static const Color writingDark = Color(0xFFFF8A65);
  
  /// 口语练习
  static const Color speaking = Color(0xFFE91E63);
  static const Color onSpeaking = Color(0xFFFFFFFF);
  static const Color speakingContainer = Color(0xFFFCE4EC);
  static const Color onSpeakingContainer = Color(0xFF880E4F);
  static const Color speakingDark = Color(0xFFF06292);
  
  // ============ 等级颜色 ============
  
  /// 初级
  static const Color beginner = Color(0xFF4CAF50);
  static const Color onBeginner = Color(0xFFFFFFFF);
  static const Color beginnerDark = Color(0xFF81C784);
  
  /// 中级
  static const Color intermediate = Color(0xFFFF9800);
  static const Color onIntermediate = Color(0xFFFFFFFF);
  static const Color intermediateDark = Color(0xFFFFB74D);
  
  /// 高级
  static const Color advanced = Color(0xFFF44336);
  static const Color onAdvanced = Color(0xFFFFFFFF);
  static const Color advancedDark = Color(0xFFEF5350);
  
  // ============ 进度颜色 ============
  
  /// 进度条背景
  static const Color progressBackground = Color(0xFFE0E0E0);
  
  /// 进度条前景
  static const Color progressForeground = Color(0xFF2196F3);
  
  /// 完成状态
  static const Color completed = Color(0xFF4CAF50);
  
  /// 进行中状态
  static const Color inProgress = Color(0xFFFF9800);
  
  /// 未开始状态
  static const Color notStarted = Color(0xFFBDBDBD);
  
  /// 进度等级颜色
  static const Color progressLow = Color(0xFFF44336);
  static const Color progressLowDark = Color(0xFFEF5350);
  static const Color progressMedium = Color(0xFFFF9800);
  static const Color progressMediumDark = Color(0xFFFFB74D);
  static const Color progressHigh = Color(0xFF4CAF50);
  static const Color progressHighDark = Color(0xFF81C784);
  
  // ============ 特殊颜色 ============
  
  /// 分割线
  static const Color divider = Color(0xFFE0E0E0);
  
  /// 禁用状态
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color onDisabled = Color(0xFF757575);
  
  /// 透明度变体
  static Color get primaryWithOpacity => primary.withValues(alpha: 0.12);
  static Color get secondaryWithOpacity => secondary.withValues(alpha: 0.12);
  static Color get errorWithOpacity => error.withValues(alpha: 0.12);
  static Color get successWithOpacity => success.withValues(alpha: 0.12);
  static Color get warningWithOpacity => warning.withValues(alpha: 0.12);
  static Color get infoWithOpacity => info.withValues(alpha: 0.12);
  
  // ============ 渐变色 ============
  
  /// 主要渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 次要渐变
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF03DAC6), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 词汇渐变
  static const LinearGradient vocabularyGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 听力渐变
  static const LinearGradient listeningGradient = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF2196F3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 阅读渐变
  static const LinearGradient readingGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 写作渐变
  static const LinearGradient writingGradient = LinearGradient(
    colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// 口语渐变
  static const LinearGradient speakingGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}