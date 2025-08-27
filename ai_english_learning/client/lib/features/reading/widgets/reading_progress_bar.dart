import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// 阅读进度条组件
class ReadingProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final double? progress;
  final String? label;
  final bool showPercentage;
  final Color? progressColor;
  final Color? backgroundColor;

  const ReadingProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.progress,
    this.label,
    this.showPercentage = true,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = progress ?? (total > 0 ? current / total : 0.0);
    final percentage = (progressValue * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和进度信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label ?? '进度',
                style: AppTextStyles.titleMedium,
              ),
              Row(
                children: [
                  Text(
                    '$current / $total',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (showPercentage) ...[
                    const SizedBox(width: AppDimensions.spacingSm),
                    Text(
                      '$percentage%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: progressColor ?? AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          
          // 进度条
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: backgroundColor ?? AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? AppColors.primary,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

/// 圆形进度条组件
class ReadingCircularProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final double? progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;

  const ReadingCircularProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.progress,
    this.size = 80,
    this.strokeWidth = 6,
    this.progressColor,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = progress ?? (total > 0 ? current / total : 0.0);
    final percentage = (progressValue * 100).toInt();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 圆形进度条
          CircularProgressIndicator(
            value: progressValue,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor ?? AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? AppColors.primary,
            ),
          ),
          
          // 中心内容
          child ??
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percentage%',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: progressColor ?? AppColors.primary,
                    ),
                  ),
                  Text(
                    '$current/$total',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

/// 步骤进度条组件
class ReadingStepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;

  const ReadingStepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isCompleted = stepNumber < currentStep;
          final isActive = stepNumber == currentStep;
          final isInactive = stepNumber > currentStep;

          Color stepColor;
          if (isCompleted) {
            stepColor = completedColor ?? AppColors.success;
          } else if (isActive) {
            stepColor = activeColor ?? AppColors.primary;
          } else {
            stepColor = inactiveColor ?? AppColors.surfaceVariant;
          }

          return Expanded(
            child: Row(
              children: [
                // 步骤圆圈
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stepColor,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: AppColors.onPrimary,
                            size: 16,
                          )
                        : Text(
                            stepNumber.toString(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isInactive
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                // 连接线（除了最后一个步骤）
                if (index < totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? (completedColor ?? AppColors.success)
                          : (inactiveColor ?? AppColors.surfaceVariant),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}