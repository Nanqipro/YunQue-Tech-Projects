import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../models/word_model.dart';
import '../models/vocabulary_book_model.dart';
import '../providers/vocabulary_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';

/// 智能背词页面
class SmartReviewScreen extends ConsumerStatefulWidget {
  final VocabularyBook? vocabularyBook;
  final ReviewMode reviewMode;
  final int dailyTarget;

  const SmartReviewScreen({
    super.key,
    this.vocabularyBook,
    this.reviewMode = ReviewMode.adaptive,
    this.dailyTarget = 20,
  });

  @override
  ConsumerState<SmartReviewScreen> createState() => _SmartReviewScreenState();
}

class _SmartReviewScreenState extends ConsumerState<SmartReviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _progressController;
  late Animation<double> _cardAnimation;
  late Animation<double> _progressAnimation;

  List<Word> _reviewWords = [];
  int _currentWordIndex = 0;
  bool _isLoading = true;
  String? _error;
  bool _isCardFlipped = false;
  DateTime? _sessionStartTime;
  Map<String, ReviewResult> _reviewResults = {};
  ReviewSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    ));
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _initializeReview();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _initializeReview() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: 从服务获取复习单词
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求
      _reviewWords = _generateReviewWords();
      _currentSession = ReviewSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        targetCount: widget.dailyTarget,
        mode: widget.reviewMode,
      );
      
      setState(() {
        _isLoading = false;
        _sessionStartTime = DateTime.now();
      });
      
      _progressController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<Word> _generateReviewWords() {
    // TODO: 实际实现应该从服务器获取智能推荐的复习单词
    final random = Random();
    final mockWords = <Word>[];
    
    for (int i = 0; i < widget.dailyTarget; i++) {
      mockWords.add(Word(
        id: 'word_$i',
        word: 'example${i + 1}',
        phonetic: '/ɪɡˈzæmpəl/',
        definitions: [
          WordDefinition(
            type: WordType.noun,
            definition: 'A thing characteristic of its kind or illustrating a general rule.',
            translation: '例子，实例',
            frequency: (random.nextDouble() * 100).round(),
          ),
        ],
        examples: [
          WordExample(
            sentence: 'This is a good example of modern architecture.',
            translation: '这是现代建筑的一个好例子。',
          ),
        ],
        difficulty: WordDifficulty.values[random.nextInt(WordDifficulty.values.length)],
        frequency: (random.nextDouble() * 100).round(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    
    return mockWords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getScreenTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitDialog,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  String _getScreenTitle() {
    if (widget.vocabularyBook != null) {
      return '${widget.vocabularyBook!.name} - 智能背词';
    }
    return '智能背词';
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(
          message: '正在准备复习单词...',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: ErrorDisplayWidget(
          message: _error!,
          onRetry: _initializeReview,
        ),
      );
    }

    if (_reviewWords.isEmpty) {
      return const Center(
        child: EmptyDataWidget(
          message: '暂无需要复习的单词',
        ),
      );
    }

    if (_currentWordIndex >= _reviewWords.length) {
      return _buildCompletionPage();
    }

    return Column(
      children: [
        _buildProgressSection(),
        Expanded(
          child: _buildWordCard(),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildProgressSection() {
    final progress = (_currentWordIndex + 1) / _reviewWords.length;
    final completedCount = _reviewResults.length;
    final correctCount = _reviewResults.values
        .where((result) => result.isCorrect)
        .length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '进度: ${_currentWordIndex + 1}/${_reviewWords.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_sessionStartTime != null)
                Text(
                  _formatTime(DateTime.now().difference(_sessionStartTime!)),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip(
                '已完成',
                completedCount.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatChip(
                '正确率',
                completedCount > 0
                    ? '${(correctCount / completedCount * 100).round()}%'
                    : '0%',
                Icons.trending_up,
                Theme.of(context).primaryColor,
              ),
              _buildStatChip(
                '剩余',
                '${_reviewWords.length - _currentWordIndex - 1}',
                Icons.schedule,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard() {
    final word = _reviewWords[_currentWordIndex];
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: _flipCard,
        child: AnimatedBuilder(
          animation: _cardAnimation,
          builder: (context, child) {
            final isShowingFront = _cardAnimation.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_cardAnimation.value * 3.14159),
              child: isShowingFront
                  ? _buildWordFront(word)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildWordBack(word),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWordFront(Word word) {
    return CustomCard(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 难度指示器
            _buildDifficultyIndicator(word.difficulty),
            const SizedBox(height: 24),
            
            // 单词
            Text(
              word.word,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // 音标
            if (word.phonetic != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    word.phonetic!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => _playAudio(word),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            
            const Spacer(),
            
            // 提示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '点击卡片查看释义',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordBack(Word word) {
    return CustomCard(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 单词（小字）
              Center(
                child: Text(
                  word.word,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 释义
              if (word.definitions.isNotEmpty)
                ...word.definitions.map((definition) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getWordTypeColor(definition.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getWordTypeColor(definition.type).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _getWordTypeText(definition.type),
                              style: TextStyle(
                                color: _getWordTypeColor(definition.type),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        definition.definition,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (definition.translation != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          definition.translation!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
              
              // 例句
              if (word.examples.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '例句',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...word.examples.take(2).map((example) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        example.sentence,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (example.translation != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          example.translation!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyIndicator(WordDifficulty difficulty) {
    Color color;
    String text;
    int stars;

    switch (difficulty) {
      case WordDifficulty.beginner:
        color = Colors.green;
        text = '初级';
        stars = 1;
        break;
      case WordDifficulty.elementary:
        color = Colors.lightGreen;
        text = '基础';
        stars = 2;
        break;
      case WordDifficulty.intermediate:
        color = Colors.orange;
        text = '中级';
        stars = 3;
        break;
      case WordDifficulty.advanced:
        color = Colors.red;
        text = '高级';
        stars = 4;
        break;
      case WordDifficulty.expert:
        color = Colors.purple;
        text = '专家';
        stars = 5;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            5,
            (index) => Icon(
              index < stars ? Icons.star : Icons.star_border,
              size: 14,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
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

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (!_isCardFlipped)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _flipCard,
                  icon: const Icon(Icons.flip_to_back),
                  label: const Text('查看释义'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _recordResult(false),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text(
                        '不认识',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _recordResult(true),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('认识'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 12),
            
            // 快捷操作
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _markAsKnown,
                  icon: const Icon(Icons.bookmark_add),
                  tooltip: '标记为已掌握',
                ),
                IconButton(
                  onPressed: _addToFavorites,
                  icon: const Icon(Icons.favorite_border),
                  tooltip: '添加到收藏',
                ),
                IconButton(
                  onPressed: () => _playAudio(_reviewWords[_currentWordIndex]),
                  icon: const Icon(Icons.volume_up),
                  tooltip: '播放发音',
                ),
                IconButton(
                  onPressed: _showWordDetails,
                  icon: const Icon(Icons.info_outline),
                  tooltip: '查看详情',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionPage() {
    final totalWords = _reviewWords.length;
    final correctCount = _reviewResults.values
        .where((result) => result.isCorrect)
        .length;
    final accuracy = totalWords > 0 ? (correctCount / totalWords * 100).round() : 0;
    final totalTime = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 完成卡片
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.celebration,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '今日复习完成！',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '恭喜您完成了今天的复习任务',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 统计信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCompletionStat(
                        '复习单词',
                        totalWords.toString(),
                        Icons.book,
                        Theme.of(context).primaryColor,
                      ),
                      _buildCompletionStat(
                        '掌握率',
                        '$accuracy%',
                        Icons.trending_up,
                        _getAccuracyColor(accuracy),
                      ),
                      _buildCompletionStat(
                        '用时',
                        _formatTime(totalTime),
                        Icons.timer,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 需要加强的单词
          _buildWeakWordsCard(),
          
          const SizedBox(height: 24),
          
          // 操作按钮
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _continueReview,
                  icon: const Icon(Icons.refresh),
                  label: const Text('继续复习'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home),
                  label: const Text('返回首页'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWeakWordsCard() {
    final weakWords = _reviewResults.entries
        .where((entry) => !entry.value.isCorrect)
        .map((entry) => _reviewWords.firstWhere((word) => word.id == entry.key))
        .toList();
    
    if (weakWords.isEmpty) {
      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.star,
                size: 48,
                color: Colors.amber,
              ),
              const SizedBox(height: 12),
              Text(
                '全部掌握！',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '恭喜您全部单词都已掌握！',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.priority_high, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '需要加强 (${weakWords.length}个)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...weakWords.take(5).map((word) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.word,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (word.definitions.isNotEmpty)
                          Text(
                            word.definitions.first.translation ?? word.definitions.first.definition,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => _reviewAgain(word),
                    color: Colors.orange,
                  ),
                ],
              ),
            )),
            if (weakWords.length > 5)
              Text(
                '还有 ${weakWords.length - 5} 个单词需要加强...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _flipCard() {
    if (_cardController.isCompleted) {
      _cardController.reverse();
      setState(() {
        _isCardFlipped = false;
      });
    } else {
      _cardController.forward();
      setState(() {
        _isCardFlipped = true;
      });
    }
  }

  void _recordResult(bool isCorrect) {
    final word = _reviewWords[_currentWordIndex];
    _reviewResults[word.id] = ReviewResult(
      wordId: word.id,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
      reviewTime: _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!)
          : Duration.zero,
    );
    
    _nextWord();
  }

  void _nextWord() {
    if (_currentWordIndex < _reviewWords.length - 1) {
      setState(() {
        _currentWordIndex++;
        _isCardFlipped = false;
      });
      _cardController.reset();
    } else {
      // 复习完成
      setState(() {
        _currentWordIndex++;
      });
    }
  }

  void _markAsKnown() {
    // TODO: 实现标记为已掌握功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已标记为掌握')),
    );
  }

  void _addToFavorites() {
    // TODO: 实现添加到收藏功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已添加到收藏')),
    );
  }

  void _playAudio(Word word) {
    // TODO: 实现音频播放功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('播放 ${word.word} 的发音')),
    );
  }

  void _showWordDetails() {
    // TODO: 实现显示单词详情功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('查看单词详情')),
    );
  }

  void _continueReview() {
    // TODO: 实现继续复习功能
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SmartReviewScreen(
          vocabularyBook: widget.vocabularyBook,
          reviewMode: widget.reviewMode,
          dailyTarget: widget.dailyTarget,
        ),
      ),
    );
  }

  void _reviewAgain(Word word) {
    // TODO: 实现重新复习单个单词功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('重新复习 ${word.word}')),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('复习设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('每日目标'),
              subtitle: Text('${widget.dailyTarget} 个单词'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // TODO: 实现修改每日目标功能
              },
            ),
            ListTile(
              title: const Text('复习模式'),
              subtitle: Text(_getReviewModeText(widget.reviewMode)),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // TODO: 实现修改复习模式功能
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出复习'),
        content: const Text('确定要退出当前复习吗？进度将会保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
              Navigator.of(context).pop(); // 退出复习页面
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Color _getWordTypeColor(WordType type) {
    switch (type) {
      case WordType.noun:
        return Colors.blue;
      case WordType.verb:
        return Colors.green;
      case WordType.adjective:
        return Colors.orange;
      case WordType.adverb:
        return Colors.purple;
      case WordType.preposition:
        return Colors.red;
      case WordType.conjunction:
        return Colors.teal;
      case WordType.interjection:
        return Colors.pink;
      case WordType.pronoun:
        return Colors.indigo;
      case WordType.article:
         return Colors.brown;
       case WordType.phrase:
         return Colors.purple;
     }
  }

  String _getWordTypeText(WordType type) {
    switch (type) {
      case WordType.noun:
        return 'n.';
      case WordType.verb:
        return 'v.';
      case WordType.adjective:
        return 'adj.';
      case WordType.adverb:
        return 'adv.';
      case WordType.preposition:
        return 'prep.';
      case WordType.conjunction:
        return 'conj.';
      case WordType.interjection:
        return 'interj.';
      case WordType.pronoun:
        return 'pron.';
      case WordType.article:
         return 'art.';
       case WordType.phrase:
         return 'phrase';
     }
  }

  String _getReviewModeText(ReviewMode mode) {
    switch (mode) {
      case ReviewMode.adaptive:
        return '智能适应';
      case ReviewMode.sequential:
        return '顺序复习';
      case ReviewMode.random:
        return '随机复习';
      case ReviewMode.difficulty:
        return '按难度复习';
    }
  }

  Color _getAccuracyColor(int accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 80) return Colors.lightGreen;
    if (accuracy >= 70) return Colors.orange;
    if (accuracy >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 复习模式
enum ReviewMode {
  adaptive,    // 智能适应
  sequential,  // 顺序复习
  random,      // 随机复习
  difficulty,  // 按难度复习
}

/// 复习结果
class ReviewResult {
  final String wordId;
  final bool isCorrect;
  final DateTime timestamp;
  final Duration reviewTime;

  ReviewResult({
    required this.wordId,
    required this.isCorrect,
    required this.timestamp,
    required this.reviewTime,
  });
}

/// 复习会话
class ReviewSession {
  final String id;
  final DateTime startTime;
  final int targetCount;
  final ReviewMode mode;
  DateTime? endTime;
  Map<String, ReviewResult> results = {};

  ReviewSession({
    required this.id,
    required this.startTime,
    required this.targetCount,
    required this.mode,
    this.endTime,
  });

  double get accuracy {
    if (results.isEmpty) return 0.0;
    final correctCount = results.values.where((r) => r.isCorrect).length;
    return correctCount / results.length;
  }

  Duration get totalTime {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isCompleted => results.length >= targetCount;
}