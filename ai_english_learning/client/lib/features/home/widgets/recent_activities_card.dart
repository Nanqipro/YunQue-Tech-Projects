import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

/// 最近活动卡片组件
class RecentActivitiesCard extends StatelessWidget {
  const RecentActivitiesCard({super.key});

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
                Icons.history,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                '最近活动',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 活动列表
          ..._buildActivityList(),
        ],
      ),
    );
  }

  /// 构建活动列表
  List<Widget> _buildActivityList() {
    final activities = [
      ActivityItem(
        icon: Icons.book_outlined,
        title: '完成单词学习',
        subtitle: '学习了20个新单词',
        time: '2小时前',
        color: AppColors.primary,
        score: 95,
      ),
      ActivityItem(
        icon: Icons.headphones_outlined,
        title: '听力练习',
        subtitle: '完成日常英语对话练习',
        time: '4小时前',
        color: AppColors.secondary,
        score: 88,
      ),
      ActivityItem(
        icon: Icons.quiz_outlined,
        title: '语法测试',
        subtitle: '时态练习测试',
        time: '昨天',
        color: AppColors.success,
        score: 92,
      ),
      ActivityItem(
        icon: Icons.article_outlined,
        title: '阅读理解',
        subtitle: '科技类文章阅读',
        time: '昨天',
        color: AppColors.tertiary,
        score: 85,
      ),
      ActivityItem(
        icon: Icons.mic_outlined,
        title: '口语练习',
        subtitle: '日常对话场景训练',
        time: '2天前',
        color: AppColors.warning,
        score: 90,
      ),
    ];

    return activities.asMap().entries.map((entry) {
      final index = entry.key;
      final activity = entry.value;
      
      return Column(
        children: [
          _buildActivityItem(activity),
          if (index < activities.length - 1)
            const SizedBox(height: AppDimensions.spacingMd),
        ],
      );
    }).toList();
  }

  /// 构建活动项
  Widget _buildActivityItem(ActivityItem activity) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: activity.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: activity.color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 图标容器
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          
          // 活动信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (activity.score != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(activity.score!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                        ),
                        child: Text(
                          '${activity.score}分',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _getScoreColor(activity.score!),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                
                Text(
                  activity.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.onSurfaceVariant,
                      size: 14,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      activity.time,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 箭头图标
          Icon(
            Icons.chevron_right,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// 获取分数颜色
  Color _getScoreColor(int score) {
    if (score >= 90) {
      return AppColors.success;
    } else if (score >= 80) {
      return AppColors.warning;
    } else if (score >= 70) {
      return AppColors.info;
    } else {
      return AppColors.error;
    }
  }
}

/// 活动项数据模型
class ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final int? score;

  ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    this.score,
  });
}