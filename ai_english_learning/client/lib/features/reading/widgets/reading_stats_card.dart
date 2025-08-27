import 'package:flutter/material.dart';
import '../models/reading_stats.dart';

/// 阅读统计卡片组件
class ReadingStatsCard extends StatelessWidget {
  final ReadingStats stats;

  const ReadingStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '阅读统计',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 统计数据网格
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.article,
                  label: '已读文章',
                  value: stats.articlesRead.toString(),
                  unit: '篇',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.quiz,
                  label: '练习次数',
                  value: stats.exercisesCompleted.toString(),
                  unit: '次',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.score,
                  label: '平均分数',
                  value: stats.averageScore.toStringAsFixed(1),
                  unit: '分',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.speed,
                  label: '阅读速度',
                  value: stats.readingSpeed.toString(),
                  unit: '词/分',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.schedule,
                  label: '总时长',
                  value: stats.formattedTotalTime,
                  unit: '',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: '连续天数',
                  value: stats.streakDays.toString(),
                  unit: '天',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 理解准确度进度条
          _buildAccuracyProgress(),
          
          const SizedBox(height: 12),
          
          // 词汇掌握进度条
          _buildVocabularyProgress(),
        ],
      ),
    );
  }

  /// 构建统计项目
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 构建理解准确度进度条
  Widget _buildAccuracyProgress() {
    final accuracy = stats.comprehensionAccuracy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '理解准确度',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${accuracy.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: accuracy / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getAccuracyColor(accuracy),
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  /// 构建词汇掌握进度条
  Widget _buildVocabularyProgress() {
    final vocabulary = stats.vocabularyMastered;
    final maxVocabulary = 10000; // 假设最大词汇量为10000
    final progress = (vocabulary / maxVocabulary).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '词汇掌握',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$vocabulary 词',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.greenAccent,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  /// 获取准确度颜色
  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) {
      return Colors.greenAccent;
    } else if (accuracy >= 70) {
      return Colors.yellowAccent;
    } else {
      return Colors.redAccent;
    }
  }
}