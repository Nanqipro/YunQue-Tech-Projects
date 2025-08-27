import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_theme.dart';
import '../../models/word_model.dart';
import '../../widgets/word_book_card.dart';
import '../../widgets/daily_word_card.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  // 模拟词书数据
  final List<WordBookModel> wordBooks = [
    WordBookModel(
      id: '1',
      name: '托福核心词汇',
      description: '托福考试必备核心词汇',
      coverImage: '',
      totalWords: 1000,
      learnedWords: 650,
      category: 'toefl',
      difficulty: 'hard',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    WordBookModel(
      id: '2',
      name: '雅思词汇',
      description: '雅思考试高频词汇',
      coverImage: '',
      totalWords: 800,
      learnedWords: 320,
      category: 'ielts',
      difficulty: 'hard',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    WordBookModel(
      id: '3',
      name: '六级词汇',
      description: '大学英语六级词汇',
      coverImage: '',
      totalWords: 600,
      learnedWords: 450,
      category: 'cet6',
      difficulty: 'medium',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    WordBookModel(
      id: '4',
      name: '日常词汇',
      description: '日常生活常用词汇',
      coverImage: '',
      totalWords: 500,
      learnedWords: 200,
      category: 'daily',
      difficulty: 'easy',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('单词学习'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell),
            onPressed: () {},
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bars),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 选择词书开始学习
            _buildWordBooksSection(),
            const SizedBox(height: 24),
            
            // 今日单词
            _buildDailyWordsSection(),
            const SizedBox(height: 24),
            
            // AI 助手推荐
            _buildAIRecommendationSection(),
            const SizedBox(height: 24),
            
            // 学习统计
            _buildStatsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWordBooksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择词书开始学习',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: wordBooks.length,
          itemBuilder: (context, index) {
            return WordBookCard(
              wordBook: wordBooks[index],
              onTap: () {
                // TODO: 导航到单词学习页面
              },
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildDailyWordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日单词',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const DailyWordCard(
          word: 'Innovation',
          meaning: '创新，革新',
          pronunciation: '/ˌɪnəˈveɪʃn/',
        ),
        const SizedBox(height: 8),
        const DailyWordCard(
          word: 'Persistent',
          meaning: '坚持的，持续的',
          pronunciation: '/pərˈsɪstənt/',
        ),
        const SizedBox(height: 8),
        const DailyWordCard(
          word: 'Enthusiasm',
          meaning: '热情，热忱',
          pronunciation: '/ɪnˈθuːziæzəm/',
        ),
      ],
    );
  }
  
  Widget _buildAIRecommendationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration.copyWith(
        color: AppTheme.primaryColor.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.robot,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'AI 助手推荐',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '根据您的学习情况，建议您重点复习托福核心词汇中的高频词汇，并加强商务英语词汇的学习。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '学习统计',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('已学单词', '1250', FontAwesomeIcons.book),
              _buildStatItem('连续打卡', '15天', FontAwesomeIcons.fire),
              _buildStatItem('平均得分', '85分', FontAwesomeIcons.trophy),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        FaIcon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}