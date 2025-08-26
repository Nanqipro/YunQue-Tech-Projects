import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/progress_indicator.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final stats = appProvider.getStatistics();
        final user = appProvider.currentUser;
        
        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息卡片
                _buildUserInfoCard(user, appProvider),
                SizedBox(height: 20),
                
                // 学习进度概览
                Text(
                  '学习进度概览',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 16),
                
                // 总体进度
                ProgressCard(
                  title: '总体进度',
                  current: stats['learned']!,
                  total: stats['total']!,
                  color: Colors.blue,
                  icon: Icons.trending_up,
                ),
                SizedBox(height: 20),
                
                // 难度分布
                Text(
                  '难度分布',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildDifficultyCard(
                        '简单',
                        stats['easy']!,
                        appProvider.getWordsByDifficulty(1).where((w) => w.isLearned).length,
                        Colors.green,
                        Icons.sentiment_very_satisfied,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDifficultyCard(
                        '中等',
                        stats['medium']!,
                        appProvider.getWordsByDifficulty(2).where((w) => w.isLearned).length,
                        Colors.orange,
                        Icons.sentiment_neutral,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDifficultyCard(
                        '困难',
                        stats['hard']!,
                        appProvider.getWordsByDifficulty(3).where((w) => w.isLearned).length,
                        Colors.red,
                        Icons.sentiment_very_dissatisfied,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                // 学习成就
                Text(
                  '学习成就',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 16),
                
                _buildAchievementsSection(stats, appProvider),
                SizedBox(height: 20),
                
                // 详细统计
                Text(
                  '详细统计',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 16),
                
                _buildDetailedStats(stats),
                SizedBox(height: 20),
                
                // 操作按钮
                _buildActionButtons(context, appProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoCard(user, AppProvider appProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? '学习者',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildUserStat('等级', '${user?.level ?? 1}', Icons.star),
                  _buildUserStat('积分', '${user?.score ?? 0}', Icons.emoji_events),
                  _buildUserStat(
                    '完成率',
                    '${(appProvider.progressPercentage * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard(
    String title,
    int total,
    int learned,
    Color color,
    IconData icon,
  ) {
    final progress = total > 0 ? learned / total : 0.0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            CircularProgressWidget(
              progress: progress,
              label: '$learned/$total',
              color: color,
              size: 60,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(Map<String, int> stats, AppProvider appProvider) {
    List<Achievement> achievements = [
      Achievement(
        title: '初学者',
        description: '学会第一个单词',
        icon: Icons.school,
        isUnlocked: stats['learned']! >= 1,
        color: Colors.green,
      ),
      Achievement(
        title: '勤奋学习者',
        description: '学会10个单词',
        icon: Icons.book,
        isUnlocked: stats['learned']! >= 10,
        color: Colors.blue,
      ),
      Achievement(
        title: '词汇达人',
        description: '学会50个单词',
        icon: Icons.star,
        isUnlocked: stats['learned']! >= 50,
        color: Colors.purple,
      ),
      Achievement(
        title: '完美主义者',
        description: '学完所有单词',
        icon: Icons.emoji_events,
        isUnlocked: stats['learned']! == stats['total']! && stats['total']! > 0,
        color: Colors.orange,
      ),
    ];

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Container(
            width: 100,
            margin: EdgeInsets.only(right: 12),
            child: Card(
              elevation: achievement.isUnlocked ? 4 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      achievement.icon,
                      size: 32,
                      color: achievement.isUnlocked
                          ? achievement.color
                          : Colors.grey.shade400,
                    ),
                    SizedBox(height: 8),
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: achievement.isUnlocked
                            ? Colors.grey.shade800
                            : Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 8,
                        color: achievement.isUnlocked
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailedStats(Map<String, int> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('总单词数', stats['total']!, Icons.library_books),
            Divider(),
            _buildStatRow('已学会', stats['learned']!, Icons.check_circle, Colors.green),
            Divider(),
            _buildStatRow('未学会', stats['unlearned']!, Icons.circle_outlined, Colors.orange),
            Divider(),
            _buildStatRow('简单单词', stats['easy']!, Icons.sentiment_very_satisfied, Colors.green),
            Divider(),
            _buildStatRow('中等单词', stats['medium']!, Icons.sentiment_neutral, Colors.orange),
            Divider(),
            _buildStatRow('困难单词', stats['hard']!, Icons.sentiment_very_dissatisfied, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, IconData icon, [Color? color]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Colors.grey.shade600,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppProvider appProvider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('重置学习进度'),
                    content: Text('确定要重置所有学习进度吗？此操作不可撤销。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          appProvider.resetProgress();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('学习进度已重置'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                        child: Text('确定'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.refresh),
            label: Text('重置进度'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final Color color;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });
}