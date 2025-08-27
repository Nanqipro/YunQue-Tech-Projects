import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary_book_model.dart';
import '../models/word_model.dart';
import '../providers/vocabulary_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import 'word_learning_screen.dart';

/// 词汇书详情页面
class VocabularyBookScreen extends ConsumerStatefulWidget {
  final VocabularyBook vocabularyBook;

  const VocabularyBookScreen({
    super.key,
    required this.vocabularyBook,
  });

  @override
  ConsumerState<VocabularyBookScreen> createState() => _VocabularyBookScreenState();
}

class _VocabularyBookScreenState extends ConsumerState<VocabularyBookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedDifficulty = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 加载词汇书单词
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: 实现loadVocabularyBookWords方法
      // ref.read(vocabularyProvider.notifier).loadVocabularyBookWords(
      //   widget.vocabularyBook.id,
      // );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyState = ref.watch(vocabularyProvider);
    
    return Scaffold(
      appBar: TabAppBar(
        title: widget.vocabularyBook.name,
        tabs: const [
          Tab(text: '单词列表'),
          Tab(text: '学习进度'),
          Tab(text: '统计信息'),
        ],
        controller: _tabController,
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWordListTab(vocabularyState),
          _buildProgressTab(vocabularyState),
          _buildStatisticsTab(vocabularyState),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startLearning(context),
        icon: const Icon(Icons.school),
        label: const Text('开始学习'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildWordListTab(VocabularyState state) {
    if (state.isLoading) {
      return const Center(
        child: LoadingWidget(message: '加载单词列表中...'),
      );
    }

    if (state.error != null) {
      return Center(
        child: ErrorDisplayWidget(
          message: state.error!,
          onRetry: () {
            // TODO: 实现loadVocabularyBookWords方法
            // ref.read(vocabularyProvider.notifier)
            //     .loadVocabularyBookWords(widget.vocabularyBook.id);
          },
        ),
      );
    }

    final words = _getFilteredWords(state.todayWords); // 使用todayWords作为临时替代

    if (words.isEmpty) {
      return const Center(
        child: EmptyDataWidget(
          title: '暂无单词',
          message: '该词汇书中还没有单词',
          icon: Icons.book_outlined,
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicatorWidget(
            onRefresh: () async {
               // TODO: 实现loadVocabularyBookWords方法
               // await ref.read(vocabularyProvider.notifier)
               //     .loadVocabularyBookWords(widget.vocabularyBook.id);
             },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[index];
                return _buildWordCard(word);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTab(VocabularyState state) {
    if (state.isLoading) {
      return const Center(
        child: LoadingWidget(message: '加载学习进度中...'),
      );
    }

    final words = state.todayWords; // 使用todayWords作为临时替代
    if (words.isEmpty) {
      return const Center(
        child: EmptyDataWidget(
          title: '暂无进度数据',
          message: '开始学习后将显示进度信息',
          icon: Icons.trending_up,
        ),
      );
    }

    final totalWords = words.length;
    // TODO: 添加userProgress字段到Word模型
    final learnedWords = 0; // words.where((w) => w.userProgress?.status == 'mastered').length;
    final learningWords = 0; // words.where((w) => w.userProgress?.status == 'learning').length;
    final newWords = words.length; // words.where((w) => w.userProgress?.status == 'new' || w.userProgress == null).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressOverview(totalWords, learnedWords, learningWords, newWords),
          const SizedBox(height: 24),
          _buildProgressChart(learnedWords, learningWords, newWords),
          const SizedBox(height: 24),
          _buildDifficultyBreakdown(words),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(VocabularyState state) {
    if (state.isLoading) {
      return const Center(
        child: LoadingWidget(message: '加载统计信息中...'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookInfo(),
          const SizedBox(height: 24),
          _buildLearningStats(state),
          const SizedBox(height: 24),
          _buildRecentActivity(state),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索单词...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildWordCard(Word word) {
    final theme = Theme.of(context);
    // TODO: 添加userProgress字段到Word模型
    // final progress = word.userProgress;
    final progress = null; // 临时设置为null
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (progress?.status) {
      case 'mastered':
        statusColor = Colors.green;
        statusText = '已掌握';
        statusIcon = Icons.check_circle;
        break;
      case 'learning':
        statusColor = Colors.orange;
        statusText = '学习中';
        statusIcon = Icons.school;
        break;
      default:
        statusColor = theme.colorScheme.outline;
        statusText = '未学习';
        statusIcon = Icons.circle_outlined;
    }

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showWordDetail(word),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (word.phonetic != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        word.phonetic!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            word.definitions.isNotEmpty 
                ? word.definitions.first.definition
                : '暂无释义',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (progress != null && progress.accuracy != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '准确率: ${(progress.accuracy! * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressOverview(int total, int learned, int learning, int newWords) {
    final theme = Theme.of(context);
    final progress = total > 0 ? learned / total : 0.0;
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '学习进度',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  '总计',
                  total.toString(),
                  Icons.book,
                  theme.colorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  '已掌握',
                  learned.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  '学习中',
                  learning.toString(),
                  Icons.school,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  '未学习',
                  newWords.toString(),
                  Icons.circle_outlined,
                  theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart(int learned, int learning, int newWords) {
    // 这里可以集成图表库来显示更详细的进度图表
    // 暂时使用简单的条形图表示
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '学习分布',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 简单的条形图
          _buildSimpleBarChart(learned, learning, newWords),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(int learned, int learning, int newWords) {
    final total = learned + learning + newWords;
    if (total == 0) return const SizedBox();
    
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          children: [
            if (learned > 0)
              Expanded(
                flex: learned,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(4),
                      bottomLeft: const Radius.circular(4),
                      topRight: learning == 0 && newWords == 0 
                          ? const Radius.circular(4) 
                          : Radius.zero,
                      bottomRight: learning == 0 && newWords == 0 
                          ? const Radius.circular(4) 
                          : Radius.zero,
                    ),
                  ),
                ),
              ),
            if (learning > 0)
              Expanded(
                flex: learning,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.only(
                      topLeft: learned == 0 
                          ? const Radius.circular(4) 
                          : Radius.zero,
                      bottomLeft: learned == 0 
                          ? const Radius.circular(4) 
                          : Radius.zero,
                      topRight: newWords == 0 
                          ? const Radius.circular(4) 
                          : Radius.zero,
                      bottomRight: newWords == 0 
                          ? const Radius.circular(4) 
                          : Radius.zero,
                    ),
                  ),
                ),
              ),
            if (newWords > 0)
              Expanded(
                flex: newWords,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem('已掌握', Colors.green, learned),
            _buildLegendItem('学习中', Colors.orange, learning),
            _buildLegendItem('未学习', theme.colorScheme.outline, newWords),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDifficultyBreakdown(List<Word> words) {
    final easy = words.where((w) => w.difficulty == WordDifficulty.beginner || w.difficulty == WordDifficulty.elementary).length;
     final medium = words.where((w) => w.difficulty == WordDifficulty.intermediate).length;
     final hard = words.where((w) => w.difficulty == WordDifficulty.advanced || w.difficulty == WordDifficulty.expert).length;
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '难度分布',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: '简单',
                  value: easy.toString(),
                  icon: Icons.sentiment_satisfied,
                  iconColor: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: '中等',
                  value: medium.toString(),
                  icon: Icons.sentiment_neutral,
                  iconColor: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: '困难',
                  value: hard.toString(),
                  icon: Icons.sentiment_dissatisfied,
                  iconColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookInfo() {
    final theme = Theme.of(context);
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '词汇书信息',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('名称', widget.vocabularyBook.name),
          _buildInfoRow('描述', widget.vocabularyBook.description ?? '暂无描述'),
          _buildInfoRow('类型', widget.vocabularyBook.type == VocabularyBookType.system ? '系统词汇书' : '用户词汇书'),
          _buildInfoRow('难度', _getDifficultyText(widget.vocabularyBook.difficulty.name)),
          _buildInfoRow('单词数量', '${widget.vocabularyBook.totalWords} 个'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStats(VocabularyState state) {
    // 这里可以显示学习统计信息
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '学习统计',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: '学习天数',
                  value: '0',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: '平均准确率',
                  value: '0%',
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(VocabularyState state) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最近活动',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const EmptyDataWidget(
            message: '暂无学习记录',
            icon: Icons.history,
          ),
        ],
      ),
    );
  }

  List<Word> _getFilteredWords(List<Word> words) {
    return words.where((word) {
      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!word.word.toLowerCase().contains(query) &&
            !word.definitions.any((d) => d.definition.toLowerCase().contains(query))) {
          return false;
        }
      }
      
      // 难度过滤
      if (_selectedDifficulty != 'all' && word.difficulty.name != _selectedDifficulty) {
        return false;
      }
      
      // 状态过滤
      if (_selectedStatus != 'all') {
        // TODO: 添加userProgress字段到Word模型
        // final status = word.userProgress?.status ?? 'new';
        final status = 'new'; // 临时设置
        if (status != _selectedStatus) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  String _getDifficultyText(String? difficulty) {
    switch (difficulty) {
      case 'easy':
        return '简单';
      case 'medium':
        return '中等';
      case 'hard':
        return '困难';
      default:
        return '未知';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选条件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('难度'),
            DropdownButton<String>(
              value: _selectedDifficulty,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('全部')),
                DropdownMenuItem(value: 'easy', child: Text('简单')),
                DropdownMenuItem(value: 'medium', child: Text('中等')),
                DropdownMenuItem(value: 'hard', child: Text('困难')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('学习状态'),
            DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('全部')),
                DropdownMenuItem(value: 'new', child: Text('未学习')),
                DropdownMenuItem(value: 'learning', child: Text('学习中')),
                DropdownMenuItem(value: 'mastered', child: Text('已掌握')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showWordDetail(Word word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(word.word),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (word.phonetic != null) ...[
              Text(
                '音标: ${word.phonetic}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              '释义:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...word.definitions.map((definition) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text('• ${definition.type.name}: ${definition.definition}'),
            )),
            if (word.examples.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '例句:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  word.examples.first.sentence,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startWordLearning([word]);
            },
            child: const Text('学习'),
          ),
        ],
      ),
    );
  }

  void _startLearning(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WordLearningScreen(
          vocabularyBook: widget.vocabularyBook,
        ),
      ),
    );
  }

  void _startWordLearning(List<Word> words) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WordLearningScreen(
          vocabularyBook: widget.vocabularyBook,
          specificWords: words,
        ),
      ),
    );
  }
}