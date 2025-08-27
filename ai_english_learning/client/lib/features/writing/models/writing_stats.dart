class WritingStats {
  final String userId;
  final int totalTasks;
  final int completedTasks;
  final int totalWords;
  final int totalTimeSpent; // 秒
  final double averageScore;
  final Map<String, int> taskTypeStats;
  final Map<String, int> difficultyStats;
  final List<WritingProgressData> progressData;
  final WritingSkillAnalysis skillAnalysis;
  final DateTime lastUpdated;

  const WritingStats({
    required this.userId,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalWords,
    required this.totalTimeSpent,
    required this.averageScore,
    required this.taskTypeStats,
    required this.difficultyStats,
    required this.progressData,
    required this.skillAnalysis,
    required this.lastUpdated,
  });

  double get completionRate => totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
  
  double get averageWordsPerTask => completedTasks > 0 ? totalWords / completedTasks : 0;
  
  double get averageTimePerTask => completedTasks > 0 ? totalTimeSpent / completedTasks : 0;

  factory WritingStats.fromJson(Map<String, dynamic> json) {
    return WritingStats(
      userId: json['userId'] as String,
      totalTasks: json['totalTasks'] as int,
      completedTasks: json['completedTasks'] as int,
      totalWords: json['totalWords'] as int,
      totalTimeSpent: json['totalTimeSpent'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      taskTypeStats: Map<String, int>.from(json['taskTypeStats'] ?? {}),
      difficultyStats: Map<String, int>.from(json['difficultyStats'] ?? {}),
      progressData: (json['progressData'] as List<dynamic>)
          .map((e) => WritingProgressData.fromJson(e as Map<String, dynamic>))
          .toList(),
      skillAnalysis: WritingSkillAnalysis.fromJson(
        json['skillAnalysis'] as Map<String, dynamic>,
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'totalWords': totalWords,
      'totalTimeSpent': totalTimeSpent,
      'averageScore': averageScore,
      'taskTypeStats': taskTypeStats,
      'difficultyStats': difficultyStats,
      'progressData': progressData.map((e) => e.toJson()).toList(),
      'skillAnalysis': skillAnalysis.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  WritingStats copyWith({
    String? userId,
    int? totalTasks,
    int? completedTasks,
    int? totalWords,
    int? totalTimeSpent,
    double? averageScore,
    Map<String, int>? taskTypeStats,
    Map<String, int>? difficultyStats,
    List<WritingProgressData>? progressData,
    WritingSkillAnalysis? skillAnalysis,
    DateTime? lastUpdated,
  }) {
    return WritingStats(
      userId: userId ?? this.userId,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      totalWords: totalWords ?? this.totalWords,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      averageScore: averageScore ?? this.averageScore,
      taskTypeStats: taskTypeStats ?? this.taskTypeStats,
      difficultyStats: difficultyStats ?? this.difficultyStats,
      progressData: progressData ?? this.progressData,
      skillAnalysis: skillAnalysis ?? this.skillAnalysis,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class WritingProgressData {
  final DateTime date;
  final double score;
  final int wordCount;
  final int timeSpent;
  final String taskType;
  final String difficulty;

  const WritingProgressData({
    required this.date,
    required this.score,
    required this.wordCount,
    required this.timeSpent,
    required this.taskType,
    required this.difficulty,
  });

  factory WritingProgressData.fromJson(Map<String, dynamic> json) {
    return WritingProgressData(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
      wordCount: json['wordCount'] as int,
      timeSpent: json['timeSpent'] as int,
      taskType: json['taskType'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'score': score,
      'wordCount': wordCount,
      'timeSpent': timeSpent,
      'taskType': taskType,
      'difficulty': difficulty,
    };
  }
}

class WritingSkillAnalysis {
  final Map<String, double> criteriaScores;
  final Map<String, int> errorCounts;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final double improvementRate;
  final DateTime lastAnalyzed;

  const WritingSkillAnalysis({
    required this.criteriaScores,
    required this.errorCounts,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.improvementRate,
    required this.lastAnalyzed,
  });

  factory WritingSkillAnalysis.fromJson(Map<String, dynamic> json) {
    return WritingSkillAnalysis(
      criteriaScores: Map<String, double>.from(
        (json['criteriaScores'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      ),
      errorCounts: Map<String, int>.from(json['errorCounts'] ?? {}),
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      improvementRate: (json['improvementRate'] as num).toDouble(),
      lastAnalyzed: DateTime.parse(json['lastAnalyzed'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criteriaScores': criteriaScores,
      'errorCounts': errorCounts,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations,
      'improvementRate': improvementRate,
      'lastAnalyzed': lastAnalyzed.toIso8601String(),
    };
  }
}