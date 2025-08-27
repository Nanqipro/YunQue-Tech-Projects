import 'package:flutter/foundation.dart';
import '../models/speaking_scenario.dart';
import '../models/conversation.dart';
import '../models/pronunciation_assessment.dart';
import '../models/speaking_stats.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/audio_service.dart';

class SpeakingProvider with ChangeNotifier {
  final ApiService _apiService;
  final AudioService _audioService;

  SpeakingProvider({
    required ApiService apiService,
    required AudioService audioService,
  })  : _apiService = apiService,
        _audioService = audioService;

  // 状态管理
  bool _isLoading = false;
  String? _error;
  
  // 任务相关
  List<SpeakingTask> _tasks = [];
  SpeakingTask? _currentTask;
  
  // 对话相关
  Conversation? _currentConversation;
  bool _isRecording = false;
  bool _isPlaying = false;
  
  // 评估相关
  List<PronunciationAssessment> _assessments = [];
  
  // 统计相关
  SpeakingStats? _stats;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SpeakingTask> get tasks => _tasks;
  SpeakingTask? get currentTask => _currentTask;
  Conversation? get currentConversation => _currentConversation;
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  List<PronunciationAssessment> get assessments => _assessments;
  SpeakingStats? get stats => _stats;

  // 加载任务列表
  Future<void> loadTasks() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.get('/speaking/tasks');
      _tasks = (response.data as List<dynamic>)
          .map((json) => SpeakingTask.fromJson(json as Map<String, dynamic>))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError('加载任务失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 按条件筛选任务
  Future<void> loadTasksByFilter({
    SpeakingScenario? scenario,
    SpeakingDifficulty? difficulty,
    String? sortBy,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final queryParams = <String, dynamic>{};
      if (scenario != null) queryParams['scenario'] = scenario.name;
      if (difficulty != null) queryParams['difficulty'] = difficulty.name;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      
      final response = await _apiService.get('/speaking/tasks', queryParams: queryParams);
      _tasks = (response.data as List<dynamic>)
          .map((json) => SpeakingTask.fromJson(json as Map<String, dynamic>))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError('筛选任务失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 开始对话任务
  Future<void> startConversation(String taskId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.post('/speaking/conversations', {
        'taskId': taskId,
      });
      
      _currentConversation = Conversation.fromJson(response.data as Map<String, dynamic>);
      _currentTask = _tasks.firstWhere((task) => task.id == taskId);
      
      notifyListeners();
    } catch (e) {
      _setError('开始对话失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 发送消息
  Future<void> sendMessage(String content, {String? audioUrl}) async {
    if (_currentConversation == null) return;
    
    try {
      final userMessage = ConversationMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        type: MessageType.user,
        timestamp: DateTime.now(),
        audioUrl: audioUrl,
      );
      
      // 立即添加用户消息
      _currentConversation = _currentConversation!.copyWith(
        messages: [..._currentConversation!.messages, userMessage],
      );
      notifyListeners();
      
      // 发送到服务器并获取AI回复
      final response = await _apiService.post(
        '/speaking/conversations/${_currentConversation!.id}/messages',
        {
          'content': content,
          'audioUrl': audioUrl,
        },
      );
      
      final aiMessage = ConversationMessage.fromJson(
        response.data['aiMessage'] as Map<String, dynamic>,
      );
      
      _currentConversation = _currentConversation!.copyWith(
        messages: [..._currentConversation!.messages, aiMessage],
      );
      
      // 如果有发音评估
      if (response.data['assessment'] != null) {
        final assessment = PronunciationAssessment.fromJson(
          response.data['assessment'] as Map<String, dynamic>,
        );
        _assessments.add(assessment);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('发送消息失败: ${e.toString()}');
    }
  }

  // 开始录音
  Future<void> startRecording() async {
    try {
      await _audioService.startRecording();
      _isRecording = true;
      notifyListeners();
    } catch (e) {
      _setError('开始录音失败: ${e.toString()}');
    }
  }

  // 停止录音
  Future<String?> stopRecording() async {
    try {
      final audioPath = await _audioService.stopRecording();
      _isRecording = false;
      notifyListeners();
      return audioPath;
    } catch (e) {
      _setError('停止录音失败: ${e.toString()}');
      return null;
    }
  }

  // 播放音频
  Future<void> playAudio(String audioUrl) async {
    try {
      _isPlaying = true;
      notifyListeners();
      
      await _audioService.playAudio(audioUrl);
      
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _setError('播放音频失败: ${e.toString()}');
      _isPlaying = false;
      notifyListeners();
    }
  }

  // 暂停对话
  Future<void> pauseConversation() async {
    if (_currentConversation == null) return;
    
    try {
      await _apiService.patch(
        '/speaking/conversations/${_currentConversation!.id}',
        {'status': 'paused'},
      );
      
      _currentConversation = _currentConversation!.copyWith(
        status: ConversationStatus.paused,
      );
      notifyListeners();
    } catch (e) {
      _setError('暂停对话失败: ${e.toString()}');
    }
  }

  // 结束对话
  Future<void> endConversation() async {
    if (_currentConversation == null) return;
    
    try {
      await _apiService.patch(
        '/speaking/conversations/${_currentConversation!.id}',
        {'status': 'completed'},
      );
      
      _currentConversation = _currentConversation!.copyWith(
        status: ConversationStatus.completed,
        endTime: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      _setError('结束对话失败: ${e.toString()}');
    }
  }

  // 加载统计数据
  Future<void> loadStats() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiService.get('/speaking/stats');
      _stats = SpeakingStats.fromJson(response.data as Map<String, dynamic>);
      
      notifyListeners();
    } catch (e) {
      _setError('加载统计数据失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 加载历史对话
  Future<List<Conversation>> loadConversationHistory() async {
    try {
      final response = await _apiService.get('/speaking/conversations');
      return (response.data as List<dynamic>)
          .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _setError('加载历史对话失败: ${e.toString()}');
      return [];
    }
  }

  // 清除当前对话
  void clearCurrentConversation() {
    _currentConversation = null;
    _currentTask = null;
    _assessments.clear();
    notifyListeners();
  }

  // 私有方法
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
    _audioService.dispose();
    super.dispose();
  }
}