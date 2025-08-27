import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listening_exercise_model.dart';
import '../providers/listening_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../widgets/listening_exercise_card.dart';
// import '../../../shared/widgets/error_display_widget.dart';
import 'listening_exercise_screen.dart';

/// 听力训练主页面
class ListeningHomeScreen extends StatefulWidget {
  const ListeningHomeScreen({super.key});

  @override
  State<ListeningHomeScreen> createState() => _ListeningHomeScreenState();
}

class _ListeningHomeScreenState extends State<ListeningHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  ListeningExerciseType? _selectedType;
  ListeningDifficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final provider = context.read<ListeningProvider>();
    provider.fetchExercises();
    provider.fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('听力训练'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          tabs: const [
            Tab(text: '推荐', icon: Icon(Icons.recommend)),
            Tab(text: '分类', icon: Icon(Icons.category)),
            Tab(text: '统计', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendedTab(),
          _buildCategoryTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildRecommendedTab() {
    return Consumer<ListeningProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.exercises.isEmpty) {
          return const LoadingWidget(message: '加载推荐练习中...');
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('错误: ${provider.error!}'),
                ElevatedButton(
                  onPressed: () => provider.fetchRecommendedExercises(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => provider.fetchRecommendedExercises(),
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: provider.exercises.isEmpty
                    ? _buildEmptyState()
                    : _buildExerciseList(provider.exercises),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryTab() {
    return Consumer<ListeningProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: provider.isLoading && provider.exercises.isEmpty
                  ? const LoadingWidget(message: '加载练习中...')
                  : provider.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('错误: ${provider.error!}'),
                              ElevatedButton(
                                onPressed: () => _applyFilters(),
                                child: const Text('重试'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => _applyFilters(),
                          child: provider.exercises.isEmpty
                              ? _buildEmptyState()
                              : _buildExerciseList(provider.exercises),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer<ListeningProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.statistics == null) {
          return const LoadingWidget(message: '加载统计数据中...');
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('错误: ${provider.error!}'),
                ElevatedButton(
                  onPressed: () => provider.fetchStatistics(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        final stats = provider.statistics;
        if (stats == null) {
          return const Center(
            child: Text('暂无统计数据'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => provider.fetchStatistics(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatisticsCard('总练习次数', stats.totalExercises.toString()),
                const SizedBox(height: 16),
                _buildStatisticsCard('平均分数', '${stats.averageScore.toStringAsFixed(1)}%'),
                const SizedBox(height: 16),
                _buildStatisticsCard('总学习时间', '${stats.totalTimeSpent} 分钟'),
                const SizedBox(height: 16),
                _buildStatisticsCard('完成练习', '${stats.completedExercises}'),
                const SizedBox(height: 16),
                _buildDifficultyProgress(stats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索听力练习...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ListeningExerciseType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: '练习类型',
                    border: OutlineInputBorder(),
                  ),
                  items: ListeningExerciseType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<ListeningDifficulty>(
                  value: _selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: '难度等级',
                    border: OutlineInputBorder(),
                  ),
                  items: ListeningDifficulty.values.map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(_getDifficultyDisplayName(difficulty)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.filter_list),
                label: const Text('应用筛选'),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('清除筛选'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(List<ListeningExercise> exercises) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ListeningExerciseCard(
            exercise: exercise,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListeningExerciseScreen(
                    exerciseId: exercise.id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.headphones,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无听力练习',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '请尝试调整筛选条件',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyProgress(ListeningStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '各难度完成情况',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...ListeningDifficulty.values.map((difficulty) {
              final count = stats.difficultyStats[difficulty] ?? 0;
              final progress = stats.totalExercises > 0 ? count / stats.totalExercises : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_getDifficultyDisplayName(difficulty)),
                        Text('${(progress * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getDifficultyColor(difficulty),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      context.read<ListeningProvider>().fetchExercises();
    } else {
      context.read<ListeningProvider>().searchExercises(query.trim());
    }
  }

  void _applyFilters() {
    context.read<ListeningProvider>().fetchExercises(
          type: _selectedType,
          difficulty: _selectedDifficulty,
        );
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedDifficulty = null;
    });
    _applyFilters();
  }

  void _startExercise(ListeningExercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListeningExerciseScreen(
          exerciseId: exercise.id,
        ),
      ),
    );
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
}