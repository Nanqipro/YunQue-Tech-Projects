import 'package:flutter/material.dart';
import '../models/speaking_scenario.dart';

class SpeakingTaskCard extends StatelessWidget {
  final SpeakingTask task;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const SpeakingTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onFavorite,
  });

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
              // 标题和收藏按钮
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      task.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: task.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: onFavorite,
                    tooltip: task.isFavorite ? '取消收藏' : '收藏',
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 描述
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // 标签行
              Row(
                children: [
                  // 场景标签
                  _buildTag(
                    context,
                    task.scenario.displayName,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  
                  // 难度标签
                  _buildTag(
                    context,
                    task.difficulty.displayName,
                    _getDifficultyColor(task.difficulty),
                  ),
                  
                  const Spacer(),
                  
                  // 推荐标签
                  if (task.isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '推荐',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 底部信息
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.estimatedDuration}分钟',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.completionCount}人完成',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // 开始按钮
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      '开始练习',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getDifficultyColor(SpeakingDifficulty difficulty) {
    switch (difficulty) {
      case SpeakingDifficulty.beginner:
        return Colors.green;
      case SpeakingDifficulty.elementary:
        return Colors.lightGreen;
      case SpeakingDifficulty.intermediate:
        return Colors.orange;
      case SpeakingDifficulty.upperIntermediate:
        return Colors.deepOrange;
      case SpeakingDifficulty.advanced:
        return Colors.red;
    }
  }
}