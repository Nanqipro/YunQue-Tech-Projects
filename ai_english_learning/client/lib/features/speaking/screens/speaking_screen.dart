import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/speaking_provider.dart';
import '../models/speaking_scenario.dart';
import 'speaking_conversation_screen.dart';
import 'speaking_history_screen.dart';
import 'speaking_stats_screen.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDifficulty = 'all';
  String _selectedScenario = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpeakingProvider>().loadTasks();
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
        title: const Text('口语练习'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade800,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue.shade600,
          tabs: const [
            Tab(
              icon: Icon(Icons.chat_bubble_outline),
              text: '练习',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: '历史',
            ),
            Tab(
              icon: Icon(Icons.analytics_outlined),
              text: '统计',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPracticeTab(),
          const SpeakingHistoryScreen(),
          const SpeakingStatsScreen(),
        ],
      ),
    );
  }

  Widget _buildPracticeTab() {
    return Consumer<SpeakingProvider>(
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
                  '加载失败',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadTasks(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        final filteredTasks = _filterTasks(provider.tasks);

        return Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: filteredTasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTaskList(filteredTasks),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 搜索框
          TextField(
            decoration: InputDecoration(
              hintText: '搜索练习内容...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // 筛选器
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  '难度',
                  _selectedDifficulty,
                  [
                    {'value': 'all', 'label': '全部'},
                    {'value': 'beginner', 'label': '初级'},
                    {'value': 'intermediate', 'label': '中级'},
                    {'value': 'advanced', 'label': '高级'},
                  ],
                  (value) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  '场景',
                  _selectedScenario,
                  [
                    {'value': 'all', 'label': '全部'},
                    {'value': 'dailyConversation', 'label': '日常对话'},
                    {'value': 'businessMeeting', 'label': '商务会议'},
                    {'value': 'travel', 'label': '旅行'},
                    {'value': 'academic', 'label': '学术讨论'},
                  ],
                  (value) {
                    setState(() {
                      _selectedScenario = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<Map<String, String>> options,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(label),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(option['label']!),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无练习内容',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请尝试调整筛选条件',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<SpeakingTask> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(SpeakingTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _startTask(task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chat,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTaskTag(
                    _getDifficultyLabel(task.difficulty),
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildTaskTag(
                    _getScenarioLabel(task.scenario),
                    Colors.green,
                  ),
                  const Spacer(),
                  Text(
                    '${task.estimatedDuration}分钟',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
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

  Widget _buildTaskTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<SpeakingTask> _filterTasks(List<SpeakingTask> tasks) {
    return tasks.where((task) {
      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!task.title.toLowerCase().contains(query) &&
            !task.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 难度过滤
      if (_selectedDifficulty != 'all' &&
          task.difficulty.toString().split('.').last != _selectedDifficulty) {
        return false;
      }

      // 场景过滤
      if (_selectedScenario != 'all' &&
          task.scenario.toString().split('.').last != _selectedScenario) {
        return false;
      }

      return true;
    }).toList();
  }

  String _getDifficultyLabel(SpeakingDifficulty difficulty) {
    return difficulty.displayName;
  }

  String _getScenarioLabel(SpeakingScenario scenario) {
    return scenario.displayName;
  }

  void _startTask(SpeakingTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeakingConversationScreen(task: task),
      ),
    );
  }
}