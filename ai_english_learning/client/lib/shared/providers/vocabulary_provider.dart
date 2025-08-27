import 'package:flutter/foundation.dart';
import '../models/vocabulary_model.dart';
import '../models/api_response.dart';
import '../services/vocabulary_service.dart';
import '../../core/errors/app_error.dart';

/// 词汇学习状态
enum VocabularyState {
  initial,
  loading,
  loaded,
  error,
}

/// 词汇学习Provider
class VocabularyProvider with ChangeNotifier {
  final VocabularyService _vocabularyService;
  
  VocabularyProvider(this._vocabularyService);
  
  // 状态管理
  VocabularyState _state = VocabularyState.initial;
  String? _errorMessage;
  
  // 词库数据
  List<VocabularyBookModel> _vocabularyBooks = [];
  VocabularyBookModel? _currentBook;
  
  // 词汇数据
  List<VocabularyModel> _vocabularies = [];
  List<UserVocabularyModel> _userVocabularies = [];
  VocabularyModel? _currentVocabulary;
  
  // 学习数据
  List<VocabularyModel> _todayReviewWords = [];
  List<VocabularyModel> _newWords = [];
  Map<String, dynamic> _learningStats = {};
  
  // 分页数据
  int _currentPage = 1;
  bool _hasMoreData = true;
  
  // Getters
  VocabularyState get state => _state;
  String? get errorMessage => _errorMessage;
  List<VocabularyBookModel> get vocabularyBooks => _vocabularyBooks;
  VocabularyBookModel? get currentBook => _currentBook;
  List<VocabularyModel> get vocabularies => _vocabularies;
  List<UserVocabularyModel> get userVocabularies => _userVocabularies;
  VocabularyModel? get currentVocabulary => _currentVocabulary;
  List<VocabularyModel> get todayReviewWords => _todayReviewWords;
  List<VocabularyModel> get newWords => _newWords;
  Map<String, dynamic> get learningStats => _learningStats;
  int get currentPage => _currentPage;
  bool get hasMoreData => _hasMoreData;
  
