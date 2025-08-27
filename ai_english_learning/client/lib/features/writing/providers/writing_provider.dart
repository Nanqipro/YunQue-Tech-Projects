import 'package:flutter/foundation.dart';
import '../models/writing_task.dart';
import '../models/writing_submission.dart';
import '../models/writing_stats.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';

class WritingProvider with ChangeNotifier {
  final ApiClient _apiClient;

  WritingProvider({
    required ApiClient apiClient,
    required StorageService storageService,
  }) : _apiClient = apiClient;

  // 状态变量
  List<WritingTask> _tasks = [];
  List<WritingSubmission> _submissions = [];
  WritingStats? _stats;
  WritingTask? _currentTask;
  WritingSubmission? _currentSubmission;
  String _currentContent = '';
  int _currentWordCount = 0;
  int _timeSpent = 0;
  bool _isLoading = false;
  String? _error;
  
  // 筛选和排序
  WritingType? _selectedType;
  WritingDifficulty? _selectedDifficulty;
  String _sortBy = 'createdAt';
  bool _sortAscending = false;

  // Getters
  List<WritingTask> get tasks => _tasks;
  List<WritingSubmission> get submissions => _submissions;
  WritingStats? get stats => _stats;
  WritingTask? get currentTask => _currentTask;
  WritingSubmission? get currentSubmission => _currentSubmission;
  String get currentContent => _currentContent;
  int get currentWordCount => _currentWordCount;
  int get timeSpent => _timeSpent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  WritingType? get selectedType => _selectedType;
  WritingDifficulty? get selectedDifficulty => _selectedDifficulty;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  // 筛选后的任务列表
  List<WritingTask> get filteredTasks {
    var filtered = _tasks.where((task) {
      if (_selectedType != null && task.type != _selectedType) {
        return false;
      }
      if (_selectedDifficulty != null && task.difficulty != _selectedDifficulty) {
        return false;
      }
      return true;
    }).toList();

    // 排序
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'difficulty':
          comparison = a.difficulty.level.compareTo(b.difficulty.level);
          break;
        case 'timeLimit':
          comparison = a.timeLimit.compareTo(b.timeLimit);
          break;
        case 'wordLimit':
          comparison = a.wordLimit.compareTo(b.wordLimit);
          break;
        case 'createdAt':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  // 加载写作任务列表
  Future<void> loadTasks() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiClient.get('/writing/tasks');
      if (response.data['success']) {
        _tasks = (response.data['data'] as List)
            .map((json) => WritingTask.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        _setError(response.data['message'] ?? '加载任务失败');
      }
    } catch (e) {
      _setError('网络错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 根据类型和难度加载任务
  Future<void> loadTasksByFilter({
    WritingType? type,
    WritingDifficulty? difficulty,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final params = <String, dynamic>{};
      if (type != null) params['type'] = type.name;
      if (difficulty != null) params['difficulty'] = difficulty.name;
      
      final response = await _apiClient.get('/writing/tasks', queryParameters: params);
      if (response.data['success']) {
        _tasks = (response.data['data'] as List)
            .map((json) => WritingTask.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        _setError(response.data['message'] ?? '加载任务失败');
      }
    } catch (e) {
      _setError('网络错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 获取任务详情
  Future<void> loadTaskDetail(String taskId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiClient.get('/writing/tasks/$taskId');
      if (response.data['success']) {
        _currentTask = WritingTask.fromJson(response.data['data']);
        notifyListeners();
      } else {
        _setError(response.data['message'] ?? '加载任务详情失败');
      }
    } catch (e) {
      _setError('网络错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 开始写作任务
  Future<void> startTask(String taskId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiClient.post('/writing/submissions', data: {
        'taskId': taskId,
        'status': 'draft',
      });
      
      if (response.data['success']) {
        _currentSubmission = WritingSubmission.fromJson(response.data['data']);
        _currentContent = '';
        _currentWordCount = 0;
        _timeSpent = 0;
        notifyListeners();
      } else {
        _setError(response.data['message'] ?? '开始任务失败');
      }
    } catch (e) {
      _setError('网络错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 更新写作内容
  void updateContent(String content) {
    _currentContent = content;
    _currentWordCount = _countWords(content);
    notifyListeners();
    
    // 自动保存草稿
    _saveDraft();
  }

  // 更新时间
  void updateTimeSpent(int seconds) {
    _timeSpent = seconds;
    notifyListeners();
  }

  // 保存草稿
  Future<void> _saveDraft() async {
    if (_currentSubmission == null) return;
    
    try {
      await _apiClient.put('/writing/submissions/${_currentSubmission!.id}', data: {
        'content': _currentContent,
        'wordCount': _currentWordCount,
        'timeSpent': _timeSpent,
        'status': 'draft',
      });
    } catch (e) {
      // 静默处理草稿保存错误
      debugPrint('保存草稿失败: $e');
    }
  }

  // 提交写作
  Future<bool> submitWriting() async {
    if (_currentSubmission == null) return false;
    
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiClient.put(
        '/writing/submissions/${_currentSubmission!.id}',
        data: {
          'content': _currentContent,
          'wordCount': _currentWordCount,
          'timeSpent': _timeSpent,
          'status': 'submitted',
        },
      );
      
      if (response.data['success']) {
        _currentSubmission = WritingSubmission.fromJson(response.data['data']);
        notifyListeners();
        return true;
      } else {
        _setError(response.data['message'] ?? '提交失败');
        return false;
      }
    } catch (e) {
      _setError('网络错误: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 获取评分结果
  Future<void> loadSubmissionResult(String submissionId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiClient.get('/writing/submissions/$submissionId');
      if (response.data['success']) {
        _currentSubmission = WritingSubmission.fromJson(response.data['data']);
        notifyListeners();
      } else {
        _setError(response.data['message'] ?? '加载结果失败');
      }
    } catch (e) {
      _setError('网络错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 加载用户提交历史
  Future<void> loadSubmissions() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiClient.get('/writing/submissions');
      if (response.data['success']) {
        _submissions = (response.data['data'] as List)
            .map((json) => WritingSubmission.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        _setError(response.data['message'] ?? '加载提交历史失败');
      }
    } catch (e) {
      _setError('网络错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 加载统计数据
  Future<void> loadStats() async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _apiClient.get('/writing/stats');
      if (response.data['success']) {
        _stats = WritingStats.fromJson(response.data['data']);
        notifyListeners();
      } else {
        _setError(response.data['message'] ?? '加载统计数据失败');
      }
    } catch (e) {
      _setError('网络错误: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 设置筛选条件
  void setTypeFilter(WritingType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setDifficultyFilter(WritingDifficulty? difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  // 设置排序
  void setSorting(String sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) {
      _sortAscending = ascending;
    } else {
      _sortAscending = _sortBy == sortBy ? !_sortAscending : false;
    }
    notifyListeners();
  }

  // 清除筛选
  void clearFilters() {
    _selectedType = null;
    _selectedDifficulty = null;
    notifyListeners();
  }

  // 重置当前任务
  void resetCurrentTask() {
    _currentTask = null;
    _currentSubmission = null;
    _currentContent = '';
    _currentWordCount = 0;
    _timeSpent = 0;
    notifyListeners();
  }

  // 工具方法
  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).
        where((word) => word.isNotEmpty).length;
  }

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


}