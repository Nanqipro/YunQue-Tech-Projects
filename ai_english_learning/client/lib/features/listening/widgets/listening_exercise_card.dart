import 'package:flutter/material.dart';
import '../models/listening_exercise_model.dart';

/// 听力练习卡片组件
class ListeningExerciseCard extends StatelessWidget {
  final ListeningExercise exercise;
  final VoidCallback? onTap;
  final bool showProgress;
  final double? progress;

  const ListeningExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildDifficultyChip(context),
                ],
              ),
              if (exercise.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  exercise.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    Icons.access_time,
                    '${exercise.duration}s',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    Icons.quiz,
                    '${exercise.questions.length}题',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    _getTypeIcon(exercise.type),
                    _getTypeDisplayName(exercise.type),
                  ),
                ],
              ),
              if (showProgress && progress != null) ...[
                const SizedBox(height: 12),
                _buildProgressBar(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(BuildContext context) {
    final color = _getDifficultyColor(exercise.difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getDifficultyDisplayName(exercise.difficulty),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '进度',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(progress! * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  String _getDifficultyDisplayName(ListeningDifficulty difficulty) {
    switch (difficulty) {
      case ListeningDifficulty.beginner:
        return '初级';
      case ListeningDifficulty.elementary:
        return '基础';
      case ListeningDifficulty.intermediate:
        return '中级';
      case ListeningDifficulty.advanced:
        return '高级';
      case ListeningDifficulty.expert:
        return '专家';
    }
  }

  String _getTypeDisplayName(ListeningExerciseType type) {
    switch (type) {
      case ListeningExerciseType.conversation:
        return '对话';
      case ListeningExerciseType.lecture:
        return '讲座';
      case ListeningExerciseType.news:
        return '新闻';
      case ListeningExerciseType.story:
        return '故事';
      case ListeningExerciseType.interview:
        return '访谈';
      case ListeningExerciseType.dialogue:
        return '对话';
    }
  }

  Color _getDifficultyColor(ListeningDifficulty difficulty) {
    switch (difficulty) {
      case ListeningDifficulty.beginner:
        return Colors.green;
      case ListeningDifficulty.elementary:
        return Colors.lightGreen;
      case ListeningDifficulty.intermediate:
        return Colors.orange;
      case ListeningDifficulty.advanced:
        return Colors.red;
      case ListeningDifficulty.expert:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(ListeningExerciseType type) {
    switch (type) {
      case ListeningExerciseType.conversation:
      case ListeningExerciseType.dialogue:
        return Icons.chat;
      case ListeningExerciseType.lecture:
        return Icons.school;
      case ListeningExerciseType.news:
        return Icons.newspaper;
      case ListeningExerciseType.story:
        return Icons.book;
      case ListeningExerciseType.interview:
        return Icons.mic;
    }
  }
}