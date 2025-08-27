import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

/// 进度图表组件
class ProgressChart extends StatefulWidget {
  const ProgressChart({super.key});

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // 模拟数据
  final List<ChartData> _weeklyData = [
    ChartData('周一', 45, AppColors.primary),
    ChartData('周二', 60, AppColors.secondary),
    ChartData('周三', 30, AppColors.tertiary),
    ChartData('周四', 80, AppColors.success),
    ChartData('周五', 55, AppColors.warning),
    ChartData('周六', 70, AppColors.info),
    ChartData('周日', 40, AppColors.error),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Text(
                    '本周学习时长',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              // 时间选择器
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                  vertical: AppDimensions.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                ),
                child: Text(
                  '本周',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          
          // 总计信息
          _buildSummaryInfo(),
          const SizedBox(height: AppDimensions.spacingLg),
          
          // 图表
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: BarChartPainter(
                    data: _weeklyData,
                    animationValue: _animation.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          
          // 图例
          _buildLegend(),
        ],
      ),
    );
  }

  /// 构建总计信息
  Widget _buildSummaryInfo() {
    final totalMinutes = _weeklyData.fold<int>(0, (sum, data) => sum + data.value);
    final avgMinutes = totalMinutes / _weeklyData.length;
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            title: '总时长',
            value: '${(totalMinutes / 60).toStringAsFixed(1)}',
            unit: '小时',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: _buildSummaryItem(
            title: '日均时长',
            value: avgMinutes.toStringAsFixed(0),
            unit: '分钟',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: _buildSummaryItem(
            title: '最长单日',
            value: _weeklyData.map((e) => e.value).reduce((a, b) => a > b ? a : b).toString(),
            unit: '分钟',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  /// 构建总计项
  Widget _buildSummaryItem({
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建图例
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          color: AppColors.primary,
          label: '目标: 60分钟/天',
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        _buildLegendItem(
          color: AppColors.success,
          label: '已完成',
        ),
      ],
    );
  }

  /// 构建图例项
  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingXs),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 图表数据模型
class ChartData {
  final String label;
  final int value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}

/// 柱状图绘制器
class BarChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double animationValue;

  BarChartPainter({
    required this.data,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    final barWidth = (size.width - (data.length + 1) * 16) / data.length;
    final chartHeight = size.height - 40; // 留出底部标签空间
    
    // 绘制网格线
    _drawGridLines(canvas, size, chartHeight);
    
    // 绘制柱状图
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final x = 16 + i * (barWidth + 16);
      final barHeight = (item.value / maxValue) * chartHeight * animationValue;
      final y = chartHeight - barHeight;
      
      // 绘制柱子
      paint.color = item.color.withOpacity(0.8);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
      
      // 绘制数值标签
      if (animationValue > 0.8) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${item.value}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x + (barWidth - textPainter.width) / 2,
            y - textPainter.height - 4,
          ),
        );
      }
      
      // 绘制底部标签
      final labelPainter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(
          x + (barWidth - labelPainter.width) / 2,
          chartHeight + 8,
        ),
      );
    }
  }

  /// 绘制网格线
  void _drawGridLines(Canvas canvas, Size size, double chartHeight) {
    final paint = Paint()
      ..color = AppColors.outline.withOpacity(0.1)
      ..strokeWidth = 1;
    
    // 绘制水平网格线
    for (int i = 0; i <= 4; i++) {
      final y = chartHeight * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}