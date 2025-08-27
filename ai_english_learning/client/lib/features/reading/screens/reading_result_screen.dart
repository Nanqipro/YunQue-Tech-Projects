import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reading_question.dart';
import '../providers/reading_provider.dart';
import '../widgets/reading_article_card.dart';

/// 阅读练习结果页面
class ReadingResultScreen extends StatefulWidget {
  final ReadingExercise exercise;
  final String articleTitle;

  const ReadingResultScreen({
    super.key,
    required this.exercise,
    required this.articleTitle,
  });

  @override
  State<ReadingResultScreen> createState() => _ReadingResultScreenState();
}

class _ReadingResultScreenState extends State<ReadingResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('练习结果'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 结果概览卡片
                _buildResultOverviewCard(),
                
                const SizedBox(height: 16),
                
                // 详细分析
                _buildDetailedAnalysis(),
                
                const SizedBox(height: 16),
                
                // 问题详情
                _buildQuestionDetails(),
                
                const SizedBox(height: 16),
                
                // 推荐文章
                _buildRecommendedArticles(),
                
                const SizedBox(height: 80), // 为底部按钮留空间
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  /// 构建结果概览卡片
  Widget _buildResultOverviewCard() {
    final score = widget.exercise.score ?? 0.0;
    final totalQuestions = widget.exercise.totalQuestions;
    final correctAnswers = widget.exercise.correctAnswers;
    final percentage = (score * 100).round();
    
    Color scoreColor;
    String scoreText;
    IconData scoreIcon;
    
    if (percentage >= 90) {
      scoreColor = Colors.green;
      scoreText = '优秀';
      scoreIcon = Icons.emoji_events;
    } else if (percentage >= 80) {
      scoreColor = Colors.blue;
      scoreText = '良好';
      scoreIcon = Icons.thumb_up;
    } else if (percentage >= 70) {
      scoreColor = Colors.orange;
      scoreText = '一般';
      scoreIcon = Icons.trending_up;
    } else {
      scoreColor = Colors.red;
      scoreText = '需要努力';
      scoreIcon = Icons.refresh;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scoreColor.withOpacity(0.1),
              scoreColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            // 分数圆环
            Container(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  // 背景圆环
                  Container(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey[200]!,
                      ),
                    ),
                  ),
                  // 进度圆环
                  Container(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: score,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  // 中心内容
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          scoreIcon,
                          color: scoreColor,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 评价文本
            Text(
              scoreText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 详细信息
            Text(
              '答对 $correctAnswers / $totalQuestions 题',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              '用时 ${_formatDuration(widget.exercise.duration)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建详细分析
  Widget _buildDetailedAnalysis() {
    final questions = widget.exercise.questions;
    final multipleChoice = questions.where((q) => q.type == QuestionType.multipleChoice).length;
    final trueFalse = questions.where((q) => q.type == QuestionType.trueFalse).length;
    final fillBlank = questions.where((q) => q.type == QuestionType.fillInBlank).length;
    final shortAnswer = questions.where((q) => q.type == QuestionType.shortAnswer).length;
    
    final multipleChoiceCorrect = questions
        .where((q) => q.type == QuestionType.multipleChoice && q.isCorrect == true)
        .length;
    final trueFalseCorrect = questions
        .where((q) => q.type == QuestionType.trueFalse && q.isCorrect == true)
        .length;
    final fillBlankCorrect = questions
        .where((q) => q.type == QuestionType.fillInBlank && q.isCorrect == true)
        .length;
    final shortAnswerCorrect = questions
        .where((q) => q.type == QuestionType.shortAnswer && q.isCorrect == true)
        .length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '题型分析',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            if (multipleChoice > 0)
              _buildQuestionTypeRow(
                '选择题',
                multipleChoiceCorrect,
                multipleChoice,
                Icons.radio_button_checked,
              ),
            
            if (trueFalse > 0)
              _buildQuestionTypeRow(
                '判断题',
                trueFalseCorrect,
                trueFalse,
                Icons.check_circle,
              ),
            
            if (fillBlank > 0)
              _buildQuestionTypeRow(
                '填空题',
                fillBlankCorrect,
                fillBlank,
                Icons.edit,
              ),
            
            if (shortAnswer > 0)
              _buildQuestionTypeRow(
                '简答题',
                shortAnswerCorrect,
                shortAnswer,
                Icons.description,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建题型统计行
  Widget _buildQuestionTypeRow(
    String type,
    int correct,
    int total,
    IconData icon,
  ) {
    final percentage = total > 0 ? (correct / total * 100).round() : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            type,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            '$correct/$total',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: percentage >= 80 ? Colors.green : 
                     percentage >= 60 ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建问题详情
  Widget _buildQuestionDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '题目详情',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _showQuestionDetailsDialog();
                  },
                  child: const Text('查看解析'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            ...widget.exercise.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              
              return _buildQuestionSummaryItem(index + 1, question);
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// 构建问题摘要项
  Widget _buildQuestionSummaryItem(int number, ReadingQuestion question) {
    final isCorrect = question.isCorrect == true;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // 题号
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 问题信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getQuestionTypeText(question.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 结果图标
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// 获取问题类型文本
  String _getQuestionTypeText(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return '选择题';
      case QuestionType.trueFalse:
        return '判断题';
      case QuestionType.fillInBlank:
        return '填空题';
      case QuestionType.shortAnswer:
        return '简答题';
    }
  }

  /// 构建推荐文章
  Widget _buildRecommendedArticles() {
    return Consumer<ReadingProvider>(
      builder: (context, provider, child) {
        final recommendations = provider.recommendedArticles;
        
        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '推荐阅读',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                ...recommendations.take(3).map((article) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ReadingArticleCard(
                      article: article,
                      onTap: () {
                        Navigator.of(context).pop();
                        // 导航到文章详情页
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建底部操作按钮
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // 重新练习
                Navigator.of(context).pop();
                // 重新开始练习逻辑
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
                side: const BorderSide(color: Color(0xFF2196F3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('重新练习'),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('完成'),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示问题详情对话框
  void _showQuestionDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      '题目解析',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 内容
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.exercise.questions.length,
                  itemBuilder: (context, index) {
                    final question = widget.exercise.questions[index];
                    return _buildQuestionDetailItem(index + 1, question);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建问题详情项
  Widget _buildQuestionDetailItem(int number, ReadingQuestion question) {
    final isCorrect = question.isCorrect == true;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 题号和类型
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '第$number题',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getQuestionTypeText(question.type),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 问题
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 选项（如果有）
          if (question.options.isNotEmpty) ...
            question.options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final optionLetter = String.fromCharCode(65 + optionIndex);
              final isUserAnswer = question.userAnswer == optionLetter;
              final isCorrectAnswer = question.correctAnswer == optionLetter;
              
              Color? backgroundColor;
              Color? textColor;
              
              if (isCorrectAnswer) {
                backgroundColor = Colors.green.withOpacity(0.1);
                textColor = Colors.green[700];
              } else if (isUserAnswer && !isCorrectAnswer) {
                backgroundColor = Colors.red.withOpacity(0.1);
                textColor = Colors.red[700];
              }
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      '$optionLetter. ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor ?? Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor ?? Colors.black87,
                        ),
                      ),
                    ),
                    if (isCorrectAnswer)
                      const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 16,
                      ),
                    if (isUserAnswer && !isCorrectAnswer)
                      const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                  ],
                ),
              );
            }).toList(),
          
          // 用户答案和正确答案
          if (question.type != QuestionType.multipleChoice) ...[
            const SizedBox(height: 8),
            if (question.userAnswer?.isNotEmpty == true)
              Text(
                '你的答案：${question.userAnswer}',
                style: TextStyle(
                  fontSize: 14,
                  color: isCorrect ? Colors.green[700] : Colors.red[700],
                ),
              ),
            Text(
              '正确答案：${question.correctAnswer}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          // 解析
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '解析',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.explanation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 格式化持续时间
  String _formatDuration(Duration? duration) {
    if (duration == null) return '未知';
    
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}分${seconds}秒';
    } else {
      return '${seconds}秒';
    }
  }
}