import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// 阅读工具栏组件
class ReadingToolbar extends StatelessWidget {
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onTranslate;
  final VoidCallback? onHighlight;
  final VoidCallback? onNote;
  final VoidCallback? onSettings;
  final bool isBookmarked;
  final bool showProgress;
  final double? progress;

  const ReadingToolbar({
    super.key,
    this.onBookmark,
    this.onShare,
    this.onTranslate,
    this.onHighlight,
    this.onNote,
    this.onSettings,
    this.isBookmarked = false,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 进度条
          if (showProgress && progress != null)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 2,
            ),
          
          // 工具栏按钮
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 书签
                _ToolbarButton(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  label: '书签',
                  onTap: onBookmark,
                  isActive: isBookmarked,
                ),
                
                // 分享
                _ToolbarButton(
                  icon: Icons.share_outlined,
                  label: '分享',
                  onTap: onShare,
                ),
                
                // 翻译
                _ToolbarButton(
                  icon: Icons.translate_outlined,
                  label: '翻译',
                  onTap: onTranslate,
                ),
                
                // 高亮
                _ToolbarButton(
                  icon: Icons.highlight_outlined,
                  label: '高亮',
                  onTap: onHighlight,
                ),
                
                // 笔记
                _ToolbarButton(
                  icon: Icons.note_outlined,
                  label: '笔记',
                  onTap: onNote,
                ),
                
                // 设置
                _ToolbarButton(
                  icon: Icons.settings_outlined,
                  label: '设置',
                  onTap: onSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingXs,
          vertical: AppDimensions.paddingXs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 阅读设置底部弹窗
class ReadingSettingsBottomSheet extends StatefulWidget {
  final double fontSize;
  final double lineHeight;
  final bool isDarkMode;
  final Function(double)? onFontSizeChanged;
  final Function(double)? onLineHeightChanged;
  final Function(bool)? onDarkModeChanged;

  const ReadingSettingsBottomSheet({
    super.key,
    required this.fontSize,
    required this.lineHeight,
    required this.isDarkMode,
    this.onFontSizeChanged,
    this.onLineHeightChanged,
    this.onDarkModeChanged,
  });

  @override
  State<ReadingSettingsBottomSheet> createState() => _ReadingSettingsBottomSheetState();
}

class _ReadingSettingsBottomSheetState extends State<ReadingSettingsBottomSheet> {
  late double _fontSize;
  late double _lineHeight;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.fontSize;
    _lineHeight = widget.lineHeight;
    _isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '阅读设置',
                style: AppTextStyles.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          
          // 字体大小
          Text(
            '字体大小',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_fontSize > 12) {
                    setState(() {
                      _fontSize -= 1;
                    });
                    widget.onFontSizeChanged?.call(_fontSize);
                  }
                },
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  label: '${_fontSize.toInt()}',
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                    widget.onFontSizeChanged?.call(value);
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_fontSize < 24) {
                    setState(() {
                      _fontSize += 1;
                    });
                    widget.onFontSizeChanged?.call(_fontSize);
                  }
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          
          // 行间距
          Text(
            '行间距',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_lineHeight > 1.2) {
                    setState(() {
                      _lineHeight -= 0.1;
                    });
                    widget.onLineHeightChanged?.call(_lineHeight);
                  }
                },
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Slider(
                  value: _lineHeight,
                  min: 1.2,
                  max: 2.0,
                  divisions: 8,
                  label: '${(_lineHeight * 10).toInt() / 10}',
                  onChanged: (value) {
                    setState(() {
                      _lineHeight = value;
                    });
                    widget.onLineHeightChanged?.call(value);
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_lineHeight < 2.0) {
                    setState(() {
                      _lineHeight += 0.1;
                    });
                    widget.onLineHeightChanged?.call(_lineHeight);
                  }
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          
          // 夜间模式
          SwitchListTile(
            title: Text(
              '夜间模式',
              style: AppTextStyles.titleMedium,
            ),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              widget.onDarkModeChanged?.call(value);
            },
          ),
          
          const SizedBox(height: AppDimensions.spacingLg),
        ],
      ),
    );
  }
}