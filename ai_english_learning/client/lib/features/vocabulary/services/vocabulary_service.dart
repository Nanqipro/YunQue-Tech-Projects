import 'dart:math';
import '../models/word_model.dart';
import '../models/vocabulary_book_model.dart';
import '../models/study_session_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';

/// 单词学习服务
class VocabularyService {
  final ApiClient _apiClient;
  final StorageService _storageService;
  final Random _random = Random();

  VocabularyService({
    required ApiClient apiClient,
    required StorageService storageService,
  }) : _apiClient = apiClient,
       _storageService = storageService;

  // ==================== 词汇书相关 ====================

  /// 获取系统词汇书列表
  Future<List<VocabularyBook>> getSystemVocabularyBooks({
    VocabularyBookDifficulty? difficulty,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/vocabulary/books/system',
        queryParameters: {
          if (difficulty != null) 'difficulty': difficulty.name,
          if (category != null) 'category': category,
          'page': page,
          'limit': limit,
        },
      );
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => VocabularyBook.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取系统词汇书失败: $e');
    }
  }

  /// 获取用户词汇书列表
  Future<List<VocabularyBook>> getUserVocabularyBooks() async {
    try {
      final response = await _apiClient.get('/vocabulary/books/user');
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => VocabularyBook.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取用户词汇书失败: $e');
    }
  }

  /// 获取词汇书详情
  Future<VocabularyBook> getVocabularyBookDetail(String bookId) async {
    try {
      final response = await _apiClient.get('/vocabulary/books/$bookId');
      return VocabularyBook.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取词汇书详情失败: $e');
    }
  }

  /// 获取词汇书单词列表
  Future<List<VocabularyBookWord>> getVocabularyBookWords(
    String bookId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '/vocabulary/books/$bookId/words',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => VocabularyBookWord.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取词汇书单词失败: $e');
    }
  }

  /// 添加词汇书到用户库
  Future<void> addVocabularyBookToUser(String bookId) async {
    try {
      await _apiClient.post('/vocabulary/books/$bookId/add');
    } catch (e) {
      throw Exception('添加词汇书失败: $e');
    }
  }

  /// 创建自定义词汇书
  Future<VocabularyBook> createCustomVocabularyBook({
    required String name,
    String? description,
    List<String> wordIds = const [],
  }) async {
    try {
      final response = await _apiClient.post(
        '/vocabulary/books/custom',
        data: {
          'name': name,
          'description': description,
          'wordIds': wordIds,
        },
      );
      
      return VocabularyBook.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('创建词汇书失败: $e');
    }
  }

  // ==================== 单词相关 ====================

  /// 搜索单词
  Future<List<Word>> searchWords(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/vocabulary/words/search',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
      );
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Word.fromJson(json)).toList();
    } catch (e) {
      throw Exception('搜索单词失败: $e');
    }
  }

  /// 获取单词详情
  Future<Word> getWordDetail(String wordId) async {
    try {
      final response = await _apiClient.get('/vocabulary/words/$wordId');
      return Word.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取单词详情失败: $e');
    }
  }

  /// 获取用户单词学习进度
  Future<UserWordProgress?> getUserWordProgress(String wordId) async {
    try {
      final response = await _apiClient.get('/vocabulary/words/$wordId/progress');
      final data = response.data['data'];
      return data != null ? UserWordProgress.fromJson(data) : null;
    } catch (e) {
      throw Exception('获取单词学习进度失败: $e');
    }
  }

  /// 更新用户单词学习进度
  Future<UserWordProgress> updateUserWordProgress({
    required String wordId,
    required LearningStatus status,
    required bool isCorrect,
    int responseTime = 0,
  }) async {
    try {
      final response = await _apiClient.put(
        '/vocabulary/words/$wordId/progress',
        data: {
          'status': status.name,
          'isCorrect': isCorrect,
          'responseTime': responseTime,
        },
      );
      
      return UserWordProgress.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('更新单词学习进度失败: $e');
    }
  }

  // ==================== 学习会话相关 ====================

  /// 开始学习会话
  Future<StudySession> startStudySession({
    String? vocabularyBookId,
    required StudyMode mode,
    required int targetWordCount,
  }) async {
    try {
      final response = await _apiClient.post(
        '/vocabulary/study/sessions',
        data: {
          'vocabularyBookId': vocabularyBookId,
          'mode': mode.name,
          'targetWordCount': targetWordCount,
        },
      );
      
      return StudySession.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('开始学习会话失败: $e');
    }
  }

  /// 结束学习会话
  Future<StudySession> endStudySession(
    String sessionId, {
    required int durationSeconds,
    required List<WordExerciseRecord> exercises,
  }) async {
    try {
      final response = await _apiClient.put(
        '/vocabulary/study/sessions/$sessionId/end',
        data: {
          'durationSeconds': durationSeconds,
          'exercises': exercises.map((e) => e.toJson()).toList(),
        },
      );
      
      return StudySession.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('结束学习会话失败: $e');
    }
  }

  /// 获取学习会话历史
  Future<List<StudySession>> getStudySessionHistory({
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        '/vocabulary/study/sessions',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => StudySession.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取学习会话历史失败: $e');
    }
  }

  // ==================== 学习统计相关 ====================

  /// 获取学习统计
  Future<StudyStatistics> getStudyStatistics(DateTime date) async {
    try {
      final response = await _apiClient.get(
        '/vocabulary/study/statistics',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
        },
      );
      
      return StudyStatistics.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取学习统计失败: $e');
    }
  }

  /// 获取学习统计历史
  Future<List<StudyStatistics>> getStudyStatisticsHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        '/vocabulary/study/statistics/history',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => StudyStatistics.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取学习统计历史失败: $e');
    }
  }

  // ==================== 智能学习算法 ====================

  /// 获取今日需要学习的单词
  Future<List<Word>> getTodayStudyWords({
    String? vocabularyBookId,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/vocabulary/study/today',
        queryParameters: {
          if (vocabularyBookId != null) 'vocabularyBookId': vocabularyBookId,
          'limit': limit,
        },
      );
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Word.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取今日学习单词失败: $e');
    }
  }

  /// 获取需要复习的单词
  Future<List<Word>> getReviewWords({
    String? vocabularyBookId,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/vocabulary/study/review',
        queryParameters: {
          if (vocabularyBookId != null) 'vocabularyBookId': vocabularyBookId,
          'limit': limit,
        },
      );
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Word.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取复习单词失败: $e');
    }
  }

  /// 生成单词练习题
  Future<Map<String, dynamic>> generateWordExercise(
    String wordId,
    ExerciseType exerciseType,
  ) async {
    try {
      final response = await _apiClient.post(
        '/vocabulary/study/exercise',
        data: {
          'wordId': wordId,
          'exerciseType': exerciseType.name,
        },
      );
      
      return response.data['data'];
    } catch (e) {
      throw Exception('生成练习题失败: $e');
    }
  }

  // ==================== 本地缓存相关 ====================

  /// 缓存词汇书到本地
  Future<void> cacheVocabularyBook(VocabularyBook book) async {
    try {
      await _storageService.setString(
        'vocabulary_book_${book.id}',
        book.toJson().toString(),
      );
    } catch (e) {
      throw Exception('缓存词汇书失败: $e');
    }
  }

  /// 从本地获取缓存的词汇书
  Future<VocabularyBook?> getCachedVocabularyBook(String bookId) async {
    try {
      final cached = await _storageService.getString('vocabulary_book_$bookId');
      if (cached != null) {
        // 这里需要实际的JSON解析逻辑
        // return VocabularyBook.fromJson(jsonDecode(cached));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 清除本地缓存
  Future<void> clearCache() async {
    try {
      // 清除所有词汇相关的缓存
      await _storageService.remove('vocabulary_books');
      await _storageService.remove('study_statistics');
    } catch (e) {
      throw Exception('清除缓存失败: $e');
    }
  }

  // ==================== 工具方法 ====================

  /// 计算单词熟练度
  int calculateWordProficiency(UserWordProgress progress) {
    if (progress.studyCount == 0) return 0;
    
    final accuracy = progress.accuracy;
    final studyCount = progress.studyCount;
    final reviewInterval = progress.reviewInterval;
    
    // 基于准确率、学习次数和复习间隔计算熟练度
    int proficiency = (accuracy * 50).round();
    proficiency += (studyCount * 5).clamp(0, 30);
    proficiency += (reviewInterval * 2).clamp(0, 20);
    
    return proficiency.clamp(0, 100);
  }

  /// 计算下次复习时间
  DateTime calculateNextReviewTime(UserWordProgress progress) {
    final now = DateTime.now();
    final accuracy = progress.accuracy;
    
    // 基于准确率调整复习间隔
    int intervalDays = progress.reviewInterval;
    
    if (accuracy >= 0.9) {
      intervalDays = (intervalDays * 2).clamp(1, 30);
    } else if (accuracy >= 0.7) {
      intervalDays = (intervalDays * 1.5).round().clamp(1, 14);
    } else if (accuracy >= 0.5) {
      intervalDays = intervalDays.clamp(1, 7);
    } else {
      intervalDays = 1;
    }
    
    return now.add(Duration(days: intervalDays));
  }

  /// 随机选择练习类型
  ExerciseType getRandomExerciseType() {
    final types = ExerciseType.values;
    return types[_random.nextInt(types.length)];
  }

  /// 生成干扰选项
  List<String> generateDistractors(
    String correctAnswer,
    List<String> wordPool,
    int count,
  ) {
    final distractors = <String>[];
    final shuffled = List<String>.from(wordPool)..shuffle(_random);
    
    for (final word in shuffled) {
      if (word != correctAnswer && !distractors.contains(word)) {
        distractors.add(word);
        if (distractors.length >= count) break;
      }
    }
    
    return distractors;
  }
}