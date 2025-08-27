import 'package:json_annotation/json_annotation.dart';

part 'listening_exercise_model.g.dart';

/// 听力练习类型
enum ListeningExerciseType {
  @JsonValue('conversation')
  conversation,
  @JsonValue('lecture')
  lecture,
  @JsonValue('news')
  news,
  @JsonValue('story')
  story,
  @JsonValue('interview')
  interview,
  @JsonValue('dialogue')
  dialogue,
}

/// 听力难度等级
enum ListeningDifficulty {
  @JsonValue('beginner')
  beginner,
  @JsonValue('elementary')
  elementary,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
  @JsonValue('expert')
  expert,
}

/// 听力问题类型
enum ListeningQuestionType {
  @JsonValue('multiple_choice')
  multipleChoice,
  @JsonValue('true_false')
  trueFalse,
  @JsonValue('fill_blank')
  fillBlank,
  @JsonValue('short_answer')
  shortAnswer,
  @JsonValue('matching')
  matching,
}

/// 听力练习问题
@JsonSerializable()
class ListeningQuestion {
  final String id;
  final ListeningQuestionType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final int timeStart; // 音频开始时间（秒）
  final int timeEnd; // 音频结束时间（秒）
  final int points;

  const ListeningQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.timeStart,
    required this.timeEnd,
    required this.points,
  });

  factory ListeningQuestion.fromJson(Map<String, dynamic> json) =>
      _$ListeningQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$ListeningQuestionToJson(this);
}

/// 听力练习
@JsonSerializable()
class ListeningExercise {
  final String id;
  final String title;
  final String description;
  final ListeningExerciseType type;
  final ListeningDifficulty difficulty;
  final String audioUrl;
  final int duration; // 音频时长（秒）
  final String transcript;
  final List<ListeningQuestion> questions;
  final List<String> tags;
  final String thumbnailUrl;
  final int totalPoints;
  final double passingScore;
  final String creatorId;
  final String creatorName;
  final bool isPublic;
  final int playCount;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ListeningExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.audioUrl,
    required this.duration,
    required this.transcript,
    required this.questions,
    required this.tags,
    required this.thumbnailUrl,
    required this.totalPoints,
    required this.passingScore,
    required this.creatorId,
    required this.creatorName,
    required this.isPublic,
    required this.playCount,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ListeningExercise.fromJson(Map<String, dynamic> json) =>
      _$ListeningExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ListeningExerciseToJson(this);
}

/// 听力练习结果
@JsonSerializable()
class ListeningExerciseResult {
  final String id;
  final String exerciseId;
  final String userId;
  final List<String> userAnswers;
  final List<bool> correctAnswers;
  final int totalQuestions;
  final int correctCount;
  final double score;
  final int timeSpent; // 用时（秒）
  final int playCount; // 播放次数
  final bool isPassed;
  final DateTime completedAt;

  const ListeningExerciseResult({
    required this.id,
    required this.exerciseId,
    required this.userId,
    required this.userAnswers,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.correctCount,
    required this.score,
    required this.timeSpent,
    required this.playCount,
    required this.isPassed,
    required this.completedAt,
  });

  factory ListeningExerciseResult.fromJson(Map<String, dynamic> json) =>
      _$ListeningExerciseResultFromJson(json);

  Map<String, dynamic> toJson() => _$ListeningExerciseResultToJson(this);

  double get accuracy => totalQuestions > 0 ? correctCount / totalQuestions : 0.0;
}

/// 听力学习统计
@JsonSerializable()
class ListeningStatistics {
  final String userId;
  final int totalExercises;
  final int completedExercises;
  final int totalQuestions;
  final int correctAnswers;
  final double averageScore;
  final int totalTimeSpent; // 总用时（秒）
  final int totalPlayCount;
  final Map<ListeningDifficulty, int> difficultyStats;
  final Map<ListeningExerciseType, int> typeStats;
  final DateTime lastUpdated;

  const ListeningStatistics({
    required this.userId,
    required this.totalExercises,
    required this.completedExercises,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.averageScore,
    required this.totalTimeSpent,
    required this.totalPlayCount,
    required this.difficultyStats,
    required this.typeStats,
    required this.lastUpdated,
  });

  factory ListeningStatistics.fromJson(Map<String, dynamic> json) =>
      _$ListeningStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$ListeningStatisticsToJson(this);

  double get completionRate => totalExercises > 0 ? completedExercises / totalExercises : 0.0;
  double get accuracy => totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
  double get averageTimePerExercise => completedExercises > 0 ? totalTimeSpent / completedExercises : 0.0;
}