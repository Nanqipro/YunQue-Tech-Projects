import 'package:flutter/material.dart';
import '../models/writing_stats.dart';

class WritingStatsCard extends StatelessWidget {
  final WritingStats stats;
  final bool showDetails;

  const WritingStatsCard({
    super.key,
    required this.stats,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade50,
              Colors.purple.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Colors.purple.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '写作统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const Spacer(),
                if (showDetails)
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.purple.shade700,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 主要统计数据
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.assignment,
                    label: '完成任务',
                    value: '${stats.completedTasks}',
                    total: '${stats.totalTasks}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.text_fields,
                    label: '总字数',
                    value: _formatNumber(stats.totalWords),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.star,
                    label: '平均分',
                    value: stats.averageScore.toStringAsFixed(1),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            
            if (showDetails) ...[

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // 详细统计
              _buildDetailedStats(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    String? total,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          total != null ? '$value/$total' : value,
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
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailedStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 任务类型统计
        Text(
          '任务类型分布',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        _buildTypeStats(),
        
        const SizedBox(height: 16),
        
        // 难度分布
        Text(
          '难度分布',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        _buildDifficultyStats(),
        
        const SizedBox(height: 16),
        
        // 技能分析
        // 技能分析
        Text(
          '技能分析',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        _buildSkillAnalysis(),

      ],
    );
  }

  Widget _buildTypeStats() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: stats.taskTypeStats.entries.map((entry) {
        final percentage = stats.totalTasks > 0 
            ? (entry.value / stats.totalTasks * 100).toInt()
            : 0;
        
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            '${entry.key}: ${entry.value} ($percentage%)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyStats() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: stats.difficultyStats.entries.map((entry) {
        final percentage = stats.totalTasks > 0 
            ? (entry.value / stats.totalTasks * 100).toInt()
            : 0;
        
        Color color;
        switch (entry.key) {
          case 'beginner':
          case 'elementary':
            color = Colors.green;
            break;
          case 'intermediate':
          case 'upperIntermediate':
            color = Colors.orange;
            break;
          case 'advanced':
            color = Colors.red;
            break;
          default:
            color = Colors.grey;
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            '${entry.key}: ${entry.value} ($percentage%)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillAnalysis() {
    final analysis = stats.skillAnalysis;
    
    return Column(
      children: [
        ...analysis.criteriaScores.entries.map((entry) {
          Color color;
          switch (entry.key) {
            case 'grammar':
              color = Colors.blue;
              break;
            case 'vocabulary':
              color = Colors.green;
              break;
            case 'structure':
              color = Colors.orange;
              break;
            case 'content':
              color = Colors.purple;
              break;
            default:
              color = Colors.grey;
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSkillBar(entry.key, entry.value * 100, color),
          );
        }),
      ],
    );
  }

  Widget _buildSkillBar(String skill, double score, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            skill,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${score.toInt()}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}