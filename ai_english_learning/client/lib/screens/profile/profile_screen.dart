import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/learning_stats_model.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/daily_word_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 模拟数据
  final UserModel user = UserModel(
    id: '1',
    name: '小明',
    email: 'xiaoming@example.com',
    avatar: 'https://via.placeholder.com/100',
    motto: '每天进步一点点',
    socialLinks: ['weibo', 'wechat'],
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    lastLoginAt: DateTime.now(),
  );
  
  final LearningStatsModel stats = LearningStatsModel(
    learnedWords: 1250,
    consecutiveDays: 15,
    averageScore: 85.5,
    totalStudyTime: 1800,
    completedLessons: 45,
    lastStudyDate: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('个人主页'),
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
          children: [
            // 用户信息卡片
            _buildUserInfoCard(),
            const SizedBox(height: 16),
            
            // 学习统计
            _buildStatsSection(),
            const SizedBox(height: 16),
            
            // 学习进度
            _buildProgressSection(),
            const SizedBox(height: 16),
            
            // 今日单词
            _buildDailyWordsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          // 头像
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              user.name.isNotEmpty ? user.name[0] : 'U',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // 用户名
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          
          // 个性签名
          Text(
            user.motto,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // 社交媒体链接
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.weibo, color: AppTheme.primaryColor),
                onPressed: () {},
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.weixin, color: AppTheme.successColor),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '学习数据',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: '已学单词',
                value: stats.learnedWords.toString(),
                icon: FontAwesomeIcons.book,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: '连续打卡',
                value: '${stats.consecutiveDays}天',
                icon: FontAwesomeIcons.fire,
                color: AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: '平均得分',
                value: '${stats.averageScore.toInt()}分',
                icon: FontAwesomeIcons.trophy,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '学习进度',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const ProgressCard(
          title: '托福核心词汇',
          progress: 0.65,
          current: 650,
          total: 1000,
        ),
        const SizedBox(height: 8),
        const ProgressCard(
          title: '商务英语词汇',
          progress: 0.35,
          current: 175,
          total: 500,
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
      ],
    );
  }
}