  /// 设置状态
  void _setState(VocabularyState newState, [String? error]) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }
  
  /// 获取词库列表
  Future<void> loadVocabularyBooks() async {
    try {
      _setState(VocabularyState.loading);
      
      final response = await _vocabularyService.getVocabularyBooks();
      
      if (response.success && response.data != null) {
        _vocabularyBooks = response.data!;
        _setState(VocabularyState.loaded);
      } else {
        _setState(VocabularyState.error, response.message);
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
    }
  }
  
  /// 设置当前词库
  void setCurrentBook(VocabularyBookModel book) {
    _currentBook = book;
    _vocabularies.clear();
    _currentPage = 1;
    _hasMoreData = true;
    notifyListeners();
  }
  
  /// 获取词汇列表
  Future<void> loadVocabularies({
    String? bookId,
    String? search,
    String? difficulty,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        _setState(VocabularyState.loading);
        _currentPage = 1;
        _vocabularies.clear();
      }
      
      final response = await _vocabularyService.getVocabularies(
        bookId: bookId ?? _currentBook?.bookId.toString(),
        page: _currentPage,
        search: search,
        level: difficulty,
      );
      
      if (response.success && response.data != null) {
        final newVocabularies = response.data!.data;
        
        if (loadMore) {
          _vocabularies.addAll(newVocabularies);
        } else {
          _vocabularies = newVocabularies;
        }
        
        _hasMoreData = response.data!.pagination.hasNextPage;
        _currentPage++;
        _setState(VocabularyState.loaded);
      } else {
        _setState(VocabularyState.error, response.message);
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
    }
  }
  
  /// 获取单词详情
  Future<VocabularyModel?> getWordDetail(String wordId) async {
    try {
      final response = await _vocabularyService.getWordDetail(wordId);
      
      if (response.success && response.data != null) {
        _currentVocabulary = response.data!;
        notifyListeners();
        return response.data!;
      } else {
        _setState(VocabularyState.error, response.message);
        return null;
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
      return null;
    }
  }
  
  /// 获取用户词汇学习记录
  Future<void> loadUserVocabularies(String userId) async {
    try {
      final response = await _vocabularyService.getUserVocabularies();
      
      if (response.success && response.data != null) {
        _userVocabularies = response.data!.data;
        notifyListeners();
      } else {
        _setState(VocabularyState.error, response.message);
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
    }
  }
  
  /// 更新单词学习状态
  Future<bool> updateWordStatus(String wordId, LearningStatus status) async {
    try {
      final response = await _vocabularyService.updateWordStatus(
        wordId: wordId,
        status: status,
      );
      
      if (response.success) {
        // 更新本地数据
        final index = _userVocabularies.indexWhere((uv) => uv.wordId.toString() == wordId);
        if (index != -1) {
          // TODO: 实现UserVocabularyModel的copyWith方法
          // _userVocabularies[index] = _userVocabularies[index].copyWith(
          //   status: status,
          //   lastStudiedAt: DateTime.now(),
          // );
          notifyListeners();
        }
        return true;
      } else {
        _setState(VocabularyState.error, response.message);
        return false;
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
      return false;
    }
  }
  
  /// 添加单词到学习列表
  Future<bool> addToLearningList(String wordId) async {
    try {
      // TODO: 实现addToLearningList方法
      // final response = await _vocabularyService.addToLearningList(wordId);
      final response = ApiResponse.success(message: 'Added to learning list');
      
      if (response.success) {
        // 刷新用户词汇数据
        await loadUserVocabularies('current_user_id'); // TODO: 获取当前用户ID
        return true;
      } else {
        _setState(VocabularyState.error, response.message);
        return false;
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
      return false;
    }
  }
  
  /// 从学习列表移除单词
  Future<bool> removeFromLearningList(String wordId) async {
    try {
      // TODO: 实现removeFromLearningList方法
      // final response = await _vocabularyService.removeFromLearningList(wordId);
      final response = ApiResponse.success(message: 'Removed from learning list');
      
      if (response.success) {
        // 更新本地数据
        _userVocabularies.removeWhere((uv) => uv.wordId.toString() == wordId);
        notifyListeners();
        return true;
      } else {
        _setState(VocabularyState.error, response.message);
        return false;
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
      return false;
    }
  }
  
  /// 获取今日复习单词
  Future<void> loadTodayReviewWords() async {
    try {
      // TODO: 实现getTodayReviewWords方法
      // final response = await _vocabularyService.getTodayReviewWords();
      final response = ApiResponse<List<VocabularyModel>>.success(
        message: 'Today review words retrieved',
        data: <VocabularyModel>[],
      );
      
      if (response.success && response.data != null) {
        _todayReviewWords = response.data ?? [];
        notifyListeners();
      } else {
        _setState(VocabularyState.error, response.message);
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
    }
  }
  
  /// 获取新单词学习
  Future<void> loadNewWords({int limit = 20}) async {
    try {
      // TODO: 实现getNewWordsForLearning方法
      // final response = await _vocabularyService.getNewWordsForLearning(limit: limit);
      final response = ApiResponse<List<VocabularyModel>>.success(
        message: 'New words retrieved',
        data: <VocabularyModel>[],
      );
      
      if (response.success && response.data != null) {
        _newWords = response.data ?? [];
        notifyListeners();
      } else {
        _setState(VocabularyState.error, response.message);
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
    }
  }
  
  /// 进行词汇量测试
  Future<Map<String, dynamic>?> takeVocabularyTest(List<Map<String, dynamic>> answers) async {
    try {
      _setState(VocabularyState.loading);
      
      // TODO: 实现takeVocabularyTest方法
      // final response = await _vocabularyService.takeVocabularyTest(answers);
      final response = ApiResponse<Map<String, dynamic>>.success(
        message: 'Vocabulary test completed',
        data: <String, dynamic>{},
      );
      
      if (response.success && response.data != null) {
        _setState(VocabularyState.loaded);
        return response.data!;
      } else {
        _setState(VocabularyState.error, response.message);
        return null;
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
      return null;
    }
  }
  
  /// 获取学习统计
  Future<void> loadLearningStats() async {
    try {
      // TODO: 实现getLearningStats方法
      // final response = await _vocabularyService.getLearningStats();
      final response = ApiResponse<Map<String, dynamic>>.success(
        message: 'Learning stats retrieved',
        data: <String, dynamic>{},
      );
      
      if (response.success && response.data != null) {
        _learningStats = response.data ?? {};
        notifyListeners();
      } else {
        _setState(VocabularyState.error, response.message);
      }
    } catch (e) {
      _setState(VocabularyState.error, e.toString());
    }
  }
  
  /// 搜索词汇
  Future<void> searchVocabularies(String query) async {
    await loadVocabularies(search: query);
  }
  
  /// 按难度筛选词汇
  Future<void> filterByDifficulty(String difficulty) async {
    await loadVocabularies(difficulty: difficulty);
  }
  
  /// 加载更多词汇
  Future<void> loadMoreVocabularies() async {
    if (_hasMoreData && _state != VocabularyState.loading) {
      await loadVocabularies(loadMore: true);
    }
  }
  
  /// 清除错误状态
  void clearError() {
    _errorMessage = null;
    if (_state == VocabularyState.error) {
      _setState(VocabularyState.initial);
    }
  }
  
  /// 重置状态
  void reset() {
    _state = VocabularyState.initial;
    _errorMessage = null;
    _vocabularyBooks.clear();
    _currentBook = null;
    _vocabularies.clear();
    _userVocabularies.clear();
    _currentVocabulary = null;
    _todayReviewWords.clear();
    _newWords.clear();
    _learningStats.clear();
    _currentPage = 1;
    _hasMoreData = true;
    notifyListeners();
  }
}