import 'package:flutter/foundation.dart';
import '../models/reading_article.dart';
import '../models/reading_question.dart';
import '../models/reading_stats.dart';
import '../services/reading_service.dart';

/// 阅读模块状态管理
class ReadingProvider extends ChangeNotifier {
  final ReadingService _readingService = ReadingService();

  // 文章列表
  List<ReadingArticle> _articles = [];
  List<ReadingArticle> get articles => _articles;

  // 当前文章
  ReadingArticle? _currentArticle;
  ReadingArticle? get currentArticle => _currentArticle;

  // 当前练习
  ReadingExercise? _currentExercise;
  ReadingExercise? get currentExercise => _currentExercise;

  // 阅读统计
  ReadingStats? _readingStats;
  ReadingStats? get readingStats => _readingStats;

  // 推荐文章
  List<ReadingArticle> _recommendedArticles = [];
  List<ReadingArticle> get recommendedArticles => _recommendedArticles;

  // 收藏文章
  List<ReadingArticle> _favoriteArticles = [];
  List<ReadingArticle> get favoriteArticles => _favoriteArticles;

  // 阅读历史
  List<ReadingArticle> _readingHistory = [];
  List<ReadingArticle> get readingHistory => _readingHistory;

  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 错误信息
  String? _error;
  String? get error => _error;

  // 筛选条件
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  String? _selectedDifficulty;
  String? get selectedDifficulty => _selectedDifficulty;

  // 搜索关键词
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // 分页
  int _currentPage = 1;
  int get currentPage => _currentPage;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// 获取文章列表
  Future<void> loadArticles({
    bool refresh = false,
    String? category,
    String? difficulty,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _articles.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      final articles = await _readingService.getArticles(
        category: category ?? _selectedCategory,
        difficulty: difficulty ?? _selectedDifficulty,
        page: _currentPage,
        limit: 20,
      );

      if (articles.isEmpty) {
        _hasMoreData = false;
      } else {
        if (refresh) {
          _articles = articles;
        } else {
          _articles.addAll(articles);
        }
        _currentPage++;
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 搜索文章
  Future<void> searchArticles(String query, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _articles.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    _searchQuery = query;
    _setLoading(true);
    _setError(null);

    try {
      final articles = await _readingService.searchArticles(
        query: query,
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        page: _currentPage,
        limit: 20,
      );

      if (articles.isEmpty) {
        _hasMoreData = false;
      } else {
        if (refresh) {
          _articles = articles;
        } else {
          _articles.addAll(articles);
        }
        _currentPage++;
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 获取文章详情
  Future<void> loadArticle(String articleId) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentArticle = await _readingService.getArticle(articleId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 获取文章练习
  Future<void> loadArticleExercise(String articleId) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentExercise = await _readingService.getArticleExercise(articleId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 提交练习答案
  Future<bool> submitExercise() async {
    if (_currentExercise == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      _currentExercise = await _readingService.submitExercise(_currentExercise!);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 记录阅读进度
  Future<void> recordReadingProgress({
    required String articleId,
    required int readingTime,
    required bool completed,
    double? comprehensionScore,
  }) async {
    try {
      await _readingService.recordReadingProgress(
        articleId: articleId,
        readingTime: readingTime,
        completed: completed,
        comprehensionScore: comprehensionScore,
      );

      // 更新当前文章状态
      if (_currentArticle?.id == articleId) {
        _currentArticle = _currentArticle!.copyWith(
          isCompleted: completed,
          comprehensionScore: comprehensionScore,
          readingTime: readingTime,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 获取阅读统计
  Future<void> loadReadingStats() async {
    _setLoading(true);
    _setError(null);

    try {
      _readingStats = await _readingService.getReadingStats();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 获取推荐文章
  Future<void> loadRecommendedArticles() async {
    try {
      _recommendedArticles = await _readingService.getRecommendedArticles();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// 收藏文章
  Future<bool> favoriteArticle(String articleId) async {
    try {
      await _readingService.favoriteArticle(articleId);
      
      // 更新文章收藏状态
      _updateArticleFavoriteStatus(articleId, true);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// 取消收藏文章
  Future<bool> unfavoriteArticle(String articleId) async {
    try {
      await _readingService.unfavoriteArticle(articleId);
      
      // 更新文章收藏状态
      _updateArticleFavoriteStatus(articleId, false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// 更新文章收藏状态
  void _updateArticleFavoriteStatus(String articleId, bool isFavorite) {
    // 注意：ReadingArticle模型中没有isFavorite字段
    // 这里只是通知UI更新，实际的收藏状态由服务器管理
    notifyListeners();
  }

  /// 获取收藏文章
  Future<void> loadFavoriteArticles() async {
    _setLoading(true);
    _setError(null);

    try {
      _favoriteArticles = await _readingService.getFavoriteArticles();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 获取阅读历史
  Future<void> loadReadingHistory() async {
    _setLoading(true);
    _setError(null);

    try {
      _readingHistory = await _readingService.getReadingHistory();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 设置筛选条件
  void setFilter({String? category, String? difficulty}) {
    _selectedCategory = category;
    _selectedDifficulty = difficulty;
    loadArticles(refresh: true);
  }

  /// 清除筛选条件
  void clearFilter() {
    _selectedCategory = null;
    _selectedDifficulty = null;
    _searchQuery = '';
    loadArticles(refresh: true);
  }

  /// 更新练习答案
  void updateExerciseAnswer(int questionIndex, String answer) {
    if (_currentExercise == null || questionIndex >= _currentExercise!.questions.length) {
      return;
    }

    final updatedQuestions = List<ReadingQuestion>.from(_currentExercise!.questions);
    updatedQuestions[questionIndex] = updatedQuestions[questionIndex].copyWith(
      userAnswer: answer,
    );

    _currentExercise = _currentExercise!.copyWith(
      questions: updatedQuestions,
    );
    notifyListeners();
  }

  /// 加载练习
  Future<void> loadExercise(String articleId) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentExercise = await _readingService.getArticleExercise(articleId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 更新问题答案
  void updateQuestionAnswer(String questionId, String answer) {
    if (_currentExercise == null) return;

    final updatedQuestions = _currentExercise!.questions.map((question) {
      if (question.id == questionId) {
        return question.copyWith(userAnswer: answer);
      }
      return question;
    }).toList();

    _currentExercise = _currentExercise!.copyWith(
      questions: updatedQuestions,
    );
    notifyListeners();
  }

  /// 重置练习
  void resetExercise() {
    if (_currentExercise == null) return;

    final resetQuestions = _currentExercise!.questions.map((question) {
      return question.copyWith(userAnswer: null);
    }).toList();

    _currentExercise = _currentExercise!.copyWith(
      questions: resetQuestions,
      startTime: null,
      endTime: null,
      score: null,
      isCompleted: false,
    );
    notifyListeners();
  }

  /// 清除当前练习
  void clearCurrentExercise() {
    _currentExercise = null;
    notifyListeners();
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }
}