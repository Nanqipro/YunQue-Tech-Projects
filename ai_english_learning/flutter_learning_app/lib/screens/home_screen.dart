import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/word_card.dart';
import '../widgets/progress_indicator.dart';
import 'word_list_screen.dart';
import 'statistics_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认退出'),
          content: Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<AppProvider>(context, listen: false).logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '英语学习助手',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue.shade600,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              _buildLearningTab(appProvider),
              WordListScreen(),
              StatisticsScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue.shade600,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: '学习',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: '单词本',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: '统计',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLearningTab(AppProvider appProvider) {
    if (appProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (appProvider.words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暂无单词数据',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 用户信息和进度
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade600,
                Colors.blue.shade400,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '欢迎回来, ${appProvider.currentUser?.username ?? "学习者"}!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '积分: ${appProvider.currentUser?.score ?? 0}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 16),
              LearningProgressIndicator(),
            ],
          ),
        ),
        // 单词学习区域
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // 导航按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: appProvider.currentWordIndex > 0
                          ? appProvider.previousWord
                          : null,
                      icon: Icon(Icons.arrow_back_ios),
                      iconSize: 32,
                      color: Colors.blue.shade600,
                    ),
                    Text(
                      '${appProvider.currentWordIndex + 1} / ${appProvider.totalWordsCount}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    IconButton(
                      onPressed: appProvider.currentWordIndex < appProvider.totalWordsCount - 1
                          ? appProvider.nextWord
                          : null,
                      icon: Icon(Icons.arrow_forward_ios),
                      iconSize: 32,
                      color: Colors.blue.shade600,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // 单词卡片
                Expanded(
                  child: appProvider.currentWord != null
                      ? WordCard(word: appProvider.currentWord!)
                      : Center(
                          child: Text(
                            '没有更多单词了',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}