import 'package:flutter/material.dart';
import '../models/reading_article.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// 阅读内容组件
class ReadingContentWidget extends StatefulWidget {
  final ReadingArticle article;
  final ScrollController? scrollController;
  final VoidCallback? onWordTap;
  final Function(String)? onTextSelection;

  const ReadingContentWidget({
    super.key,
    required this.article,
    this.scrollController,
    this.onWordTap,
    this.onTextSelection,
  });

  @override
  State<ReadingContentWidget> createState() => _ReadingContentWidgetState();
}

class _ReadingContentWidgetState extends State<ReadingContentWidget> {
  double _fontSize = 16.0;
  double _lineHeight = 1.6;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文章标题
          Text(
            widget.article.title,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: _fontSize + 4,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? AppColors.onSurface : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 文章信息
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                widget.article.category,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Icon(
                Icons.schedule_outlined,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                '${widget.article.estimatedReadingTime} 分钟',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Icon(
                Icons.text_fields_outlined,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                '${widget.article.wordCount} 词',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          
          // 阅读设置工具栏
          _buildReadingToolbar(),
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 文章内容
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: SelectableText(
                widget.article.content,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: _fontSize,
                  height: _lineHeight,
                  color: _isDarkMode ? AppColors.onSurface : AppColors.onSurface,
                ),
                onSelectionChanged: (selection, cause) {
                  if (selection.isValid && widget.onTextSelection != null) {
                    final selectedText = widget.article.content
                        .substring(selection.start, selection.end);
                    widget.onTextSelection!(selectedText);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 字体大小调节
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_fontSize > 12) _fontSize -= 1;
                  });
                },
                icon: const Icon(Icons.text_decrease),
                iconSize: 20,
              ),
              Text(
                '${_fontSize.toInt()}',
                style: AppTextStyles.bodySmall,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_fontSize < 24) _fontSize += 1;
                  });
                },
                icon: const Icon(Icons.text_increase),
                iconSize: 20,
              ),
            ],
          ),
          
          // 行间距调节
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_lineHeight > 1.2) _lineHeight -= 0.1;
                  });
                },
                icon: const Icon(Icons.format_line_spacing),
                iconSize: 20,
              ),
              Text(
                '${(_lineHeight * 10).toInt() / 10}',
                style: AppTextStyles.bodySmall,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_lineHeight < 2.0) _lineHeight += 0.1;
                  });
                },
                icon: const Icon(Icons.format_line_spacing),
                iconSize: 20,
              ),
            ],
          ),
          
          // 夜间模式切换
          IconButton(
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}