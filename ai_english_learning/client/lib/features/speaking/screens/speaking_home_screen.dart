import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/speaking_scenario.dart';
import '../providers/speaking_provider.dart';
import '../widgets/speaking_task_card.dart';
import '../widgets/speaking_filter_bar.dart';
import '../widgets/speaking_stats_card.dart';
import 'speaking_conversation_screen.dart';
import 'speaking_history_screen.dart';
import 'speaking_stats_screen.dart';

class SpeakingHomeScreen extends StatefulWidget {
  const SpeakingHomeScreen({super.key});

  @override
  State<SpeakingHomeScreen> createState() => _SpeakingHomeScreenState();
}

class _SpeakingHomeScreenState extends State<SpeakingHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  SpeakingScenario? _selectedScenario;
  SpeakingDifficulty? _selectedDifficulty;
  String _sortBy = 'recommended';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<SpeakingProvider>();
    await Future.wait([
      provider.loadTasks(),
      provider.loadStats(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('口语练习'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _navigateToHistory(),
            tooltip: '练习历史',
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _navigateToStats(),
            tooltip: '学习统计',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '推荐练习'),
            Tab(text: '全部场景'),
            Tab(text: '我的收藏'),
          ],
        ),
      ),
      body: Consumer<SpeakingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.tasks.isEmpty) {
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
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialData,
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SpeakingStatsCard(stats: provider.stats!),
                ),
              
              // 筛选栏
              SpeakingFilterBar(
                selectedScenario: _selectedScenario,
                selectedDifficulty: _selectedDifficulty,
                sortBy: _sortBy,
                onScenarioChanged: _onScenarioChanged,
                onDifficultyChanged: _onDifficultyChanged,
                onSortChanged: _onSortChanged,
              ),
              
              // 任务列表
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRecommendedTasks(provider),
                    _buildAllTasks(provider),
                    _buildFavoriteTasks(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCustomTaskDialog,
        child: const Icon(Icons.add),
        tooltip: '自定义练习',
      ),
    );
  }

  Widget _buildRecommendedTasks(SpeakingProvider provider) {
    final recommendedTasks = provider.tasks
        .where((task) => task.isRecommended)
        .toList();

    if (recommendedTasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.recommend_outlined,
        title: '暂无推荐练习',
        subtitle: '系统会根据您的学习情况推荐合适的练习',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommendedTasks.length,
        itemBuilder: (context, index) {
          final task = recommendedTasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SpeakingTaskCard(
              task: task,
              onTap: () => _navigateToConversation(task),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllTasks(SpeakingProvider provider) {
    final filteredTasks = _getFilteredTasks(provider.tasks);

    if (filteredTasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: '没有找到匹配的练习',
        subtitle: '请尝试调整筛选条件',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SpeakingTaskCard(
              task: task,
              onTap: () => _navigateToConversation(task),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteTasks(SpeakingProvider provider) {
    final favoriteTasks = provider.tasks
        .where((task) => task.isFavorite)
        .toList();

    if (favoriteTasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        title: '暂无收藏的练习',
        subtitle: '点击练习卡片上的收藏按钮来收藏练习',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteTasks.length,
        itemBuilder: (context, index) {
          final task = favoriteTasks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SpeakingTaskCard(
              task: task,
              onTap: () => _navigateToConversation(task),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<SpeakingTask> _getFilteredTasks(List<SpeakingTask> tasks) {
    var filteredTasks = tasks.where((task) {
      if (_selectedScenario != null && task.scenario != _selectedScenario) {
        return false;
      }
      if (_selectedDifficulty != null && task.difficulty != _selectedDifficulty) {
        return false;
      }
      return true;
    }).toList();

    // 排序
    switch (_sortBy) {
      case 'difficulty':
        filteredTasks.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
        break;
      case 'duration':
        filteredTasks.sort((a, b) => a.estimatedDuration.compareTo(b.estimatedDuration));
        break;
      case 'popularity':
        filteredTasks.sort((a, b) => b.completionCount.compareTo(a.completionCount));
        break;
      case 'recommended':
      default:
        // 保持原有顺序（推荐排序）
        break;
    }

    return filteredTasks;
  }

  void _onScenarioChanged(SpeakingScenario? scenario) {
    setState(() {
      _selectedScenario = scenario;
    });
    _applyFilters();
  }

  void _onDifficultyChanged(SpeakingDifficulty? difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    _applyFilters();
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    final provider = context.read<SpeakingProvider>();
    await provider.loadTasksByFilter(
      scenario: _selectedScenario,
      difficulty: _selectedDifficulty,
      sortBy: _sortBy,
    );
  }

  void _navigateToConversation(SpeakingTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeakingConversationScreen(task: task),
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SpeakingHistoryScreen(),
      ),
    );
  }

  void _navigateToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SpeakingStatsScreen(),
      ),
    );
  }

  void _showCustomTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义练习'),
        content: const Text('自定义练习功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}