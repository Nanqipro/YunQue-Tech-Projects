import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word_model.dart';
import '../models/vocabulary_book_model.dart';
import '../providers/vocabulary_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';

/// 单词学习页面
class WordLearningScreen extends ConsumerStatefulWidget {
  final VocabularyBook vocabularyBook;
  final List<Word>? specificWords;
  final LearningMode mode;

  const WordLearningScreen({
    super.key,
    required this.vocabularyBook,
    this.specificWords,
    this.mode = LearningMode.normal,
  });

  @override
  ConsumerState<WordLearningScreen> createState() => _WordLearningScreenState();
}

class _WordLearningScreenState extends ConsumerState<WordLearningScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _flipController;
  late AnimationController _progressController;
  late Animation<double> _flipAnimation;
  late Animation<double> _progressAnimation;

  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _showDefinition = false;
  List<Word> _words = [];
  Map<String, bool> _answers = {};
  LearningSession? _session;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _initializeWords();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flipController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _initializeWords() {
    _words = widget.specificWords ?? [];
    if (_words.isNotEmpty) {
      _progressController.animateTo(_currentIndex / _words.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(
          title: '单词学习',
        ),
        body: const Center(
          child: EmptyDataWidget(
            message: '暂无学习单词',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
          title: widget.vocabularyBook.name,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettings,
            ),
          ],
        ),
      body: Column(
        children: [
          _buildProgressBar(),
          _buildLearningModeIndicator(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _words.length,
              itemBuilder: (context, index) {
                return _buildWordCard(_words[index]);
              },
            ),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentIndex + 1} / ${_words.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${((_currentIndex + 1) / _words.length * 100).toInt()}%',
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
                value: _progressAnimation.value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLearningModeIndicator() {
    String modeText;
    Color modeColor;
    IconData modeIcon;

    switch (widget.mode) {
      case LearningMode.review:
        modeText = '复习模式';
        modeColor = Colors.orange;
        modeIcon = Icons.refresh;
        break;
      case LearningMode.test:
        modeText = '测试模式';
        modeColor = Colors.red;
        modeIcon = Icons.quiz;
        break;
      case LearningMode.normal:
      default:
        modeText = '学习模式';
        modeColor = Colors.blue;
        modeIcon = Icons.school;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: modeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: modeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(modeIcon, size: 16, color: modeColor),
          const SizedBox(width: 4),
          Text(
            modeText,
            style: TextStyle(
              color: modeColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(Word word) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
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
    );
  }

  Widget _buildWordFront(Word word) {
    return CustomCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 单词难度指示器
            _buildDifficultyIndicator(word.difficulty),
            const SizedBox(height: 24),
            
            // 主单词
            Text(
              word.word,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 音标
            if (word.phonetic != null) ...[
              const SizedBox(height: 8),
              Text(
                word.phonetic!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // 音频播放按钮
            if (word.audioUrl != null)
              ElevatedButton.icon(
                onPressed: () => _playAudio(word.audioUrl!),
                icon: const Icon(Icons.volume_up),
                label: const Text('播放发音'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // 提示文本
            Text(
              '点击卡片查看释义',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
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
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 单词和音标
              Center(
                child: Column(
                  children: [
                    Text(
                      word.word,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (word.phonetic != null)
                      Text(
                        word.phonetic!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 释义
              if (word.definitions.isNotEmpty) ...[
                Text(
                  '释义',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...word.definitions.map((definition) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${definition.type.name}: ${definition.definition}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (definition.translation != null)
                              Text(
                                definition.translation!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
              ],
              
              // 例句
              if (word.examples.isNotEmpty) ...[
                Text(
                  '例句',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...word.examples.take(2).map((example) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        example.sentence,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (example.translation != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          example.translation!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
                const SizedBox(height: 16),
              ],
              
              // 记忆技巧
              if (word.memoryTip != null) ...[
                Text(
                  '记忆技巧',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          word.memoryTip!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
              size: 16,
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

  Widget _buildBottomControls() {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // 翻转卡片按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _flipCard,
                icon: Icon(_isFlipped ? Icons.visibility_off : Icons.visibility),
                label: Text(_isFlipped ? '隐藏释义' : '查看释义'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 学习反馈按钮
            if (widget.mode != LearningMode.test)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _markWord(false),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('不认识'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markWord(true),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('认识'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            
            // 导航按钮
            if (widget.mode == LearningMode.test) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentIndex > 0 ? _previousWord : null,
                      child: const Text('上一个'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentIndex < _words.length - 1
                          ? _nextWord
                          : _finishLearning,
                      child: Text(
                        _currentIndex < _words.length - 1 ? '下一个' : '完成',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _isFlipped = false;
    });
    _flipController.reset();
    _progressController.animateTo((index + 1) / _words.length);
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _markWord(bool isKnown) {
    final word = _words[_currentIndex];
    _answers[word.id] = isKnown;
    
    // TODO: 更新单词学习进度
    // ref.read(vocabularyProvider.notifier).updateWordProgress(
    //   word.id,
    //   isKnown ? LearningStatus.reviewing : LearningStatus.learning,
    //   isKnown,
    //   DateTime.now().millisecondsSinceEpoch,
    // );
    
    _nextWord();
  }

  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishLearning();
    }
  }

  void _previousWord() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _playAudio(String audioUrl) {
    // TODO: 实现音频播放功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('音频播放功能开发中...')),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSettingsSheet(),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '学习设置',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.shuffle),
            title: const Text('随机顺序'),
            trailing: Switch(
              value: false, // TODO: 实现设置状态管理
              onChanged: (value) {
                // TODO: 实现随机顺序切换
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('自动播放发音'),
            trailing: Switch(
              value: false, // TODO: 实现设置状态管理
              onChanged: (value) {
                // TODO: 实现自动播放切换
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('显示计时器'),
            trailing: Switch(
              value: false, // TODO: 实现设置状态管理
              onChanged: (value) {
                // TODO: 实现计时器切换
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ),
        ],
      ),
    );
  }

  void _finishLearning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildFinishDialog(),
    );
  }

  Widget _buildFinishDialog() {
    final knownCount = _answers.values.where((known) => known).length;
    final unknownCount = _answers.values.where((known) => !known).length;
    final accuracy = _answers.isNotEmpty
        ? (knownCount / _answers.length * 100).toInt()
        : 0;

    return AlertDialog(
      title: const Text('学习完成'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.celebration,
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            '恭喜完成本次学习！',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '$knownCount',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('认识'),
                ],
              ),
              Column(
                children: [
                  Text(
                    '$unknownCount',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('不认识'),
                ],
              ),
              Column(
                children: [
                  Text(
                    '$accuracy%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('准确率'),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 关闭对话框
            Navigator.of(context).pop(); // 返回上一页
          },
          child: const Text('返回'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // 关闭对话框
            // TODO: 重新开始学习
            _restartLearning();
          },
          child: const Text('再学一遍'),
        ),
      ],
    );
  }

  void _restartLearning() {
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _answers.clear();
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _flipController.reset();
    _progressController.reset();
  }
}

/// 学习模式
enum LearningMode {
  normal,  // 普通学习
  review,  // 复习模式
  test,    // 测试模式
}

/// 学习会话
class LearningSession {
  final String id;
  final String vocabularyBookId;
  final List<String> wordIds;
  final LearningMode mode;
  final DateTime startTime;
  final Map<String, bool> answers;
  final Map<String, int> responseTimes;

  LearningSession({
    required this.id,
    required this.vocabularyBookId,
    required this.wordIds,
    required this.mode,
    required this.startTime,
    this.answers = const {},
    this.responseTimes = const {},
  });

  LearningSession copyWith({
    String? id,
    String? vocabularyBookId,
    List<String>? wordIds,
    LearningMode? mode,
    DateTime? startTime,
    Map<String, bool>? answers,
    Map<String, int>? responseTimes,
  }) {
    return LearningSession(
      id: id ?? this.id,
      vocabularyBookId: vocabularyBookId ?? this.vocabularyBookId,
      wordIds: wordIds ?? this.wordIds,
      mode: mode ?? this.mode,
      startTime: startTime ?? this.startTime,
      answers: answers ?? this.answers,
      responseTimes: responseTimes ?? this.responseTimes,
    );
  }
}