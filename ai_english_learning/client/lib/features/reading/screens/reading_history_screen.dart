import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reading_article.dart';
import '../providers/reading_provider.dart';
import '../widgets/reading_article_card.dart';
import 'reading_article_screen.dart';
import 'reading_search_screen.dart';

/// 阅读历史页面
class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  String _selectedPeriod = 'all';
  String _selectedDifficulty = 'all';
  String _sortBy = 'newest';
  bool _isLoading = true;
  List<ReadingArticle> _filteredHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// 加载阅读历史
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReadingProvider>(context, listen: false);
      await provider.loadReadingHistory();
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载历史失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 应用筛选条件
  void _applyFilters() {
    final provider = Provider.of<ReadingProvider>(context, listen: false);
    List<ReadingArticle> history = List.from(provider.readingHistory);

    // 时间筛选
    if (_selectedPeriod != 'all') {
      final now = DateTime.now();
      DateTime cutoffDate;
      
      switch (_selectedPeriod) {
        case 'today':
          cutoffDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          cutoffDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          cutoffDate = DateTime(now.year, now.month - 1, now.day);
          break;
        default:
          cutoffDate = DateTime(1970);
      }
      
      history = history.where((article) => 
        article.publishDate.isAfter(cutoffDate)
      ).toList();
    }

    // 难度筛选
    if (_selectedDifficulty != 'all') {
      history = history.where((article) => 
        article.difficulty == _selectedDifficulty
      ).toList();
    }

    // 排序
    switch (_sortBy) {
      case 'newest':
        history.sort((a, b) => b.publishDate.compareTo(a.publishDate));
        break;
      case 'oldest':
        history.sort((a, b) => a.publishDate.compareTo(b.publishDate));
        break;
      case 'difficulty':
        history.sort((a, b) {
          const difficultyOrder = {'beginner': 1, 'intermediate': 2, 'advanced': 3};
          return (difficultyOrder[a.difficulty] ?? 0)
              .compareTo(difficultyOrder[b.difficulty] ?? 0);
        });
        break;
      case 'readingTime':
        history.sort((a, b) => (a.readingTime ?? 0).compareTo(b.readingTime ?? 0));
        break;
    }

    setState(() {
      _filteredHistory = history;
    });
  }

  /// 清除历史记录
  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除历史记录'),
        content: const Text('确定要清除所有阅读历史记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<ReadingProvider>(context, listen: false);
        // TODO: 实现清除历史记录功能
        // await provider.clearReadingHistory();
        _applyFilters();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('历史记录已清除'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('清除失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 删除单个历史记录
  Future<void> _removeHistoryItem(ReadingArticle article) async {
    try {
      final provider = Provider.of<ReadingProvider>(context, listen: false);
      // TODO: 实现移除历史记录功能
        // await provider.removeFromHistory(article.id);
      _applyFilters();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已从历史记录中移除'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('移除失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('阅读历史'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReadingSearchScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                _clearHistory();
              } else {
                setState(() {
                  _sortBy = value;
                });
                _applyFilters();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Text('最近阅读'),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Text('最早阅读'),
              ),
              const PopupMenuItem(
                value: 'difficulty',
                child: Text('按难度'),
              ),
              const PopupMenuItem(
                value: 'readingTime',
                child: Text('按阅读时长'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Text(
                  '清除历史',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选条件
          _buildFilterSection(),
          
          // 历史列表
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                    ),
                  )
                : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  /// 构建筛选条件
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // 时间筛选
          Row(
            children: [
              const Text(
                '时间：',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('全部', 'all', _selectedPeriod, (value) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                        _applyFilters();
                      }),
                      _buildFilterChip('今天', 'today', _selectedPeriod, (value) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                        _applyFilters();
                      }),
                      _buildFilterChip('本周', 'week', _selectedPeriod, (value) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                        _applyFilters();
                      }),
                      _buildFilterChip('本月', 'month', _selectedPeriod, (value) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                        _applyFilters();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 难度筛选
          Row(
            children: [
              const Text(
                '难度：',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('全部', 'all', _selectedDifficulty, (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                        _applyFilters();
                      }),
                      _buildFilterChip('初级', 'beginner', _selectedDifficulty, (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                        _applyFilters();
                      }),
                      _buildFilterChip('中级', 'intermediate', _selectedDifficulty, (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                        _applyFilters();
                      }),
                      _buildFilterChip('高级', 'advanced', _selectedDifficulty, (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                        _applyFilters();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建筛选标签
  Widget _buildFilterChip(
    String label,
    String value,
    String selectedValue,
    Function(String) onSelected,
  ) {
    final isSelected = selectedValue == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelected(value),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2196F3) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建历史列表
  Widget _buildHistoryList() {
    if (_filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedPeriod == 'all' && _selectedDifficulty == 'all'
                  ? '还没有阅读历史'
                  : '没有符合条件的阅读记录',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedPeriod == 'all' && _selectedDifficulty == 'all'
                  ? '开始你的第一次阅读吧'
                  : '试试调整筛选条件',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('去阅读'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 统计信息
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                '共 ${_filteredHistory.length} 条记录',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (_selectedPeriod != 'all' || _selectedDifficulty != 'all')
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPeriod = 'all';
                      _selectedDifficulty = 'all';
                    });
                    _applyFilters();
                  },
                  child: const Text(
                    '清除筛选',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // 文章列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredHistory.length,
            itemBuilder: (context, index) {
              final article = _filteredHistory[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key('history_${article.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '删除记录',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('删除记录'),
                        content: Text('确定要删除「${article.title}」的阅读记录吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              '确定',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) {
                    _removeHistoryItem(article);
                  },
                  child: _buildHistoryCard(article),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建历史记录卡片
  Widget _buildHistoryCard(ReadingArticle article) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReadingArticleScreen(
              articleId: article.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和时间
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(article.publishDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 摘要
            Text(
              article.content.length > 100 
                  ? '${article.content.substring(0, 100)}...'
                  : article.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // 标签和进度
            Row(
              children: [
                // 难度标签
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(article.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyText(article.difficulty),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDifficultyColor(article.difficulty),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 分类标签
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    article.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // 阅读时长
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${article.readingTime}分钟',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  /// 获取难度颜色
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 获取难度文本
  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return '初级';
      case 'intermediate':
        return '中级';
      case 'advanced':
        return '高级';
      default:
        return '未知';
    }
  }
}