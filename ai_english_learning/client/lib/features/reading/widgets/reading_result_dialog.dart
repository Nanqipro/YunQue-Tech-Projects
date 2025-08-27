import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/reading_question.dart';

/// 阅读结果对话框
class ReadingResultDialog extends StatelessWidget {
  final ReadingExercise exercise;
  final VoidCallback? onReview;
  final VoidCallback? onRetry;
  final VoidCallback? onFinish;

  const ReadingResultDialog({
    super.key,
    required this.exercise,
    this.onReview,
    this.onRetry,
    this.onFinish,
  });

  ReadingExerciseResult get result {
    // 计算练习结果
    int correctCount = 0;
    int totalCount = exercise.questions.length;
    
    for (final question in exercise.questions) {
      if (question.userAnswer == question.correctAnswer) {
        correctCount++;
      }
    }
    
    double score = totalCount > 0 ? (correctCount / totalCount) * 100 : 0;
    
    return ReadingExerciseResult(
      score: score,
      correctCount: correctCount,
      totalCount: totalCount,
      timeSpent: 0, // 可以从练习中获取
      accuracy: score,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 结果图标和标题
            _buildHeader(),
            const SizedBox(height: AppDimensions.spacingLg),

            // 分数展示
            _buildScoreDisplay(),
            const SizedBox(height: AppDimensions.spacingLg),

            // 详细统计
            _buildDetailedStats(),
            const SizedBox(height: AppDimensions.spacingLg),

            // 评价和建议
            _buildFeedback(),
            const SizedBox(height: AppDimensions.spacingXl),

            // 操作按钮
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isExcellent = result.score >= 90;
    final isGood = result.score >= 70;
    final isPass = result.score >= 60;

    IconData iconData;
    Color iconColor;
    String title;

    if (isExcellent) {
      iconData = Icons.emoji_events;
      iconColor = AppColors.warning;
      title = '优秀！';
    } else if (isGood) {
      iconData = Icons.thumb_up;
      iconColor = AppColors.success;
      title = '良好！';
    } else if (isPass) {
      iconData = Icons.check_circle;
      iconColor = AppColors.info;
      title = '及格！';
    } else {
      iconData = Icons.refresh;
      iconColor = AppColors.error;
      title = '需要加油！';
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withOpacity(0.1),
          ),
          child: Icon(
            iconData,
            size: 40,
            color: iconColor,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(
            color: iconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            '总分',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                result.score.toString(),
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' / 100',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          _buildStatRow('正确题数', '${result.correctCount}', AppColors.success),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildStatRow('错误题数', '${result.wrongCount}', AppColors.error),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildStatRow('总题数', '${result.totalQuestions}', AppColors.onSurface),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildStatRow(
            '正确率',
            '${((result.correctCount / result.totalQuestions) * 100).toInt()}%',
            AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildStatRow(
            '用时',
            _formatDuration(result.timeSpent),
            AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    String feedback = _getFeedbackMessage();
    List<String> suggestions = _getSuggestions();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                '学习建议',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            feedback,
            style: AppTextStyles.bodyMedium,
          ),
          if (suggestions.isNotEmpty) ..[
            const SizedBox(height: AppDimensions.spacingSm),
            ...suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // 查看解析按钮
        if (onReview != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                onReview?.call();
              },
              icon: const Icon(Icons.visibility),
              label: const Text('查看解析'),
            ),
          ),
        
        if (onReview != null && (onRetry != null || onFinish != null))
          const SizedBox(width: AppDimensions.spacingMd),

        // 重新练习按钮
        if (onRetry != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                onRetry?.call();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重新练习'),
            ),
          ),
        
        if (onRetry != null && onFinish != null)
          const SizedBox(width: AppDimensions.spacingMd),

        // 完成按钮
        if (onFinish != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                onFinish?.call();
              },
              icon: const Icon(Icons.check),
              label: const Text('完成'),
            ),
          ),
      ],
    );
  }

  String _getFeedbackMessage() {
    final accuracy = (result.correctCount / result.totalQuestions) * 100;
    
    if (accuracy >= 90) {
      return '太棒了！你的阅读理解能力非常出色，继续保持这种学习状态！';
    } else if (accuracy >= 80) {
      return '很好！你的阅读理解能力不错，再接再厉！';
    } else if (accuracy >= 70) {
      return '不错！你的阅读理解能力还可以，继续努力提升！';
    } else if (accuracy >= 60) {
      return '及格了！但还有很大的提升空间，建议多练习阅读理解。';
    } else {
      return '需要加强练习！建议从基础阅读开始，逐步提升理解能力。';
    }
  }

  List<String> _getSuggestions() {
    final accuracy = (result.correctCount / result.totalQuestions) * 100;
    
    if (accuracy >= 80) {
      return [
        '可以尝试更高难度的阅读材料',
        '注意总结阅读技巧和方法',
        '保持每日阅读的好习惯',
      ];
    } else if (accuracy >= 60) {
      return [
        '多练习不同类型的阅读题目',
        '注意理解文章的主旨大意',
        '学会从文中寻找关键信息',
        '提高词汇量和语法理解',
      ];
    } else {
      return [
        '从简单的阅读材料开始练习',
        '重点提升基础词汇量',
        '学习基本的阅读理解技巧',
        '每天坚持阅读练习',
        '可以寻求老师或同学的帮助',
      ];
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}分${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }
}

/// 显示阅读结果对话框
Future<void> showReadingResultDialog(
  BuildContext context,
  ReadingExerciseResult result, {
  VoidCallback? onRestart,
  VoidCallback? onContinue,
  VoidCallback? onClose,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ReadingResultDialog(
      result: result,
      onRestart: onRestart,
      onContinue: onContinue,
      onClose: onClose,
    ),
  );
}