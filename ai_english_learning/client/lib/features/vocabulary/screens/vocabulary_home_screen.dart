import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../models/vocabulary_book_model.dart';
import '../providers/vocabulary_provider.dart';
import 'vocabulary_book_screen.dart';
import 'word_learning_screen.dart';
import 'vocabulary_test_screen.dart';
import 'study_statistics_screen.dart';

/// 单词学习主页
class VocabularyHomeScreen extends ConsumerStatefulWidget {
  const VocabularyHomeScreen({super.key});

  @override
  ConsumerState<VocabularyHomeScreen> createState() => _VocabularyHomeScreenState;
}

class _VocabularyHomeScreenState extends ConsumerState<VocabularyHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 初始化加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vocabularyProvider.notifier).loadSystemVocabularyBooks();
      ref.read(vocabularyProvider.notifier).loadUserVocabularyBooks();
      ref.read(vocabularyProvider.notifier).loadTodayStudyWords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyState = ref.watch(vocabularyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: '单词学习',
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudyStatisticsScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '今日学习', icon: Icon(Icons.today)),
            Tab(text: '词汇书', icon: Icon(Icons.book)),
            Tab(text: '我的词汇', icon: Icon(Icons.bookmark)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayStudyTab(vocabularyState, theme),
          _buildVocabularyBooksTab(vocabularyState, theme),
          _buildMyVocabularyTab(vocabularyState, theme),
        ],
      ),
    );
  }

  /// 今日学习标签页
  Widget _buildTodayStudyTab(VocabularyState state, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(vocabularyProvider.notifier).loadTodayStudyWords();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 学习进度卡片
            _buildStudyProgressCard(state, theme),
            const SizedBox(height: 16),
            
            // 快速学习入口
            _buildQuickStudySection(theme),
            const SizedBox(height: 16),
            
            // 今日单词
            _buildTodayWordsSection(state, theme),
          ],
        ),
      ),
    );
  }

  /// 词汇书标签页
  Widget _buildVocabularyBooksTab(VocabularyState state, ThemeData theme) {
    if (state.isLoading && state.systemBooks.isEmpty) {
      return const LoadingWidget();
    }

    if (state.error != null && state.systemBooks.isEmpty) {
      return CustomErrorWidget(
        message: state.error!,
        onRetry: () {
          ref.read(vocabularyProvider.notifier).loadSystemVocabularyBooks();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(vocabularyProvider.notifier).loadSystemVocabularyBooks();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.systemBooks.length,
        itemBuilder: (context, index) {
          final book = state.systemBooks[index];
          return _buildVocabularyBookCard(book, theme);
        },
      ),
    );
  }

  /// 我的词汇标签页
  Widget _buildMyVocabularyTab(VocabularyState state, ThemeData theme) {
    if (state.isLoading && state.userBooks.isEmpty) {
      return const LoadingWidget();
    }

    if (state.userBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '还没有添加词汇书',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '去词汇书页面添加感兴趣的词汇书吧',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              child: const Text('浏览词汇书'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(vocabularyProvider.notifier).loadUserVocabularyBooks();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.userBooks.length,
        itemBuilder: (context, index) {
          final book = state.userBooks[index];
          return _buildMyVocabularyBookCard(book, theme);
        },
      ),
    );
  }

  /// 学习进度卡片
  Widget _buildStudyProgressCard(VocabularyState state, ThemeData theme) {
    final todayStats = state.todayStatistics;
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日学习进度',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (todayStats != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      '新学单词',
                      '${todayStats.newWordsLearned}',
                      Icons.add_circle_outline,
                      theme.colorScheme.primary,
                      theme,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      '复习单词',
                      '${todayStats.wordsReviewed}',
                      Icons.refresh,
                      theme.colorScheme.secondary,
                      theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      '学习时长',
                      '${todayStats.studyTimeMinutes}分钟',
                      Icons.access_time,
                      theme.colorScheme.tertiary,
                      theme,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      '正确率',
                      '${(todayStats.accuracy * 100).toInt()}%',
                      Icons.check_circle_outline,
                      Colors.green,
                      theme,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Center(
                child: Text(
                  '今天还没有学习记录',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 统计项目
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
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
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  /// 快速学习区域
  Widget _buildQuickStudySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速开始',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickStudyCard(
                '智能学习',
                '根据遗忘曲线智能安排',
                Icons.psychology,
                theme.colorScheme.primary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordLearningScreen(
                        mode: StudyMode.smart,
                      ),
                    ),
                  );
                },
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStudyCard(
                '词汇量测试',
                '测试你的词汇水平',
                Icons.quiz,
                theme.colorScheme.secondary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VocabularyTestScreen(),
                    ),
                  );
                },
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 快速学习卡片
  Widget _buildQuickStudyCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 今日单词区域
  Widget _buildTodayWordsSection(VocabularyState state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '今日单词',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (state.todayWords.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordLearningScreen(
                        mode: StudyMode.today,
                      ),
                    ),
                  );
                },
                child: const Text('查看全部'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (state.todayWords.isEmpty) ...[
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '今天的学习任务已完成！',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.todayWords.take(5).length,
              itemBuilder: (context, index) {
                final word = state.todayWords[index];
                return Container(
                  width: 200,
                  margin: EdgeInsets.only(
                    right: index < state.todayWords.length - 1 ? 12 : 0,
                  ),
                  child: _buildTodayWordCard(word, theme),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// 今日单词卡片
  Widget _buildTodayWordCard(Word word, ThemeData theme) {
    return CustomCard(
      onTap: () {
        // TODO: 显示单词详情
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word.word,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (word.phonetic != null) ...[
              const SizedBox(height: 4),
              Text(
                word.phonetic!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                word.definitions.isNotEmpty
                    ? word.definitions.first.definition
                    : '暂无释义',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 词汇书卡片
  Widget _buildVocabularyBookCard(VocabularyBook book, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VocabularyBookScreen(book: book),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 封面图标
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getBookColor(book.difficulty),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getBookIcon(book.type),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // 书籍信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBookTag(
                          _getDifficultyText(book.difficulty),
                          _getBookColor(book.difficulty),
                          theme,
                        ),
                        const SizedBox(width: 8),
                        _buildBookTag(
                          '${book.wordCount}词',
                          theme.colorScheme.outline,
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 操作按钮
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  ref.read(vocabularyProvider.notifier)
                      .addVocabularyBookToUser(book.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 我的词汇书卡片
  Widget _buildMyVocabularyBookCard(VocabularyBook book, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VocabularyBookScreen(book: book),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 封面图标
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getBookColor(book.difficulty),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getBookIcon(book.type),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // 书籍信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // 学习进度
                    if (book.userProgress != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: book.userProgress!.progress,
                              backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getBookColor(book.difficulty),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(book.userProgress!.progress * 100).toInt()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '已学 ${book.userProgress!.learnedWords}/${book.wordCount} 词',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 继续学习按钮
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordLearningScreen(
                        mode: StudyMode.book,
                        bookId: book.id,
                      ),
                    ),
                  );
                },
                child: const Text('学习'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 书籍标签
  Widget _buildBookTag(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 获取书籍颜色
  Color _getBookColor(VocabularyBookDifficulty difficulty) {
    switch (difficulty) {
      case VocabularyBookDifficulty.beginner:
        return Colors.green;
      case VocabularyBookDifficulty.intermediate:
        return Colors.orange;
      case VocabularyBookDifficulty.advanced:
        return Colors.red;
      case VocabularyBookDifficulty.expert:
        return Colors.purple;
    }
  }

  /// 获取书籍图标
  IconData _getBookIcon(VocabularyBookType type) {
    switch (type) {
      case VocabularyBookType.system:
        return Icons.book;
      case VocabularyBookType.custom:
        return Icons.edit;
      case VocabularyBookType.imported:
        return Icons.download;
    }
  }

  /// 获取难度文本
  String _getDifficultyText(VocabularyBookDifficulty difficulty) {
    switch (difficulty) {
      case VocabularyBookDifficulty.beginner:
        return '初级';
      case VocabularyBookDifficulty.intermediate:
        return '中级';
      case VocabularyBookDifficulty.advanced:
        return '高级';
      case VocabularyBookDifficulty.expert:
        return '专家';
    }
  }
}