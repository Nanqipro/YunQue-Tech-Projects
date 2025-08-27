import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reading_article.dart';
import '../providers/reading_provider.dart';
import '../widgets/reading_article_card.dart';
import 'reading_article_screen.dart';
import 'reading_search_screen.dart';

/// 阅读收藏页面
class ReadingFavoritesScreen extends StatefulWidget {
  const ReadingFavoritesScreen({super.key});

  @override
  State<ReadingFavoritesScreen> createState() => _ReadingFavoritesScreenState();
}

class _ReadingFavoritesScreenState extends State<ReadingFavoritesScreen> {
  String _selectedDifficulty = 'all';
  String _selectedCategory = 'all';
  String _sortBy = 'newest';
  bool _isLoading = true;
  List<ReadingArticle> _filteredFavorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// 加载收藏文章
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ReadingProvider>(context, listen: false);
      await provider.loadFavoriteArticles();
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载收藏失败: $e'),
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
    List<ReadingArticle> favorites = List.from(provider.favoriteArticles);

    // 难度筛选
    if (_selectedDifficulty != 'all') {
      favorites = favorites.where((article) => 
        article.difficulty == _selectedDifficulty
      ).toList();
    }

    // 分类筛选
    if (_selectedCategory != 'all') {
      favorites = favorites.where((article) => 
        article.category == _selectedCategory
      ).toList();
    }

    // 排序
    switch (_sortBy) {
      case 'newest':
        favorites.sort((a, b) => b.publishDate.compareTo(a.publishDate));
        break;
      case 'oldest':
        favorites.sort((a, b) => a.publishDate.compareTo(b.publishDate));
        break;
      case 'difficulty':
        favorites.sort((a, b) {
          const difficultyOrder = {'beginner': 1, 'intermediate': 2, 'advanced': 3};
          return (difficultyOrder[a.difficulty] ?? 0)
              .compareTo(difficultyOrder[b.difficulty] ?? 0);
        });
        break;
      case 'wordCount':
        favorites.sort((a, b) => a.wordCount.compareTo(b.wordCount));
        break;
    }

    setState(() {
      _filteredFavorites = favorites;
    });
  }

  /// 取消收藏
  Future<void> _unfavoriteArticle(ReadingArticle article) async {
    try {
      final provider = Provider.of<ReadingProvider>(context, listen: false);
      await provider.favoriteArticle(article.id);
      _applyFilters();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已取消收藏'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('取消收藏失败: $e'),
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
        title: const Text('我的收藏'),
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
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
              _applyFilters();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Text('最新收藏'),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Text('最早收藏'),
              ),
              const PopupMenuItem(
                value: 'difficulty',
                child: Text('按难度'),
              ),
              const PopupMenuItem(
                value: 'wordCount',
                child: Text('按字数'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选条件
          _buildFilterSection(),
          
          // 收藏列表
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                    ),
                  )
                : _buildFavoritesList(),
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
          
          const SizedBox(height: 12),
          
          // 分类筛选
          Row(
            children: [
              const Text(
                '分类：',
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
                      _buildFilterChip('全部', 'all', _selectedCategory, (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _applyFilters();
                      }),
                      _buildFilterChip('新闻', 'news', _selectedCategory, (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _applyFilters();
                      }),
                      _buildFilterChip('科技', 'technology', _selectedCategory, (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _applyFilters();
                      }),
                      _buildFilterChip('商务', 'business', _selectedCategory, (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _applyFilters();
                      }),
                      _buildFilterChip('文化', 'culture', _selectedCategory, (value) {
                        setState(() {
                          _selectedCategory = value;
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

  /// 构建收藏列表
  Widget _buildFavoritesList() {
    if (_filteredFavorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedDifficulty == 'all' && _selectedCategory == 'all'
                  ? '还没有收藏任何文章'
                  : '没有符合条件的收藏文章',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedDifficulty == 'all' && _selectedCategory == 'all'
                  ? '去发现一些有趣的文章吧'
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
                '共 ${_filteredFavorites.length} 篇收藏',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (_selectedDifficulty != 'all' || _selectedCategory != 'all')
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDifficulty = 'all';
                      _selectedCategory = 'all';
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
            itemCount: _filteredFavorites.length,
            itemBuilder: (context, index) {
              final article = _filteredFavorites[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key('favorite_${article.id}'),
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
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '取消收藏',
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
                        title: const Text('确认取消收藏'),
                        content: Text('确定要取消收藏「${article.title}」吗？'),
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
                    _unfavoriteArticle(article);
                  },
                  child: ReadingArticleCard(
                    article: article,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReadingArticleScreen(
                            articleId: article.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}