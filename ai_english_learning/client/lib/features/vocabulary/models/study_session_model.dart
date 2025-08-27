import 'package:json_annotation/json_annotation.dart';
import 'word_model.dart';

part 'study_session_model.g.dart';

/// 学习模式
enum StudyMode {
  @JsonValue('new_words')
  newWords, // 学习新单词
  @JsonValue('review')
  review, // 复习单词
  @JsonValue('mixed')
  mixed, // 混合模式
  @JsonValue('test')
  test, // 测试模式
  @JsonValue('quick_review')
  quickReview, // 快速复习
}

/// 练习类型
enum ExerciseType {
  @JsonValue('word_meaning')
  wordMeaning, // 单词释义
  @JsonValue('meaning_word')
  meaningWord, // 释义选单词
  @JsonValue('spelling')
  spelling, // 拼写练习
  @JsonValue('listening')
  listening, // 听力练习
  @JsonValue('sentence_completion')
  sentenceCompletion, // 句子填空
  @JsonValue('synonym_antonym')
  synonymAntonym, // 同义词反义词
  @JsonValue('image_word')
  imageWord, // 图片识词
}

/// 答题结果
enum AnswerResult {
  @JsonValue('correct')
  correct,
  @JsonValue('wrong')
  wrong,
  @JsonValue('skipped')
  skipped,
}

/// 学习会话
@JsonSerializable()
class StudySession {
  /// 会话ID
  final String id;
  
  /// 用户ID
  final String userId;
  
  /// 词汇书ID
  final String? vocabularyBookId;
  
  /// 学习模式
  final StudyMode mode;
  
  /// 目标单词数
  final int targetWordCount;
  
  /// 实际学习单词数
  final int actualWordCount;
  
  /// 正确答题数
  final int correctAnswers;
  
  /// 错误答题数
  final int wrongAnswers;
  
  /// 跳过答题数
  final int skippedAnswers;
  
  /// 学习时长（秒）
  final int durationSeconds;
  
  /// 准确率
  final double accuracy;
  
  /// 获得经验值
  final int experienceGained;
  
  /// 获得积分
  final int pointsGained;
  
  /// 是否完成
  final bool isCompleted;
  
  /// 开始时间
  final DateTime startedAt;
  
  /// 结束时间
  final DateTime? endedAt;
  
  /// 创建时间
  final DateTime createdAt;

