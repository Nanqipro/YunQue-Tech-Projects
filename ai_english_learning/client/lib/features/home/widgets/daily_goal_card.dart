import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

/// 每日目标卡片组件
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.track_changes,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                '今日目标进度',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 单词学习目标
          _buildGoalItem(
            icon: Icons.book,
            title: '单词学习',
            current: 15,
            target: 20,
            unit: '个',
            color: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 学习时长目标
          _buildGoalItem(
            icon: Icons.timer,
            title: '学习时长',
            current: 25,
            target: 30,
            unit: '分钟',
            color: AppColors.secondary,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 练习题目标
          _buildGoalItem(
            icon: Icons.quiz,
            title: '练习题',
            current: 8,
            target: 10,
            unit: '道',
            color: AppColors.tertiary,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          
          // 总体进度
          _buildOverallProgress(),
        ],
      ),
    );
  }

  /// 构建目标项
  Widget _buildGoalItem({
    required IconData icon,
    required String title,
    required int current,
    required int target,
    required String unit,
    required Color color,
  }) {
    final progress = current / target;
    final isCompleted = current >= target;
    
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '$current/$target $unit',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isCompleted ? AppColors.success : AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: AppDimensions.spacingXs),
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 16,
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              
              // 进度条
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.success : color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建总体进度
  Widget _buildOverallProgress() {
    const totalProgress = 0.75; // 75% 完成
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今日完成度',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(totalProgress * 100).toInt()}%',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          
          // 总体进度条
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: totalProgress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          
          Text(
            totalProgress >= 1.0 
                ? '🎉 恭喜！今日目标已完成！' 
                : '继续加油，距离完成目标还有一点点！',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}