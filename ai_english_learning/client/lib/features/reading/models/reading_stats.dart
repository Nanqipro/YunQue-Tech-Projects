class ReadingStats {
  final int totalArticlesRead;
  final int practicesDone;
  final double averageScore;
  final int totalReadingTime; // in minutes
  final double averageReadingSpeed; // words per minute
  final double comprehensionAccuracy; // percentage
  final int vocabularyMastered;
  final int consecutiveDays;
  final Map<String, int> categoryStats; // category -> articles read
  final Map<String, double> difficultyStats; // difficulty -> average score
  final List<DailyReadingRecord> dailyRecords;

  const ReadingStats({
    required this.totalArticlesRead,
    required this.practicesDone,
    required this.averageScore,
    required this.totalReadingTime,
    required this.averageReadingSpeed,
    required this.comprehensionAccuracy,
    required this.vocabularyMastered,
    required this.consecutiveDays,
    required this.categoryStats,
    required this.difficultyStats,
    required this.dailyRecords,
  });

  factory ReadingStats.fromJson(Map<String, dynamic> json) {
    return ReadingStats(
      totalArticlesRead: json['totalArticlesRead'] as int,
      practicesDone: json['practicesDone'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      totalReadingTime: json['totalReadingTime'] as int,
      averageReadingSpeed: (json['averageReadingSpeed'] as num).toDouble(),
      comprehensionAccuracy: (json['comprehensionAccuracy'] as num).toDouble(),
      vocabularyMastered: json['vocabularyMastered'] as int,
      consecutiveDays: json['consecutiveDays'] as int,
      categoryStats: Map<String, int>.from(json['categoryStats'] as Map),
      difficultyStats: Map<String, double>.from(
        (json['difficultyStats'] as Map).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      dailyRecords: (json['dailyRecords'] as List)
          .map((record) => DailyReadingRecord.fromJson(record as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalArticlesRead': totalArticlesRead,
      'practicesDone': practicesDone,
      'averageScore': averageScore,
      'totalReadingTime': totalReadingTime,
      'averageReadingSpeed': averageReadingSpeed,
      'comprehensionAccuracy': comprehensionAccuracy,
      'vocabularyMastered': vocabularyMastered,
      'consecutiveDays': consecutiveDays,
      'categoryStats': categoryStats,
      'difficultyStats': difficultyStats,
      'dailyRecords': dailyRecords.map((record) => record.toJson()).toList(),
    };
  }

  ReadingStats copyWith({
    int? totalArticlesRead,
    int? practicesDone,
    double? averageScore,
    int? totalReadingTime,
    double? averageReadingSpeed,
    double? comprehensionAccuracy,
    int? vocabularyMastered,
    int? consecutiveDays,
    Map<String, int>? categoryStats,
    Map<String, double>? difficultyStats,
    List<DailyReadingRecord>? dailyRecords,
  }) {
    return ReadingStats(
      totalArticlesRead: totalArticlesRead ?? this.totalArticlesRead,
      practicesDone: practicesDone ?? this.practicesDone,
      averageScore: averageScore ?? this.averageScore,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      averageReadingSpeed: averageReadingSpeed ?? this.averageReadingSpeed,
      comprehensionAccuracy: comprehensionAccuracy ?? this.comprehensionAccuracy,
      vocabularyMastered: vocabularyMastered ?? this.vocabularyMastered,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      categoryStats: categoryStats ?? this.categoryStats,
      difficultyStats: difficultyStats ?? this.difficultyStats,
      dailyRecords: dailyRecords ?? this.dailyRecords,
    );
  }

  String get readingTimeFormatted {
    final hours = totalReadingTime ~/ 60;
    final minutes = totalReadingTime % 60;
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    }
    return '${minutes}分钟';
  }

  String get averageScoreFormatted {
    return '${averageScore.toStringAsFixed(1)}分';
  }

  String get comprehensionAccuracyFormatted {
    return '${comprehensionAccuracy.toStringAsFixed(1)}%';
  }

  String get averageReadingSpeedFormatted {
    return '${averageReadingSpeed.toStringAsFixed(0)}词/分钟';
  }
}

class DailyReadingRecord {
  final DateTime date;
  final int articlesRead;
  final int practicesDone;
  final int readingTime; // in minutes
  final double averageScore;
  final int vocabularyLearned;

  const DailyReadingRecord({
    required this.date,
    required this.articlesRead,
    required this.practicesDone,
    required this.readingTime,
    required this.averageScore,
    required this.vocabularyLearned,
  });

  factory DailyReadingRecord.fromJson(Map<String, dynamic> json) {
    return DailyReadingRecord(
      date: DateTime.parse(json['date'] as String),
      articlesRead: json['articlesRead'] as int,
      practicesDone: json['practicesDone'] as int,
      readingTime: json['readingTime'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      vocabularyLearned: json['vocabularyLearned'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'articlesRead': articlesRead,
      'practicesDone': practicesDone,
      'readingTime': readingTime,
      'averageScore': averageScore,
      'vocabularyLearned': vocabularyLearned,
    };
  }

  DailyReadingRecord copyWith({
    DateTime? date,
    int? articlesRead,
    int? practicesDone,
    int? readingTime,
    double? averageScore,
    int? vocabularyLearned,
  }) {
    return DailyReadingRecord(
      date: date ?? this.date,
      articlesRead: articlesRead ?? this.articlesRead,
      practicesDone: practicesDone ?? this.practicesDone,
      readingTime: readingTime ?? this.readingTime,
      averageScore: averageScore ?? this.averageScore,
      vocabularyLearned: vocabularyLearned ?? this.vocabularyLearned,
    );
  }
}

class ReadingProgress {
  final String category;
  final int totalArticles;
  final int completedArticles;
  final double averageScore;
  final String difficulty;

  const ReadingProgress({
    required this.category,
    required this.totalArticles,
    required this.completedArticles,
    required this.averageScore,
    required this.difficulty,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      category: json['category'] as String,
      totalArticles: json['totalArticles'] as int,
      completedArticles: json['completedArticles'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'totalArticles': totalArticles,
      'completedArticles': completedArticles,
      'averageScore': averageScore,
      'difficulty': difficulty,
    };
  }

  double get progressPercentage {
    if (totalArticles == 0) return 0.0;
    return (completedArticles / totalArticles) * 100;
  }

  String get progressText {
    return '$completedArticles/$totalArticles';
  }

  String get categoryLabel {
    switch (category.toLowerCase()) {
      case 'cet4':
        return '四级阅读';
      case 'cet6':
        return '六级阅读';
      case 'toefl':
        return '托福阅读';
      case 'ielts':
        return '雅思阅读';
      case 'daily':
        return '日常阅读';
      case 'business':
        return '商务阅读';
      case 'academic':
        return '学术阅读';
      case 'news':
        return '新闻阅读';
      default:
        return category;
    }
  }
}