  const StudySession({
    required this.id,
    required this.userId,
    this.vocabularyBookId,
    required this.mode,
    required this.targetWordCount,
    this.actualWordCount = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.skippedAnswers = 0,
    this.durationSeconds = 0,
    this.accuracy = 0.0,
    this.experienceGained = 0,
    this.pointsGained = 0,
    this.isCompleted = false,
    required this.startedAt,
    this.endedAt,
    required this.createdAt,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) => _$StudySessionFromJson(json);
  Map<String, dynamic> toJson() => _$StudySessionToJson(this);

  StudySession copyWith({
    String? id,
    String? userId,
    String? vocabularyBookId,
    StudyMode? mode,
    int? targetWordCount,
    int? actualWordCount,
    int? correctAnswers,
    int? wrongAnswers,
    int? skippedAnswers,
    int? durationSeconds,
    double? accuracy,
    int? experienceGained,
    int? pointsGained,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? createdAt,
  }) {
    return StudySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vocabularyBookId: vocabularyBookId ?? this.vocabularyBookId,
      mode: mode ?? this.mode,
      targetWordCount: targetWordCount ?? this.targetWordCount,
      actualWordCount: actualWordCount ?? this.actualWordCount,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      skippedAnswers: skippedAnswers ?? this.skippedAnswers,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      accuracy: accuracy ?? this.accuracy,
      experienceGained: experienceGained ?? this.experienceGained,
      pointsGained: pointsGained ?? this.pointsGained,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 总答题数
  int get totalAnswers => correctAnswers + wrongAnswers + skippedAnswers;

  /// 计算准确率
  double calculateAccuracy() {
    if (totalAnswers == 0) return 0.0;
    return correctAnswers / totalAnswers;
  }

  /// 学习时长（分钟）
  double get durationMinutes => durationSeconds / 60.0;
}

/// 单词练习记录
@JsonSerializable()
class WordExerciseRecord {
  /// 记录ID
  final String id;
  
  /// 学习会话ID
  final String sessionId;
  
  /// 单词ID
  final String wordId;
  
  /// 练习类型
  final ExerciseType exerciseType;
  
  /// 用户答案
  final String userAnswer;
  
  /// 正确答案
  final String correctAnswer;
  
  /// 答题结果
  final AnswerResult result;
  
  /// 答题时间（秒）
  final int responseTimeSeconds;
  
  /// 提示次数
  final int hintCount;
  
  /// 单词信息
  final Word? word;
  
  /// 答题时间
  final DateTime answeredAt;

  const WordExerciseRecord({
    required this.id,
    required this.sessionId,
    required this.wordId,
    required this.exerciseType,
    required this.userAnswer,
    required this.correctAnswer,
    required this.result,
    required this.responseTimeSeconds,
    this.hintCount = 0,
    this.word,
    required this.answeredAt,
  });

  factory WordExerciseRecord.fromJson(Map<String, dynamic> json) => _$WordExerciseRecordFromJson(json);
  Map<String, dynamic> toJson() => _$WordExerciseRecordToJson(this);

  WordExerciseRecord copyWith({
    String? id,
    String? sessionId,
    String? wordId,
    ExerciseType? exerciseType,
    String? userAnswer,
    String? correctAnswer,
    AnswerResult? result,
    int? responseTimeSeconds,
    int? hintCount,
    Word? word,
    DateTime? answeredAt,
  }) {
    return WordExerciseRecord(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      wordId: wordId ?? this.wordId,
      exerciseType: exerciseType ?? this.exerciseType,
      userAnswer: userAnswer ?? this.userAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      result: result ?? this.result,
      responseTimeSeconds: responseTimeSeconds ?? this.responseTimeSeconds,
      hintCount: hintCount ?? this.hintCount,
      word: word ?? this.word,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  /// 是否正确
  bool get isCorrect => result == AnswerResult.correct;

  /// 是否错误
  bool get isWrong => result == AnswerResult.wrong;

  /// 是否跳过
  bool get isSkipped => result == AnswerResult.skipped;

  /// 答题时间（分钟）
  double get responseTimeMinutes => responseTimeSeconds / 60.0;
}

/// 学习统计
@JsonSerializable()
class StudyStatistics {
  /// 统计ID
  final String id;
  
  /// 用户ID
  final String userId;
  
  /// 统计日期
  final DateTime date;
  
  /// 学习会话数
  final int sessionCount;
  
  /// 学习单词数
  final int wordsStudied;
  
  /// 新学单词数
  final int newWordsLearned;
  
  /// 复习单词数
  final int wordsReviewed;
  
  /// 掌握单词数
  final int wordsMastered;
  
  /// 学习时长（秒）
  final int totalStudyTimeSeconds;
  
  /// 正确答题数
  final int correctAnswers;
  
  /// 错误答题数
  final int wrongAnswers;
  
  /// 平均准确率
  final double averageAccuracy;
  
  /// 获得经验值
  final int experienceGained;
  
  /// 获得积分
  final int pointsGained;
  
  /// 连续学习天数
  final int streakDays;

  const StudyStatistics({
    required this.id,
    required this.userId,
    required this.date,
    this.sessionCount = 0,
    this.wordsStudied = 0,
    this.newWordsLearned = 0,
    this.wordsReviewed = 0,
    this.wordsMastered = 0,
    this.totalStudyTimeSeconds = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.averageAccuracy = 0.0,
    this.experienceGained = 0,
    this.pointsGained = 0,
    this.streakDays = 0,
  });

  factory StudyStatistics.fromJson(Map<String, dynamic> json) => _$StudyStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$StudyStatisticsToJson(this);

  StudyStatistics copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? sessionCount,
    int? wordsStudied,
    int? newWordsLearned,
    int? wordsReviewed,
    int? wordsMastered,
    int? totalStudyTimeSeconds,
    int? correctAnswers,
    int? wrongAnswers,
    double? averageAccuracy,
    int? experienceGained,
    int? pointsGained,
    int? streakDays,
  }) {
    return StudyStatistics(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      sessionCount: sessionCount ?? this.sessionCount,
      wordsStudied: wordsStudied ?? this.wordsStudied,
      newWordsLearned: newWordsLearned ?? this.newWordsLearned,
      wordsReviewed: wordsReviewed ?? this.wordsReviewed,
      wordsMastered: wordsMastered ?? this.wordsMastered,
      totalStudyTimeSeconds: totalStudyTimeSeconds ?? this.totalStudyTimeSeconds,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      experienceGained: experienceGained ?? this.experienceGained,
      pointsGained: pointsGained ?? this.pointsGained,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  /// 总答题数
  int get totalAnswers => correctAnswers + wrongAnswers;

  /// 学习时长（分钟）
  double get totalStudyTimeMinutes => totalStudyTimeSeconds / 60.0;

  /// 学习时长（小时）
  double get totalStudyTimeHours => totalStudyTimeSeconds / 3600.0;
}