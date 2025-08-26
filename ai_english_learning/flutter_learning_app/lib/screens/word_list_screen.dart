import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/word.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  int _selectedDifficulty = 0; // 0: 全部, 1: 简单, 2: 中等, 3: 困难

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Word> _filterWords(List<Word> words) {
    List<Word> filtered = words;

    // 按难度筛选
    if (_selectedDifficulty > 0) {
      filtered = filtered.where((word) => word.difficulty == _selectedDifficulty).toList();
    }

    // 按搜索关键词筛选
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((word) {
        return word.english.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               word.chinese.contains(_searchQuery) ||
               word.pronunciation.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          body: Column(
            children: [
              // 搜索和筛选区域
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 搜索框
                    TextField(
                      decoration: InputDecoration(
                        hintText: '搜索单词...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    // 难度筛选
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildDifficultyChip('全部', 0),
                          SizedBox(width: 8),
                          _buildDifficultyChip('简单', 1),
                          SizedBox(width: 8),
                          _buildDifficultyChip('中等', 2),
                          SizedBox(width: 8),
                          _buildDifficultyChip('困难', 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 标签栏
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue.shade600,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue.shade600,
                  tabs: [
                    Tab(text: '全部单词'),
                    Tab(text: '已学会'),
                    Tab(text: '未学会'),
                  ],
                ),
              ),
              // 单词列表
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWordList(_filterWords(appProvider.words)),
                    _buildWordList(_filterWords(appProvider.getLearnedWords())),
                    _buildWordList(_filterWords(appProvider.getUnlearnedWords())),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDifficultyChip(String label, int difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    Color chipColor;
    
    switch (difficulty) {
      case 1:
        chipColor = Colors.green;
        break;
      case 2:
        chipColor = Colors.orange;
        break;
      case 3:
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.blue;
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDifficulty = selected ? difficulty : 0;
        });
      },
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : Colors.grey.shade600,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildWordList(List<Word> words) {
    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              '没有找到匹配的单词',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return _buildWordItem(word, index);
      },
    );
  }

  Widget _buildWordItem(Word word, int index) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // 跳转到该单词
              final wordIndex = appProvider.words.indexWhere((w) => w.id == word.id);
              if (wordIndex != -1) {
                appProvider.goToWord(wordIndex);
                DefaultTabController.of(context)?.animateTo(0); // 切换到学习页面
              }
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // 单词信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              word.english,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(width: 8),
                            _buildDifficultyBadge(word.difficulty),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          word.pronunciation,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          word.chinese,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          word.example,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // 学习状态和操作
                  Column(
                    children: [
                      if (word.isLearned)
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 20,
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.circle_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      SizedBox(height: 8),
                      IconButton(
                        onPressed: () {
                          if (word.isLearned) {
                            appProvider.markWordAsUnlearned(word.id!);
                          } else {
                            appProvider.markWordAsLearned(word.id!);
                          }
                        },
                        icon: Icon(
                          word.isLearned ? Icons.refresh : Icons.check,
                          color: word.isLearned ? Colors.orange : Colors.green,
                        ),
                        tooltip: word.isLearned ? '标记为未学会' : '标记为已学会',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultyBadge(int difficulty) {
    Color color;
    String text;
    
    switch (difficulty) {
      case 1:
        color = Colors.green;
        text = '简单';
        break;
      case 2:
        color = Colors.orange;
        text = '中等';
        break;
      case 3:
        color = Colors.red;
        text = '困难';
        break;
      default:
        color = Colors.grey;
        text = '未知';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}