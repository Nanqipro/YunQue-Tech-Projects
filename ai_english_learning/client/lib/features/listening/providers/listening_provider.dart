import 'package:flutter/foundation.dart';
import '../models/listening_exercise_model.dart';
import '../services/listening_service.dart';

/// 听力训练状态管理提供者
class ListeningProvider with ChangeNotifier {
  // 注意：ListeningService 使用静态方法

  // 状态变量
  bool _isLoading = false;
  String? _error;
  List<ListeningExercise> _exercises = [];
  ListeningExercise? _currentExercise;
  List<ListeningQuestion> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _userAnswers = {};
  ListeningExerciseResult? _currentResult;
  ListeningStatistics? _statistics;
  bool _isPlaying = false;
  double _playbackPosition = 0.0;
  double _playbackSpeed = 1.0;
  bool _showTranscript = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ListeningExercise> get exercises => _exercises;
  ListeningExercise? get currentExercise => _currentExercise;
  List<ListeningQuestion> get currentQuestions => _currentQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, dynamic> get userAnswers => _userAnswers;
  ListeningExerciseResult? get currentResult => _currentResult;
  ListeningStatistics? get statistics => _statistics;
  bool get isPlaying => _isPlaying;
  double get playbackPosition => _playbackPosition;
  double get playbackSpeed => _playbackSpeed;
  bool get showTranscript => _showTranscript;

  ListeningQuestion? get currentQuestion {
    if (_currentQuestionIndex < _currentQuestions.length) {
      return _currentQuestions[_currentQuestionIndex];
    }
    return null;
  }

  bool get hasNextQuestion => _currentQuestionIndex < _currentQuestions.length - 1;
  bool get hasPreviousQuestion => _currentQuestionIndex > 0;
  bool get isLastQuestion => _currentQuestionIndex == _currentQuestions.length - 1;

  /// 获取听力练习列表
  Future<void> fetchExercises({
    ListeningExerciseType? type,
    ListeningDifficulty? difficulty,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final exercises = await ListeningService.getListeningExercises(
        type: type,
        difficulty: difficulty,
        page: page,
        limit: limit,
      );

      if (page == 1) {
        _exercises = exercises;
      } else {
        _exercises.addAll(exercises);
      }

      notifyListeners();
    } catch (e) {
      _setError('获取听力练习失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 开始听力练习
  Future<void> startExercise(String exerciseId) async {
    try {
      _setLoading(true);
      _clearError();

      final exercise = await ListeningService.getListeningExercise(exerciseId);
      _currentExercise = exercise;
      _currentQuestions = exercise.questions;
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _currentResult = null;
      _playbackPosition = 0.0;
      _playbackSpeed = 1.0;
      _showTranscript = false;

      notifyListeners();
    } catch (e) {
      _setError('加载听力练习失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 回答问题
  void answerQuestion(String questionId, dynamic answer) {
    _userAnswers[questionId] = answer;
    notifyListeners();
  }

  /// 下一题
  void nextQuestion() {
    if (hasNextQuestion) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// 上一题
  void previousQuestion() {
    if (hasPreviousQuestion) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// 跳转到指定题目
  void goToQuestion(int index) {
    if (index >= 0 && index < _currentQuestions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  /// 提交答案
  Future<void> submitAnswers() async {
    if (_currentExercise == null) return;

    try {
      _setLoading(true);
      _clearError();

      // 需要用户ID和其他参数，这里使用模拟数据
      final result = await ListeningService.submitListeningExercise(
        exerciseId: _currentExercise!.id,
        userId: 'current_user_id', // 应该从认证状态获取
        userAnswers: _userAnswers.values.map((e) => e.toString()).toList(),
        timeSpent: 0, // 应该计算实际时间
        playCount: 1, // 应该记录实际播放次数
      );

      _currentResult = result;
      notifyListeners();
    } catch (e) {
      _setError('提交答案失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 获取用户统计数据
  Future<void> fetchStatistics() async {
    try {
      _setLoading(true);
      _clearError();

      final stats = await ListeningService.getUserListeningStatistics('current_user_id'); // 应该从认证状态获取
      _statistics = stats;
      notifyListeners();
    } catch (e) {
      _setError('获取统计数据失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 音频播放控制
  void togglePlayback() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void pausePlayback() {
    _isPlaying = false;
    notifyListeners();
  }

  void resumePlayback() {
    _isPlaying = true;
    notifyListeners();
  }

  void updatePlaybackPosition(double position) {
    _playbackPosition = position;
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  void seekTo(double position) {
    _playbackPosition = position;
    notifyListeners();
  }

  /// 显示/隐藏听力文本
  void toggleTranscript() {
    _showTranscript = !_showTranscript;
    notifyListeners();
  }

  /// 重置练习
  void resetExercise() {
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _currentResult = null;
    _playbackPosition = 0.0;
    _isPlaying = false;
    _showTranscript = false;
    notifyListeners();
  }

  /// 清除当前练习
  void clearCurrentExercise() {
    _currentExercise = null;
    _currentQuestions.clear();
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _currentResult = null;
    _playbackPosition = 0.0;
    _isPlaying = false;
    _showTranscript = false;
    notifyListeners();
  }

  /// 搜索练习
  Future<void> searchExercises(String query) async {
    try {
      _setLoading(true);
      _clearError();

      final exercises = await ListeningService.searchListeningExercises(query: query);
      _exercises = exercises;
      notifyListeners();
    } catch (e) {
      _setError('搜索失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 获取推荐练习
  Future<void> fetchRecommendedExercises() async {
    try {
      _setLoading(true);
      _clearError();

      final exercises = await ListeningService.getRecommendedListeningExercises(userId: 'current_user_id'); // 应该从认证状态获取
      _exercises = exercises;
      notifyListeners();
    } catch (e) {
      _setError('获取推荐练习失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    // 清理资源
    super.dispose();
  }
}