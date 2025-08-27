import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_provider.dart';
import '../widgets/reading_category_tabs.dart';
import '../widgets/reading_article_card.dart';
import '../widgets/reading_stats_card.dart';
import '../widgets/reading_search_bar.dart';
import 'reading_article_screen.dart';
import 'reading_search_screen.dart';
import 'reading_favorites_screen.dart';
import 'reading_history_screen.dart';

/// 阅读模块主页面
class ReadingHomeScreen extends StatefulWidget {
  const ReadingHomeScreen({super.key});

  @override
  State<ReadingHomeScreen> createState() => _ReadingHomeScreenState();
}

class _ReadingHomeScreenState extends State<ReadingHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // 初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReadingProvider>();
      provider.loadArticles(refresh: true);
      provider.loadRecommendedArticles();
      provider.loadReadingStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 触发加载更多
      context.read<ReadingProvider>().loadArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '阅读理解',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReadingSearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计卡片
          Consumer<ReadingProvider>(
            builder: (context, provider, child) {
              if (provider.readingStats != null) {
                return ReadingStatsCard(stats: provider.readingStats!);
              }
              return const SizedBox.shrink();
            },
          ),
          
          // 标签页
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2196F3),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFF2196F3),
              tabs: const [
                Tab(text: '推荐阅读'),
                Tab(text: '分类阅读'),
                Tab(text: '我的收藏'),
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecommendedTab(),
                _buildCategoryTab(),
                _buildFavoriteTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 推荐阅读标签页
  Widget _buildRecommendedTab() {
    return Consumer<ReadingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.recommendedArticles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadRecommendedArticles(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (provider.recommendedArticles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无推荐文章',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadRecommendedArticles(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.recommendedArticles.length,
            itemBuilder: (context, index) {
              final article = provider.recommendedArticles[index];
              return ReadingArticleCard(
                article: article,
                onTap: () => _navigateToArticle(article.id),
              );
            },
          ),
        );
      },
    );
  }

  /// 分类阅读标签页
  Widget _buildCategoryTab() {
    return Column(
      children: [
        // 分类选择
        const ReadingCategoryTabs(),
        
        // 文章列表
        Expanded(
          child: Consumer<ReadingProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.articles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.loadArticles(refresh: true),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }

              if (provider.articles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无文章',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.loadArticles(refresh: true),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.articles.length + 
                      (provider.hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= provider.articles.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final article = provider.articles[index];
                    return ReadingArticleCard(
                      article: article,
                      onTap: () => _navigateToArticle(article.id),
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

  /// 我的收藏标签页
  Widget _buildFavoriteTab() {
    return Consumer<ReadingProvider>(
      builder: (context, provider, child) {
        // 首次加载收藏文章
        if (provider.favoriteArticles.isEmpty && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.loadFavoriteArticles();
          });
        }

        if (provider.isLoading && provider.favoriteArticles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadFavoriteArticles(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (provider.favoriteArticles.isEmpty) {
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
                  '暂无收藏文章',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  '去发现一些有趣的文章吧！',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadFavoriteArticles(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.favoriteArticles.length,
            itemBuilder: (context, index) {
              final article = provider.favoriteArticles[index];
              return ReadingArticleCard(
                article: article,
                onTap: () => _navigateToArticle(article.id),
              );
            },
          ),
        );
      },
    );
  }

  /// 显示搜索对话框
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => ReadingSearchBar(
        onSearch: (query) {
          Navigator.of(context).pop();
          context.read<ReadingProvider>().searchArticles(query, refresh: true);
        },
      ),
    );
  }

  /// 显示筛选对话框
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选条件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 分类筛选
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '文章分类'),
              value: context.read<ReadingProvider>().selectedCategory,
              items: const [
                DropdownMenuItem(value: null, child: Text('全部分类')),
                DropdownMenuItem(value: 'cet4', child: Text('四级阅读')),
                DropdownMenuItem(value: 'cet6', child: Text('六级阅读')),
                DropdownMenuItem(value: 'toefl', child: Text('托福阅读')),
                DropdownMenuItem(value: 'ielts', child: Text('雅思阅读')),
                DropdownMenuItem(value: 'daily', child: Text('日常阅读')),
              ],
              onChanged: (value) {
                context.read<ReadingProvider>().setFilter(category: value);
              },
            ),
            const SizedBox(height: 16),
            // 难度筛选
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '难度等级'),
              value: context.read<ReadingProvider>().selectedDifficulty,
              items: const [
                DropdownMenuItem(value: null, child: Text('全部难度')),
                DropdownMenuItem(value: 'a1', child: Text('A1 - 初级')),
                DropdownMenuItem(value: 'a2', child: Text('A2 - 初级')),
                DropdownMenuItem(value: 'b1', child: Text('B1 - 中级')),
                DropdownMenuItem(value: 'b2', child: Text('B2 - 中级')),
                DropdownMenuItem(value: 'c1', child: Text('C1 - 高级')),
                DropdownMenuItem(value: 'c2', child: Text('C2 - 高级')),
              ],
              onChanged: (value) {
                context.read<ReadingProvider>().setFilter(difficulty: value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ReadingProvider>().clearFilter();
              Navigator.of(context).pop();
            },
            child: const Text('清除'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 导航到文章详情页
  void _navigateToArticle(String articleId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReadingArticleScreen(articleId: articleId),
      ),
    );
  }
}