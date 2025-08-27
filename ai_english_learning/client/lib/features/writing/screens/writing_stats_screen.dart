import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/writing_stats.dart';
import '../providers/writing_provider.dart';

class WritingStatsScreen extends StatefulWidget {
  const WritingStatsScreen({super.key});

  @override
  State<WritingStatsScreen> createState() => _WritingStatsScreenState();
}

class _WritingStatsScreenState extends State<WritingStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WritingProvider>(context, listen: false).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('写作统计'),
      ),
      body: Consumer<WritingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  ElevatedButton(
                    onPressed: () => provider.loadStats(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (provider.stats == null) {
            return const Center(
              child: Text('暂无统计数据'),
            );
          }

          final stats = provider.stats!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCard(stats),
                const SizedBox(height: 16),
                _buildTaskTypeStats(stats),
                const SizedBox(height: 16),
                _buildDifficultyStats(stats),
                const SizedBox(height: 16),
                _buildSkillAnalysis(stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(WritingStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '总体统计',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '完成任务',
                    '${stats.completedTasks}',
                    Icons.assignment_turned_in,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '总字数',
                    '${stats.totalWords}',
                    Icons.text_fields,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '平均分',
                    '${stats.averageScore.toStringAsFixed(1)}',
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTypeStats(WritingStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '任务类型分布',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...stats.taskTypeStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(entry.key),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: entry.value / stats.completedTasks,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.value}'),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyStats(WritingStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '难度分布',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...stats.difficultyStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(entry.key),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: entry.value / stats.completedTasks,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.value}'),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillAnalysis(WritingStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '技能分析',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...stats.skillAnalysis.criteriaScores.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        '${(entry.value * 10).toStringAsFixed(1)}/10',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getSkillColor(entry.value),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Color _getSkillColor(double value) {
    if (value >= 0.9) return Colors.green;
    if (value >= 0.8) return Colors.lightGreen;
    if (value >= 0.7) return Colors.orange;
    if (value >= 0.6) return Colors.deepOrange;
    return Colors.red;
  }
}