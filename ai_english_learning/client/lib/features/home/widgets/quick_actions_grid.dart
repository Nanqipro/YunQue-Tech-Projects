import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

/// 快捷操作网格组件
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppDimensions.spacingMd,
      mainAxisSpacing: AppDimensions.spacingMd,
      childAspectRatio: 1.2,
      children: [
        _buildActionCard(
          context: context,
          icon: Icons.book_outlined,
          title: '单词学习',
          subtitle: '智能背词',
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, '/vocabulary'),
        ),
        _buildActionCard(
          context: context,
          icon: Icons.headphones_outlined,
          title: '听力训练',
          subtitle: '提升听力',
          color: AppColors.secondary,
          onTap: () => Navigator.pushNamed(context, '/listening'),
        ),
        _buildActionCard(
          context: context,
          icon: Icons.article_outlined,
          title: '阅读理解',
          subtitle: '分级阅读',
          color: AppColors.tertiary,
          onTap: () => Navigator.pushNamed(context, '/reading'),
        ),
        _buildActionCard(
          context: context,
          icon: Icons.edit_outlined,
          title: '写作练习',
          subtitle: 'AI批改',
          color: AppColors.success,
          onTap: () => Navigator.pushNamed(context, '/writing'),
        ),
        _buildActionCard(
          context: context,
          icon: Icons.mic_outlined,
          title: '口语练习',
          subtitle: '发音评估',
          color: AppColors.warning,
          onTap: () => Navigator.pushNamed(context, '/speaking'),
        ),
        _buildActionCard(
          context: context,
          icon: Icons.quiz_outlined,
          title: '模拟考试',
          subtitle: '综合测试',
          color: AppColors.info,
          onTap: () => Navigator.pushNamed(context, '/exam'),
        ),
      ],
    );
  }

  /// 构建操作卡片
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 图标容器
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  
                  // 标题
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  
                  // 副标题
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}