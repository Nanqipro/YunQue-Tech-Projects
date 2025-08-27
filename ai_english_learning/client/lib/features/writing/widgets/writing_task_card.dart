import 'package:flutter/material.dart';
import '../models/writing_task.dart';

class WritingTaskCard extends StatelessWidget {
  final WritingTask task;
  final VoidCallback? onTap;
  final bool showProgress;

  const WritingTaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.showProgress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和类型
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(),
                ],
              ),
              const SizedBox(height: 8),
              
              // 描述
              Text(
                task.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // 任务信息
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.signal_cellular_alt,
                    label: task.difficulty.displayName,
                    color: _getDifficultyColor(),
                  ),
                  const SizedBox(width: 8),
                  if (task.timeLimit != null)
                    _buildInfoChip(
                      icon: Icons.timer,
                      label: '${task.timeLimit}分钟',
                      color: Colors.blue,
                    ),
                  const SizedBox(width: 8),
                  if (task.wordLimit != null)
                    _buildInfoChip(
                      icon: Icons.text_fields,
                      label: '${task.wordLimit}词',
                      color: Colors.green,
                    ),
                ],
              ),
              
              // 关键词
              if (task.keywords.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: task.keywords.take(3).map((keyword) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.purple.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        keyword,
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              // 进度条（如果需要显示）
              if (showProgress) ...[
                const SizedBox(height: 12),
                _buildProgressBar(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getTypeColor(),
          width: 1,
        ),
      ),
      child: Text(
        task.type.displayName,
        style: TextStyle(
          color: _getTypeColor(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    // TODO: 实现进度条逻辑
    const progress = 0.6; // 示例进度
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '完成进度',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.purple.shade600,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor() {
    switch (task.type) {
      case WritingType.essay:
        return Colors.blue;
      case WritingType.letter:
        return Colors.green;
      case WritingType.report:
        return Colors.orange;
      case WritingType.story:
        return Colors.purple;
      case WritingType.review:
        return Colors.red;
      case WritingType.argument:
        return Colors.teal;
      case WritingType.article:
        return Colors.indigo;
      case WritingType.email:
        return Colors.cyan;
      case WritingType.diary:
        return Colors.pink;
      case WritingType.description:
        return Colors.amber;
    }
  }

  Color _getDifficultyColor() {
    switch (task.difficulty) {
      case WritingDifficulty.beginner:
        return Colors.green;
      case WritingDifficulty.elementary:
        return Colors.lightGreen;
      case WritingDifficulty.intermediate:
        return Colors.orange;
      case WritingDifficulty.upperIntermediate:
        return Colors.deepOrange;
      case WritingDifficulty.advanced:
        return Colors.red;
    }
  }
}