import 'package:flutter/material.dart';
import '../models/speaking_stats.dart';

class SpeakingStatsCard extends StatelessWidget {
  final SpeakingStats? stats;
  final bool isLoading;
  final VoidCallback? onTap;

  const SpeakingStatsCard({
    super.key,
    this.stats,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: isLoading ? _buildLoadingState() : _buildStatsContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildStatsContent() {
    if (stats == null) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          children: [
            const Icon(
              Icons.mic,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              '口语练习统计',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[600],
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 统计数据网格
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                '总会话',
                stats!.totalSessions.toString(),
                Icons.chat_bubble_outline,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                '总时长',
                _formatDuration(stats!.totalMinutes),
                Icons.access_time,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                '平均分',
                stats!.averageScore.toStringAsFixed(1),
                Icons.star,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 进度条
        _buildProgressSection(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            '还没有口语练习记录',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '开始你的第一次对话吧！',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    if (stats?.progressData == null || stats!.progressData.isEmpty) {
      return const SizedBox.shrink();
    }

    // 获取最近的进度数据
    final recentProgress = stats!.progressData.last;
    final progressPercentage = (recentProgress.averageScore / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '最近表现',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${recentProgress.averageScore.toStringAsFixed(1)}分',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressPercentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getScoreColor(recentProgress.averageScore),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getScoreLevel(recentProgress.averageScore),
              style: TextStyle(
                fontSize: 12,
                color: _getScoreColor(recentProgress.averageScore),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatDate(recentProgress.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}分钟';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}小时';
      } else {
        return '${hours}小时${remainingMinutes}分钟';
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '${difference}天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 90) {
      return Colors.green;
    } else if (score >= 80) {
      return Colors.lightGreen;
    } else if (score >= 70) {
      return Colors.orange;
    } else if (score >= 60) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }

  String _getScoreLevel(double score) {
    if (score >= 90) {
      return '优秀';
    } else if (score >= 80) {
      return '良好';
    } else if (score >= 70) {
      return '中等';
    } else if (score >= 60) {
      return '及格';
    } else {
      return '需要提高';
    }
  }
}