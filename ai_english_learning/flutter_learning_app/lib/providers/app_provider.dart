import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/word.dart';
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  List<Word> _words = [];
  int _currentWordIndex = 0;
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  List<Word> get words => _words;
  Word? get currentWord => _words.isNotEmpty ? _words[_currentWordIndex] : null;
  int get currentWordIndex => _currentWordIndex;
  int get learnedWordsCount => _words.where((w) => w.isLearned).length;
  int get totalWordsCount => _words.length;
  bool get isLoading => _isLoading;
  double get progressPercentage => 
      _words.isEmpty ? 0.0 : learnedWordsCount / totalWordsCount;

  Future<bool> login(String email, String username) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      User? user = await _databaseService.getUser(email);
      if (user == null) {
        // 创建新用户
        user = User(username: username, email: email);
        await _databaseService.insertUser(user);
        user = await _databaseService.getUser(email);
      }
      _currentUser = user;
      await loadWords();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Login error: $e');
      return false;
    }
  }

  Future<void> loadWords() async {
    try {
      _words = await _databaseService.getAllWords();
      _currentWordIndex = 0;
      notifyListeners();
    } catch (e) {
      print('Load words error: $e');
    }
  }

  void nextWord() {
    if (_currentWordIndex < _words.length - 1) {
      _currentWordIndex++;
      notifyListeners();
    }
  }

  void previousWord() {
    if (_currentWordIndex > 0) {
      _currentWordIndex--;
      notifyListeners();
    }
  }

  void goToWord(int index) {
    if (index >= 0 && index < _words.length) {
      _currentWordIndex = index;
      notifyListeners();
    }
  }

  Future<void> markWordAsLearned(int wordId) async {
    try {
      await _databaseService.updateWordLearned(wordId, true);
      final wordIndex = _words.indexWhere((w) => w.id == wordId);
      if (wordIndex != -1) {
        _words[wordIndex].isLearned = true;
        
        // 更新用户分数
        if (_currentUser != null) {
          int newScore = _currentUser!.score + 10;
          await _databaseService.updateUserScore(_currentUser!.id!, newScore);
          _currentUser = User(
            id: _currentUser!.id,
            username: _currentUser!.username,
            email: _currentUser!.email,
            level: _currentUser!.level,
            score: newScore,
          );
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Mark word as learned error: $e');
    }
  }

  Future<void> markWordAsUnlearned(int wordId) async {
    try {
      await _databaseService.updateWordLearned(wordId, false);
      final wordIndex = _words.indexWhere((w) => w.id == wordId);
      if (wordIndex != -1) {
        _words[wordIndex].isLearned = false;
        notifyListeners();
      }
    } catch (e) {
      print('Mark word as unlearned error: $e');
    }
  }

  List<Word> getWordsByDifficulty(int difficulty) {
    return _words.where((word) => word.difficulty == difficulty).toList();
  }

  List<Word> getLearnedWords() {
    return _words.where((word) => word.isLearned).toList();
  }

  List<Word> getUnlearnedWords() {
    return _words.where((word) => !word.isLearned).toList();
  }

  void resetProgress() {
    for (var word in _words) {
      if (word.isLearned) {
        markWordAsUnlearned(word.id!);
      }
    }
    _currentWordIndex = 0;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _words.clear();
    _currentWordIndex = 0;
    _isLoading = false;
    notifyListeners();
  }

  // 获取学习统计信息
  Map<String, int> getStatistics() {
    Map<String, int> stats = {
      'total': _words.length,
      'learned': learnedWordsCount,
      'unlearned': _words.length - learnedWordsCount,
      'easy': _words.where((w) => w.difficulty == 1).length,
      'medium': _words.where((w) => w.difficulty == 2).length,
      'hard': _words.where((w) => w.difficulty == 3).length,
    };
    return stats;
  }
}