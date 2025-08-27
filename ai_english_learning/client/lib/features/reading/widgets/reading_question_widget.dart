import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/reading_question.dart';

/// 阅读问题组件
class ReadingQuestionWidget extends StatelessWidget {
  final ReadingQuestion question;
  final String? selectedAnswer;
  final bool showResult;
  final Function(String) onAnswerSelected;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool isFirst;
  final bool isLast;

  const ReadingQuestionWidget({
    super.key,
    required this.question,
    this.selectedAnswer,
    this.showResult = false,
    required this.onAnswerSelected,
    this.onNext,
    this.onPrevious,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 问题类型标签
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm,
              vertical: AppDimensions.spacingXs,
            ),
            decoration: BoxDecoration(
              color: _getQuestionTypeColor(question.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(
                color: _getQuestionTypeColor(question.type),
                width: 1,
              ),
            ),
            child: Text(
              _getQuestionTypeLabel(question.type),
              style: AppTextStyles.bodySmall.copyWith(
                color: _getQuestionTypeColor(question.type),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // 问题内容
          Text(
            question.question,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // 选项列表
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final optionKey = String.fromCharCode(65 + index.toInt()); // A, B, C, D
            final isSelected = selectedAnswer == optionKey;
            final isCorrect = showResult && question.correctAnswer == optionKey;
            final isWrong = showResult && isSelected && !isCorrect;

            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
              child: InkWell(
                onTap: showResult ? null : () => onAnswerSelected(optionKey),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  decoration: BoxDecoration(
                    color: _getOptionBackgroundColor(
                      isSelected,
                      isCorrect,
                      isWrong,
                      showResult,
                    ),
                    border: Border.all(
                      color: _getOptionBorderColor(
                        isSelected,
                        isCorrect,
                        isWrong,
                        showResult,
                      ),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      // 选项标识
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getOptionLabelColor(
                            isSelected,
                            isCorrect,
                            isWrong,
                            showResult,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            optionKey,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _getOptionLabelTextColor(
                                isSelected,
                                isCorrect,
                                isWrong,
                                showResult,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingMd),

                      // 选项内容
                      Expanded(
                        child: Text(
                          option,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _getOptionTextColor(
                              isSelected,
                              isCorrect,
                              isWrong,
                              showResult,
                            ),
                          ),
                        ),
                      ),

                      // 结果图标
                      if (showResult && (isCorrect || isWrong))
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? AppColors.success : AppColors.error,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          // 解析（如果显示结果且有解析）
          if (showResult && question.explanation != null) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
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
                        Icons.lightbulb_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Text(
                        '解析',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    question.explanation!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.spacingXl),

          // 导航按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 上一题按钮
              if (!isFirst)
                OutlinedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('上一题'),
                )
              else
                const SizedBox.shrink(),

              // 下一题/完成按钮
              if (!isLast)
                ElevatedButton.icon(
                  onPressed: selectedAnswer != null ? onNext : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('下一题'),
                )
              else
                ElevatedButton.icon(
                  onPressed: selectedAnswer != null ? onNext : null,
                  icon: const Icon(Icons.check),
                  label: const Text('完成'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getQuestionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return '选择题';
      case QuestionType.trueFalse:
        return '判断题';
      case QuestionType.fillInBlank:
        return '填空题';
      case QuestionType.shortAnswer:
        return '简答题';
    }
  }

  Color _getQuestionTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return AppColors.primary;
      case QuestionType.trueFalse:
        return AppColors.secondary;
      case QuestionType.fillInBlank:
        return AppColors.warning;
      case QuestionType.shortAnswer:
        return AppColors.info;
    }
  }

  Color _getOptionBackgroundColor(
    bool isSelected,
    bool isCorrect,
    bool isWrong,
    bool showResult,
  ) {
    if (showResult) {
      if (isCorrect) return AppColors.success.withOpacity(0.1);
      if (isWrong) return AppColors.error.withOpacity(0.1);
    }
    if (isSelected) return AppColors.primary.withOpacity(0.1);
    return AppColors.surface;
  }

  Color _getOptionBorderColor(
    bool isSelected,
    bool isCorrect,
    bool isWrong,
    bool showResult,
  ) {
    if (showResult) {
      if (isCorrect) return AppColors.success;
      if (isWrong) return AppColors.error;
    }
    if (isSelected) return AppColors.primary;
    return AppColors.outline;
  }

  Color _getOptionLabelColor(
    bool isSelected,
    bool isCorrect,
    bool isWrong,
    bool showResult,
  ) {
    if (showResult) {
      if (isCorrect) return AppColors.success;
      if (isWrong) return AppColors.error;
    }
    if (isSelected) return AppColors.primary;
    return AppColors.surfaceVariant;
  }

  Color _getOptionLabelTextColor(
    bool isSelected,
    bool isCorrect,
    bool isWrong,
    bool showResult,
  ) {
    if (showResult && (isCorrect || isWrong)) return AppColors.onPrimary;
    if (isSelected) return AppColors.onPrimary;
    return AppColors.onSurfaceVariant;
  }

  Color _getOptionTextColor(
    bool isSelected,
    bool isCorrect,
    bool isWrong,
    bool showResult,
  ) {
    if (showResult) {
      if (isCorrect) return AppColors.success;
      if (isWrong) return AppColors.error;
    }
    if (isSelected) return AppColors.primary;
    return AppColors.onSurface;
  }
}