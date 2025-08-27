import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/writing_provider.dart';
import '../models/writing_task.dart';
import '../models/writing_submission.dart';
import '../widgets/writing_task_card.dart';
import '../widgets/writing_stats_card.dart';
import 'widgets/writing_filter_bar.dart';
import 'writing_task_screen.dart';
import 'writing_history_screen.dart';
import 'writing_stats_screen.dart';

class WritingHomeScreen extends StatefulWidget {
  const WritingHomeScreen({super.key});

  @override
  State<WritingHomeScreen> createState() => _WritingHomeScreenState();
}

class _WritingHomeScreenState extends State<WritingHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WritingProvider>().loadTasks();
      context.read<WritingProvider>().loadStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('写作练习'),
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.purple.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WritingHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WritingStatsScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.purple.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.purple.shade700,
          tabs: const [
            Tab(text: '推荐任务'),
            Tab(text: '全部任务'),
            Tab(text: '我的草稿'),
          ],
        ),
      ),
      body: Consumer<WritingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadTasks();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 统计卡片
              if (provider.stats != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: WritingStatsCard(stats: provider.stats!),
                ),
              
              // 筛选栏
              WritingFilterBar(
                selectedType: provider.selectedType,
                selectedDifficulty: provider.selectedDifficulty,
                sortBy: provider.sortBy,
                isAscending: provider.sortAscending,
                onTypeChanged: (type) => provider.setTypeFilter(type),
                onDifficultyChanged: (difficulty) => provider.setDifficultyFilter(difficulty),
                onSortChanged: (sortBy) => provider.setSorting(sortBy),
                onClearFilters: () => provider.clearFilters(),
              ),
              
              // 任务列表
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRecommendedTasks(provider),
                    _buildAllTasks(provider),
                    _buildDrafts(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskTypeDialog();
        },
        backgroundColor: Colors.purple.shade600,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecommendedTasks(WritingProvider provider) {
    final recommendedTasks = provider.tasks
        .where((task) => task.difficulty == WritingDifficulty.intermediate)
        .take(10)
        .toList();

    if (recommendedTasks.isEmpty) {
      return _buildEmptyState('暂无推荐任务', '系统会根据您的水平推荐合适的写作任务');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recommendedTasks.length,
      itemBuilder: (context, index) {
        final task = recommendedTasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WritingTaskCard(
            task: task,
            onTap: () => _navigateToTask(task),
          ),
        );
      },
    );
  }

  Widget _buildAllTasks(WritingProvider provider) {
    if (provider.tasks.isEmpty) {
      return _buildEmptyState('暂无写作任务', '请稍后再试或联系管理员');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.tasks.length,
      itemBuilder: (context, index) {
        final task = provider.tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WritingTaskCard(
            task: task,
            onTap: () => _navigateToTask(task),
          ),
        );
      },
    );
  }

  Widget _buildDrafts(WritingProvider provider) {
    final drafts = provider.submissions
        .where((submission) => submission.status == WritingStatus.draft)
        .toList();

    if (drafts.isEmpty) {
      return _buildEmptyState('暂无草稿', '开始写作后，未提交的内容会自动保存为草稿');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final draft = drafts[index];
        return Card(
          child: ListTile(
            title: Text(
              '草稿 ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('字数: ${draft.wordCount}'),
                Text('保存时间: ${_formatDateTime(draft.submittedAt)}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: 继续编辑草稿
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToTask(WritingTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritingTaskScreen(task: task),
      ),
    );
  }

  void _showTaskTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择写作类型'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WritingType.values.map((type) {
            return ListTile(
              title: Text(type.displayName),
              onTap: () {
                Navigator.pop(context);
                _createCustomTask(type);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _createCustomTask(WritingType type) {
    // TODO: 实现自定义任务创建
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('创建${type.displayName}任务功能开发中...'),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}