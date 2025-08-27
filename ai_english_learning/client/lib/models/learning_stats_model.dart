class LearningStatsModel {
  final int learnedWords;
  final int consecutiveDays;
  final double averageScore;
  final int totalStudyTime; // 总学习时间（分钟）
  final int completedLessons;
  final DateTime lastStudyDate;
  
  const LearningStatsModel({
    required this.learnedWords,
    required this.consecutiveDays,
    required this.averageScore,
    required this.totalStudyTime,
    required this.completedLessons,
    required this.lastStudyDate,
  });
  
  factory LearningStatsModel.fromJson(Map<String, dynamic> json) {
    return LearningStatsModel(
      learnedWords: json['learnedWords'] ?? 0,
      consecutiveDays: json['consecutiveDays'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      totalStudyTime: json['totalStudyTime'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      lastStudyDate: DateTime.parse(json['lastStudyDate'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'learnedWords': learnedWords,
      'consecutiveDays': consecutiveDays,
      'averageScore': averageScore,
      'totalStudyTime': totalStudyTime,
      'completedLessons': completedLessons,
      'lastStudyDate': lastStudyDate.toIso8601String(),
    };
  }
  
  LearningStatsModel copyWith({
    int? learnedWords,
    int? consecutiveDays,
    double? averageScore,
    int? totalStudyTime,
    int? completedLessons,
    DateTime? lastStudyDate,
  }) {
    return LearningStatsModel(
      learnedWords: learnedWords ?? this.learnedWords,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      averageScore: averageScore ?? this.averageScore,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      completedLessons: completedLessons ?? this.completedLessons,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }
}