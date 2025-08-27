import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reading_article.dart';
import '../providers/reading_provider.dart';
import '../widgets/reading_article_card.dart';
import '../widgets/reading_search_bar.dart';
import 'reading_article_screen.dart';

/// 阅读搜索页面
class ReadingSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const ReadingSearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  State<ReadingSearchScreen> createState() => _ReadingSearchScreenState();
}

class _ReadingSearchScreenState extends State<ReadingSearchScreen> {
  late TextEditingController _searchController;
  String _currentQuery = '';
  bool _isSearching = false;
  List<ReadingArticle> _searchResults = [];
  List<String> _searchHistory = [];
  String _selectedDifficulty = 'all';
  String _selectedCategory = 'all';
  String _sortBy = 'relevance';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _currentQuery = widget.initialQuery ?? '';
    
    if (_currentQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(_currentQuery);
      });
    }
    
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 加载搜索历史
  void _loadSearchHistory() {
    // TODO: 从本地存储加载搜索历史
    _searchHistory = [
      '四级阅读',
      '商务英语',
      '科技文章',
      '新闻报道',
    ];
  }

  /// 保存搜索历史
  void _saveSearchHistory(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.take(10).toList();
      }
    });
    
    // TODO: 保存到本地存储
  }

  /// 执行搜索
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _currentQuery = query;
    });
    
    _saveSearchHistory(query);
    
    try {
      final provider = Provider.of<ReadingProvider>(context, listen: false);
      await provider.searchArticles(query);
      
      setState(() {
        _searchResults = provider.articles;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('搜索失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  /// 清除搜索历史
  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
    // TODO: 清除本地存储
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('搜索文章'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索文章标题、内容或标签...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF2196F3),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _currentQuery = '';
                            _searchResults.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: _performSearch,
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 筛选条件
          _buildFilterSection(),
          
          // 搜索结果或历史
          Expanded(
            child: _currentQuery.isEmpty
                ? _buildSearchHistory()
                : _buildSearchResults(),
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
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      }),
                      _buildFilterChip('初级', 'beginner', _selectedDifficulty, (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      }),
                      _buildFilterChip('中级', 'intermediate', _selectedDifficulty, (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      }),
                      _buildFilterChip('高级', 'advanced', _selectedDifficulty, (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
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
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      }),
                      _buildFilterChip('新闻', 'news', _selectedCategory, (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      }),
                      _buildFilterChip('科技', 'technology', _selectedCategory, (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      }),
                      _buildFilterChip('商务', 'business', _selectedCategory, (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      }),
                      _buildFilterChip('文化', 'culture', _selectedCategory, (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 排序方式
          Row(
            children: [
              const Text(
                '排序：',
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
                      _buildFilterChip('相关度', 'relevance', _sortBy, (value) {
                        setState(() {
                          _sortBy = value;
                        });
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      }),
                      _buildFilterChip('最新', 'newest', _sortBy, (value) {
                        setState(() {
                          _sortBy = value;
                        });
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
                      }),
                      _buildFilterChip('热门', 'popular', _sortBy, (value) {
                        setState(() {
                          _sortBy = value;
                        });
                        if (_currentQuery.isNotEmpty) {
                          _performSearch(_currentQuery);
                        }
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

  /// 构建搜索历史
  Widget _buildSearchHistory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 热门搜索
          _buildHotSearches(),
          
          const SizedBox(height: 24),
          
          // 搜索历史
          if (_searchHistory.isNotEmpty) _buildHistorySection(),
        ],
      ),
    );
  }

  /// 构建热门搜索
  Widget _buildHotSearches() {
    final hotSearches = [
      '四级阅读',
      '六级阅读',
      '托福阅读',
      '雅思阅读',
      '商务英语',
      '日常对话',
      '科技文章',
      '新闻报道',
      '文化差异',
      '环境保护',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '热门搜索',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: hotSearches.map((search) {
            return GestureDetector(
              onTap: () {
                _searchController.text = search;
                _performSearch(search);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      search,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建历史搜索
  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '搜索历史',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _clearSearchHistory,
              child: Text(
                '清空',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        ..._searchHistory.map((history) {
          return ListTile(
            leading: Icon(
              Icons.history,
              color: Colors.grey[500],
              size: 20,
            ),
            title: Text(
              history,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.grey[500],
                size: 18,
              ),
              onPressed: () {
                setState(() {
                  _searchHistory.remove(history);
                });
              },
            ),
            onTap: () {
              _searchController.text = history;
              _performSearch(history);
            },
          );
        }).toList(),
      ],
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
            SizedBox(height: 16),
            Text(
              '搜索中...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '没有找到相关文章',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '试试其他关键词或调整筛选条件',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 结果统计
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                '找到 ${_searchResults.length} 篇相关文章',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '搜索"$_currentQuery"',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // 文章列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final article = _searchResults[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
              );
            },
          ),
        ),
      ],
    );
  }
}