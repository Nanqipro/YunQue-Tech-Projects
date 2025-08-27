import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_provider.dart';
import '../models/reading_question.dart';
import '../widgets/reading_question_widget.dart';
import '../widgets/reading_progress_bar.dart';
import '../widgets/reading_result_dialog.dart';

/// 阅读练习页面
class ReadingExerciseScreen extends StatefulWidget {
  final String articleId;

  const ReadingExerciseScreen({
    super.key,
    required this.articleId,
  });

  @override
  State<ReadingExerciseScreen> createState() => _ReadingExerciseScreenState();
}

class _ReadingExerciseScreenState extends State<ReadingExerciseScreen> {
  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExercise();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadExercise() {
    final provider = context.read<ReadingProvider>();
    provider.loadExercise(widget.articleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '阅读练习',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<ReadingProvider>(
            builder: (context, provider, child) {
              final exercise = provider.currentExercise;
              if (exercise == null) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${_currentQuestionIndex + 1}/${exercise.questions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReadingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadExercise,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final exercise = provider.currentExercise;
          if (exercise == null) {
            return const Center(
              child: Text('练习不存在'),
            );
          }

          return Column(
            children: [
              // 进度条
              ReadingProgressBar(
                current: _currentQuestionIndex + 1,
                total: exercise.questions.length,
                progress: exercise.progressPercentage,
              ),
              
              // 问题内容
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentQuestionIndex = index;
                    });
                  },
                  itemCount: exercise.questions.length,
                  itemBuilder: (context, index) {
                    final question = exercise.questions[index];
                    return ReadingQuestionWidget(
                      question: question,
                      selectedAnswer: question.userAnswer,
                      onAnswerSelected: (answer) {
                        _updateAnswer(question, answer);
                      },
                      onNext: _nextQuestion,
                      onPrevious: _previousQuestion,
                      isFirst: index == 0,
                      isLast: index == exercise.questions.length - 1,
                    );
                  },
                ),
              ),
              
              // 底部导航
              _buildBottomNavigation(exercise),
            ],
          );
        },
      ),
    );
  }

  /// 构建底部导航
  Widget _buildBottomNavigation(ReadingExercise exercise) {
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex == exercise.questions.length - 1;
    final currentQuestion = exercise.questions[_currentQuestionIndex];
    final hasAnswer = currentQuestion.userAnswer != null && 
                     currentQuestion.userAnswer!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 上一题按钮
          if (!isFirstQuestion)
            OutlinedButton(
              onPressed: _previousQuestion,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
                side: const BorderSide(color: Color(0xFF2196F3)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('上一题'),
            ),
          
          const Spacer(),
          
          // 下一题/提交按钮
          ElevatedButton(
            onPressed: hasAnswer
                ? (isLastQuestion ? _submitExercise : _nextQuestion)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isLastQuestion ? '提交答案' : '下一题',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// 更新答案
  void _updateAnswer(ReadingQuestion question, String answer) {
    final provider = context.read<ReadingProvider>();
    provider.updateQuestionAnswer(question.id, answer);
  }

  /// 上一题
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 下一题
  void _nextQuestion() {
    final exercise = context.read<ReadingProvider>().currentExercise;
    if (exercise != null && _currentQuestionIndex < exercise.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 提交练习
  void _submitExercise() async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<ReadingProvider>();
      final exercise = provider.currentExercise;
      
      if (exercise == null) {
        throw Exception('练习数据不存在');
      }

      // 检查是否所有题目都已回答
      final unansweredQuestions = exercise.questions
          .where((q) => q.userAnswer == null || q.userAnswer!.isEmpty)
          .toList();

      if (unansweredQuestions.isNotEmpty) {
        _showUnansweredDialog(unansweredQuestions.length);
        return;
      }

      // 提交答案
      await provider.submitExercise();
      
      // 显示结果
      if (mounted) {
        _showResultDialog(exercise);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 显示未回答题目对话框
  void _showUnansweredDialog(int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text('还有 $count 道题目未回答，是否继续提交？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _forceSubmitExercise();
            },
            child: const Text('继续提交'),
          ),
        ],
      ),
    );
  }

  /// 强制提交练习
  void _forceSubmitExercise() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<ReadingProvider>();
      final exercise = provider.currentExercise!;
      
      await provider.submitExercise();
      
      if (mounted) {
        _showResultDialog(exercise);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 显示结果对话框
  void _showResultDialog(ReadingExercise exercise) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReadingResultDialog(
        exercise: exercise,
        onReview: () {
          Navigator.of(context).pop();
          _reviewAnswers();
        },
        onRetry: () {
          Navigator.of(context).pop();
          _retryExercise();
        },
        onFinish: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // 返回到文章页面
        },
      ),
    );
  }

  /// 查看答案解析
  void _reviewAnswers() {
    // 切换到查看模式，显示正确答案和解析
    setState(() {
      _currentQuestionIndex = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 重新练习
  void _retryExercise() {
    final provider = context.read<ReadingProvider>();
    provider.resetExercise();
    setState(() {
      _currentQuestionIndex = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}