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

/// 词汇量测试页面
class VocabularyTestScreen extends ConsumerStatefulWidget {
  final VocabularyBook? vocabularyBook;
  final TestType testType;
  final int questionCount;

  const VocabularyTestScreen({
    super.key,
    this.vocabularyBook,
    this.testType = TestType.vocabularyLevel,
    this.questionCount = 20,
  });

  @override
  ConsumerState<VocabularyTestScreen> createState() => _VocabularyTestScreenState();
}

class _VocabularyTestScreenState extends ConsumerState<VocabularyTestScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _questionController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentQuestionIndex = 0;
  List<TestQuestion> _questions = [];
  Map<int, int> _answers = {};
  bool _isLoading = true;
  String? _error;
  DateTime? _startTime;
  bool _isTestCompleted = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _questionController,
      curve: Curves.easeInOut,
    ));

    _initializeTest();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _initializeTest() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // TODO: 从服务获取测试题目
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求
      _questions = _generateTestQuestions();
      
      setState(() {
        _isLoading = false;
        _startTime = DateTime.now();
      });
      
      _questionController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<TestQuestion> _generateTestQuestions() {
    // TODO: 实际实现应该从服务器获取题目
    final random = Random();
    final questions = <TestQuestion>[];
    
    for (int i = 0; i < widget.questionCount; i++) {
      final questionType = TestQuestionType.values[random.nextInt(TestQuestionType.values.length)];
      questions.add(_createMockQuestion(i + 1, questionType));
    }
    
    return questions;
  }

  TestQuestion _createMockQuestion(int id, TestQuestionType type) {
    final random = Random();
    final mockWords = [
      'apple', 'banana', 'computer', 'elephant', 'fantastic',
      'guitar', 'happiness', 'internet', 'journey', 'knowledge'
    ];
    
    final word = mockWords[random.nextInt(mockWords.length)];
    final correctAnswer = random.nextInt(4);
    
    List<String> options;
    String question;
    
    switch (type) {
      case TestQuestionType.meaningChoice:
        question = '"$word" 的意思是？';
        options = ['选项A', '选项B', '选项C', '选项D'];
        break;
      case TestQuestionType.wordChoice:
        question = '下列哪个单词的意思是"苹果"？';
        options = [word, 'orange', 'grape', 'pear'];
        break;
      case TestQuestionType.sentenceCompletion:
        question = '请选择正确的单词完成句子：I like to eat ___.';
        options = [word, 'book', 'car', 'house'];
        break;
      case TestQuestionType.synonym:
        question = '"$word" 的同义词是？';
        options = ['同义词A', '同义词B', '同义词C', '同义词D'];
        break;
    }
    
    return TestQuestion(
      id: id,
      type: type,
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      difficulty: WordDifficulty.values[random.nextInt(WordDifficulty.values.length)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getTestTitle(),
        actions: [
          if (!_isTestCompleted)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _showExitDialog,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  String _getTestTitle() {
    switch (widget.testType) {
      case TestType.vocabularyLevel:
        return '词汇量测试';
      case TestType.bookTest:
        return '${widget.vocabularyBook?.name ?? ''} 测试';
      case TestType.dailyTest:
        return '每日测试';
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(
          message: '正在准备测试题目...',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: ErrorDisplayWidget(
          message: _error!,
          onRetry: _initializeTest,
        ),
      );
    }

    if (_isTestCompleted) {
      return _buildResultPage();
    }

    return Column(
      children: [
        _buildProgressSection(),
        Expanded(
          child: _buildQuestionSection(),
        ),
        _buildAnswerSection(),
      ],
    );
  }

  Widget _buildProgressSection() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '题目 ${_currentQuestionIndex + 1}/${_questions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_startTime != null)
                Text(
                  _formatTime(DateTime.now().difference(_startTime!)),
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
        ],
      ),
    );
  }

  Widget _buildQuestionSection() {
    if (_questions.isEmpty) return const SizedBox();
    
    final question = _questions[_currentQuestionIndex];
    
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 题目类型指示器
                _buildQuestionTypeIndicator(question.type),
                const SizedBox(height: 16),
                
                // 难度指示器
                _buildDifficultyIndicator(question.difficulty),
                const SizedBox(height: 24),
                
                // 题目内容
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // 题目图片（如果有）
                if (question.imageUrl != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(question.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTypeIndicator(TestQuestionType type) {
    String text;
    IconData icon;
    Color color;
    
    switch (type) {
      case TestQuestionType.meaningChoice:
        text = '选择释义';
        icon = Icons.translate;
        color = Colors.blue;
        break;
      case TestQuestionType.wordChoice:
        text = '选择单词';
        icon = Icons.spellcheck;
        color = Colors.green;
        break;
      case TestQuestionType.sentenceCompletion:
        text = '完成句子';
        icon = Icons.edit;
        color = Colors.orange;
        break;
      case TestQuestionType.synonym:
        text = '同义词';
        icon = Icons.compare_arrows;
        color = Colors.purple;
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
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
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

  Widget _buildAnswerSection() {
    if (_questions.isEmpty) return const SizedBox();
    
    final question = _questions[_currentQuestionIndex];
    final selectedAnswer = _answers[_currentQuestionIndex];
    
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
            // 选项列表
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedAnswer == index;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _selectAnswer(index),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      backgroundColor: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400]!,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${String.fromCharCode(65 + index)}. $option',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : null,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 16),
            
            // 导航按钮
            Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      child: const Text('上一题'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedAnswer != null
                        ? (_currentQuestionIndex < _questions.length - 1
                            ? _nextQuestion
                            : _finishTest)
                        : null,
                    child: Text(
                      _currentQuestionIndex < _questions.length - 1
                          ? '下一题'
                          : '完成测试',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPage() {
    final correctAnswers = _calculateCorrectAnswers();
    final accuracy = (correctAnswers / _questions.length * 100).round();
    final totalTime = _startTime != null
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 结果卡片
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
                    '测试完成！',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 统计信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '正确率',
                        '$accuracy%',
                        Icons.check_circle,
                        _getAccuracyColor(accuracy),
                      ),
                      _buildStatItem(
                        '正确题数',
                        '$correctAnswers/${_questions.length}',
                        Icons.quiz,
                        Theme.of(context).primaryColor,
                      ),
                      _buildStatItem(
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
          
          // 词汇量评估（仅限词汇量测试）
          if (widget.testType == TestType.vocabularyLevel)
            _buildVocabularyLevelCard(accuracy),
          
          const SizedBox(height: 16),
          
          // 错题回顾
          _buildWrongAnswersCard(),
          
          const SizedBox(height: 24),
          
          // 操作按钮
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _retakeTest,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新测试'),
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
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

  Widget _buildVocabularyLevelCard(int accuracy) {
    String level;
    String description;
    Color color;
    
    if (accuracy >= 90) {
      level = '专家级';
      description = '您的词汇量非常丰富，已达到专家水平！';
      color = Colors.purple;
    } else if (accuracy >= 80) {
      level = '高级';
      description = '您的词汇量很不错，已达到高级水平。';
      color = Colors.red;
    } else if (accuracy >= 70) {
      level = '中级';
      description = '您的词汇量处于中级水平，继续加油！';
      color = Colors.orange;
    } else if (accuracy >= 60) {
      level = '基础';
      description = '您的词汇量处于基础水平，需要继续学习。';
      color = Colors.lightGreen;
    } else {
      level = '初级';
      description = '建议从基础词汇开始学习，循序渐进。';
      color = Colors.green;
    }
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: color),
                const SizedBox(width: 8),
                Text(
                  '词汇量评估',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                level,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWrongAnswersCard() {
    final wrongAnswers = _getWrongAnswers();
    
    if (wrongAnswers.isEmpty) {
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
                '完美答题！',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '恭喜您全部答对！',
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
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  '错题回顾 (${wrongAnswers.length}题)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...wrongAnswers.take(3).map((question) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '题目 ${question.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '正确答案: ${String.fromCharCode(65 + question.correctAnswer)}. ${question.options[question.correctAnswer]}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
            if (wrongAnswers.length > 3)
              Text(
                '还有 ${wrongAnswers.length - 3} 道错题...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _questionController.reset();
      _questionController.forward();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _questionController.reset();
      _questionController.forward();
    }
  }

  void _finishTest() {
    setState(() {
      _isTestCompleted = true;
    });
  }

  void _retakeTest() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
      _isTestCompleted = false;
      _startTime = DateTime.now();
    });
    _questionController.reset();
    _questionController.forward();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出测试'),
        content: const Text('确定要退出当前测试吗？测试进度将不会保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
              Navigator.of(context).pop(); // 退出测试页面
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  int _calculateCorrectAnswers() {
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctAnswer) {
        correct++;
      }
    }
    return correct;
  }

  List<TestQuestion> _getWrongAnswers() {
    final wrongAnswers = <TestQuestion>[];
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] != _questions[i].correctAnswer) {
        wrongAnswers.add(_questions[i]);
      }
    }
    return wrongAnswers;
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

/// 测试类型
enum TestType {
  vocabularyLevel, // 词汇量测试
  bookTest,        // 词汇书测试
  dailyTest,       // 每日测试
}

/// 测试题目类型
enum TestQuestionType {
  meaningChoice,      // 选择释义
  wordChoice,         // 选择单词
  sentenceCompletion, // 完成句子
  synonym,            // 同义词
}

/// 测试题目
class TestQuestion {
  final int id;
  final TestQuestionType type;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final WordDifficulty difficulty;
  final String? imageUrl;
  final String? audioUrl;

  TestQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
    this.imageUrl,
    this.audioUrl,
  });
}