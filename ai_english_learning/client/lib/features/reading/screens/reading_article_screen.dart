import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reading_provider.dart';
import '../models/reading_article.dart';
import '../widgets/reading_content_widget.dart';
import '../widgets/reading_toolbar.dart';
import 'reading_exercise_screen.dart';

/// 阅读文章详情页面
class ReadingArticleScreen extends StatefulWidget {
  final String articleId;

  const ReadingArticleScreen({
    super.key,
    required this.articleId,
  });

  @override
  State<ReadingArticleScreen> createState() => _ReadingArticleScreenState();
}

class _ReadingArticleScreenState extends State<ReadingArticleScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isReading = false;
  DateTime? _startTime;
  
  @override
  void initState() {
    super.initState();
    _loadArticle();
    _startReading();
  }

  @override
  void dispose() {
    _endReading();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadArticle() {
    final provider = context.read<ReadingProvider>();
    provider.loadArticle(widget.articleId);
  }

  void _startReading() {
    _startTime = DateTime.now();
    _isReading = true;
  }

  void _endReading() {
    if (_isReading && _startTime != null) {
      final duration = DateTime.now().difference(_startTime!);
      final provider = context.read<ReadingProvider>();
      provider.recordReadingProgress(
        articleId: widget.articleId,
        readingTime: duration.inSeconds,
        completed: true,
      );
      _isReading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '阅读文章',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<ReadingProvider>(
            builder: (context, provider, child) {
              final article = provider.currentArticle;
              if (article == null) return const SizedBox.shrink();
              
              return IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: provider.favoriteArticles.any((a) => a.id == article.id)
                      ? Colors.red
                      : Colors.white,
                ),
                onPressed: () => _toggleFavorite(article),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareArticle,
          ),
        ],
      ),
      body: Consumer<ReadingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
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
                    onPressed: _loadArticle,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final article = provider.currentArticle;
          if (article == null) {
            return const Center(
              child: Text('文章不存在'),
            );
          }

          return Column(
            children: [
              // 文章信息头部
              _buildArticleHeader(article),
              
              // 阅读工具栏
              const ReadingToolbar(),
              
              // 文章内容
              Expanded(
                child: ReadingContentWidget(
                  article: article,
                  scrollController: _scrollController,
                ),
              ),
              
              // 底部操作栏
              _buildBottomActions(article),
            ],
          );
        },
      ),
    );
  }

  /// 构建文章信息头部
  Widget _buildArticleHeader(ReadingArticle article) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          // 文章信息
          Row(
            children: [
              // 分类标签
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  article.categoryLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
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
                  article.difficultyLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getDifficultyColor(article.difficulty),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              
              // 字数和阅读时间
              Text(
                '${article.wordCount}词 · ${article.readingTime}分钟',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          // 来源和发布时间
          if (article.source != null || article.publishDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  if (article.source != null) ...[
                    Icon(
                      Icons.source,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article.source!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (article.source != null && article.publishDate != null)
                    Text(
                      ' · ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  if (article.publishDate != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(article.publishDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomActions(ReadingArticle article) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 开始练习按钮
          Expanded(
            child: ElevatedButton(
              onPressed: () => _startExercise(article),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '开始练习',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 重新阅读按钮
          OutlinedButton(
            onPressed: () => _scrollToTop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2196F3),
              side: const BorderSide(color: Color(0xFF2196F3)),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('重新阅读'),
          ),
        ],
      ),
    );
  }

  /// 获取难度颜色
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'a1':
      case 'a2':
        return Colors.green;
      case 'b1':
      case 'b2':
        return Colors.orange;
      case 'c1':
      case 'c2':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 切换收藏状态
  void _toggleFavorite(ReadingArticle article) {
    final provider = context.read<ReadingProvider>();
    final isFavorite = provider.favoriteArticles.any((a) => a.id == article.id);
    
    if (isFavorite) {
      provider.unfavoriteArticle(article.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已取消收藏')),
      );
    } else {
      provider.favoriteArticle(article.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已添加到收藏')),
      );
    }
  }

  /// 分享文章
  void _shareArticle() {
    final article = context.read<ReadingProvider>().currentArticle;
    if (article != null) {
      // TODO: 实现分享功能
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('分享功能开发中...')),
      );
    }
  }

  /// 开始练习
  void _startExercise(ReadingArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReadingExerciseScreen(articleId: article.id),
      ),
    );
  }

  /// 滚动到顶部
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}