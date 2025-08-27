import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word_model.dart';
import '../models/vocabulary_book_model.dart';
import '../models/study_session_model.dart';
import '../services/vocabulary_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';

/// 词汇状态
class VocabularyState {
  final bool isLoading;
  final String? error;
  final List<VocabularyBook> systemBooks;
  final List<VocabularyBook> userBooks;
  final List<Word> todayWords;
  final List<Word> reviewWords;
  final StudyStatistics? todayStatistics;
  final StudySession? currentSession;

  const VocabularyState({
    this.isLoading = false,
    this.error,
    this.systemBooks = const [],
    this.userBooks = const [],
    this.todayWords = const [],
    this.reviewWords = const [],
    this.todayStatistics,
    this.currentSession,
  });

  VocabularyState copyWith({
    bool? isLoading,
    String? error,
    List<VocabularyBook>? systemBooks,
    List<VocabularyBook>? userBooks,
    List<Word>? todayWords,
    List<Word>? reviewWords,
    StudyStatistics? todayStatistics,
    StudySession? currentSession,
  }) {
    return VocabularyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      systemBooks: systemBooks ?? this.systemBooks,
      userBooks: userBooks ?? this.userBooks,
      todayWords: todayWords ?? this.todayWords,
      reviewWords: reviewWords ?? this.reviewWords,
      todayStatistics: todayStatistics ?? this.todayStatistics,
      currentSession: currentSession ?? this.currentSession,
    );
  }
}

/// 词汇状态管理
class VocabularyNotifier extends StateNotifier<VocabularyState> {
  final VocabularyService _vocabularyService;

  VocabularyNotifier(this._vocabularyService) : super(const VocabularyState());

  /// 加载系统词汇书
  Future<void> loadSystemVocabularyBooks({
    VocabularyBookDifficulty? difficulty,
    String? category,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final books = await _vocabularyService.getSystemVocabularyBooks(
        difficulty: difficulty,
        category: category,
      );
      
      state = state.copyWith(
        isLoading: false,
        systemBooks: books,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 加载用户词汇书
  Future<void> loadUserVocabularyBooks() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final books = await _vocabularyService.getUserVocabularyBooks();
      
      state = state.copyWith(
        isLoading: false,
        userBooks: books,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 加载今日学习单词
  Future<void> loadTodayStudyWords() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final words = await _vocabularyService.getTodayStudyWords();
      final statistics = await _vocabularyService.getStudyStatistics(DateTime.now());
      
      state = state.copyWith(
        isLoading: false,
        todayWords: words,
        todayStatistics: statistics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 加载复习单词
  Future<void> loadReviewWords() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final words = await _vocabularyService.getReviewWords();
      
      state = state.copyWith(
        isLoading: false,
        reviewWords: words,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 添加词汇书到用户
  Future<void> addVocabularyBookToUser(String bookId) async {
    try {
      await _vocabularyService.addVocabularyBookToUser(bookId);
      // 重新加载用户词汇书
      await loadUserVocabularyBooks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 开始学习会话
  Future<void> startStudySession({
    required StudyMode mode,
    String? vocabularyBookId,
    required int targetWordCount,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final session = await _vocabularyService.startStudySession(
        mode: mode,
        vocabularyBookId: vocabularyBookId,
        targetWordCount: targetWordCount,
      );
      
      state = state.copyWith(
        isLoading: false,
        currentSession: session,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 结束学习会话
  Future<void> endStudySession({
    required String sessionId,
    required int durationSeconds,
    required List<WordExerciseRecord> exercises,
  }) async {
    try {
      await _vocabularyService.endStudySession(
        sessionId,
        durationSeconds: durationSeconds,
        exercises: exercises,
      );
      
      state = state.copyWith(currentSession: null);
      
      // 重新加载今日数据
      await loadTodayStudyWords();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 更新单词学习进度
  Future<void> updateWordProgress({
    required String wordId,
    required LearningStatus status,
    required bool isCorrect,
    int responseTime = 0,
  }) async {
    try {
      await _vocabularyService.updateUserWordProgress(
        wordId: wordId,
        status: status,
        isCorrect: isCorrect,
        responseTime: responseTime,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 词汇服务提供者
final vocabularyServiceProvider = FutureProvider<VocabularyService>((ref) async {
  final apiClient = ApiClient.instance;
  final storageService = await StorageService.getInstance();
  return VocabularyService(
    apiClient: apiClient,
    storageService: storageService,
  );
});

/// 词汇状态提供者
final vocabularyProvider = StateNotifierProvider.autoDispose<VocabularyNotifier, VocabularyState>((ref) {
  final vocabularyServiceAsync = ref.watch(vocabularyServiceProvider);
  
  // 如果服务还在加载中，返回一个空状态的notifier
  if (vocabularyServiceAsync.isLoading) {
    return VocabularyNotifier(VocabularyService(
      apiClient: ApiClient.instance,
      storageService: StorageService.getInstance().then((value) => value) as StorageService,
    ));
  }
  
  // 如果有错误，抛出错误
  if (vocabularyServiceAsync.hasError) {
    throw vocabularyServiceAsync.error!;
  }
  
  // 返回正常的notifier
  return VocabularyNotifier(vocabularyServiceAsync.value!);
});

/// 当前学习会话提供者
final currentStudySessionProvider = Provider<StudySession?>((ref) {
  final vocabularyState = ref.watch(vocabularyProvider);
  return vocabularyState.currentSession;
});

/// 今日学习统计提供者
final todayStatisticsProvider = Provider<StudyStatistics?>((ref) {
  final vocabularyState = ref.watch(vocabularyProvider);
  return vocabularyState.todayStatistics;
});

/// 用户词汇书提供者
final userVocabularyBooksProvider = Provider<List<VocabularyBook>>((ref) {
  final vocabularyState = ref.watch(vocabularyProvider);
  return vocabularyState.userBooks;
});

/// 系统词汇书提供者
final systemVocabularyBooksProvider = Provider<List<VocabularyBook>>((ref) {
  final vocabularyState = ref.watch(vocabularyProvider);
  return vocabularyState.systemBooks;
});

/// 今日单词提供者
final todayWordsProvider = Provider<List<Word>>((ref) {
  final vocabularyState = ref.watch(vocabularyProvider);
  return vocabularyState.todayWords;
});

/// 复习单词提供者
final reviewWordsProvider = Provider<List<Word>>((ref) {
  final vocabularyState = ref.watch(vocabularyProvider);
  return vocabularyState.reviewWords;
});