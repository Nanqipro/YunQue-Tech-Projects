import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_theme.dart';
import '../models/word_model.dart';

class WordBookCard extends StatelessWidget {
  final WordBookModel wordBook;
  final VoidCallback? onTap;
  
  const WordBookCard({
    super.key,
    required this.wordBook,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片区域
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      _getCategoryIcon(),
                      size: 32,
                      color: _getCategoryColor(),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getDifficultyText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 内容区域
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wordBook.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${wordBook.totalWords} 词',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    
                    // 进度条
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '进度',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${(wordBook.progress * 100).toInt()}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: wordBook.progress,
                          backgroundColor: AppTheme.dividerColor,
                          valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor()),
                          minHeight: 3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor() {
    switch (wordBook.category) {
      case 'toefl':
        return const Color(0xFF2196F3);
      case 'ielts':
        return const Color(0xFF4CAF50);
      case 'cet6':
        return const Color(0xFFFF9800);
      case 'daily':
        return const Color(0xFF9C27B0);
      case 'business':
        return const Color(0xFFF44336);
      default:
        return AppTheme.primaryColor;
    }
  }
  
  IconData _getCategoryIcon() {
    switch (wordBook.category) {
      case 'toefl':
        return FontAwesomeIcons.graduationCap;
      case 'ielts':
        return FontAwesomeIcons.globe;
      case 'cet6':
        return FontAwesomeIcons.school;
      case 'daily':
        return FontAwesomeIcons.home;
      case 'business':
        return FontAwesomeIcons.briefcase;
      default:
        return FontAwesomeIcons.book;
    }
  }
  
  Color _getDifficultyColor() {
    switch (wordBook.difficulty) {
      case 'easy':
        return AppTheme.successColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'hard':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }
  
  String _getDifficultyText() {
    switch (wordBook.difficulty) {
      case 'easy':
        return '简单';
      case 'medium':
        return '中等';
      case 'hard':
        return '困难';
      default:
        return '中等';
    }
  }
}