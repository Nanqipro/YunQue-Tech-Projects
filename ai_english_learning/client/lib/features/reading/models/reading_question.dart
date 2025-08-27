enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInBlank,
  shortAnswer,
}

class ReadingQuestion {
  final String id;
  final String articleId;
  final QuestionType type;
  final String question;
  final List<String> options; // For multiple choice questions
  final String correctAnswer;
  final String explanation;
  final int order;
  final String? userAnswer;
  final bool? isCorrect;

  const ReadingQuestion({
    required this.id,
    required this.articleId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.order,
    this.userAnswer,
    this.isCorrect,
  });

  factory ReadingQuestion.fromJson(Map<String, dynamic> json) {
    return ReadingQuestion(
      id: json['id'] as String,
      articleId: json['articleId'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List? ?? []),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
      order: json['order'] as int,
      userAnswer: json['userAnswer'] as String?,
      isCorrect: json['isCorrect'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'type': type.toString().split('.').last,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'order': order,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
    };
  }

  ReadingQuestion copyWith({
    String? id,
    String? articleId,
    QuestionType? type,
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    int? order,
    String? userAnswer,
    bool? isCorrect,
  }) {
    return ReadingQuestion(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      order: order ?? this.order,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  String get typeLabel {
    switch (type) {
      case QuestionType.multipleChoice:
        return '选择题';
      case QuestionType.trueFalse:
        return '判断题';
      case QuestionType.fillInBlank:
        return '填空题';
      case QuestionType.shortAnswer:
        return '简答题';
    }
  }
}

class ReadingExercise {
  final String id;
  final String articleId;
  final List<ReadingQuestion> questions;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? score;
  final bool isCompleted;

  const ReadingExercise({
    required this.id,
    required this.articleId,
    required this.questions,
    this.startTime,
    this.endTime,
    this.score,
    this.isCompleted = false,
  });

  factory ReadingExercise.fromJson(Map<String, dynamic> json) {
    return ReadingExercise(
      id: json['id'] as String,
      articleId: json['articleId'] as String,
      questions: (json['questions'] as List)
          .map((q) => ReadingQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      score: json['score'] as double?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'score': score,
      'isCompleted': isCompleted,
    };
  }

  ReadingExercise copyWith({
    String? id,
    String? articleId,
    List<ReadingQuestion>? questions,
    DateTime? startTime,
    DateTime? endTime,
    double? score,
    bool? isCompleted,
  }) {
    return ReadingExercise(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      questions: questions ?? this.questions,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  int get totalQuestions => questions.length;

  int get answeredQuestions {
    return questions.where((q) => q.userAnswer != null).length;
  }

  int get correctAnswers {
    return questions.where((q) => q.isCorrect == true).length;
  }

  double get progressPercentage {
    if (totalQuestions == 0) return 0.0;
    return (answeredQuestions / totalQuestions) * 100;
  }

  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }
}

/// 阅读练习结果
class ReadingExerciseResult {
  final double score;
  final int correctCount;
  final int totalCount;
  final Duration timeSpent; // 用时
  final double accuracy;

  const ReadingExerciseResult({
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.timeSpent,
    required this.accuracy,
  });

  /// 错误题数
  int get wrongCount => totalCount - correctCount;

  /// 总题数（别名）
  int get totalQuestions => totalCount;

  factory ReadingExerciseResult.fromJson(Map<String, dynamic> json) {
    return ReadingExerciseResult(
      score: (json['score'] as num).toDouble(),
      correctCount: json['correctCount'] as int,
      totalCount: json['totalCount'] as int,
      timeSpent: Duration(seconds: json['timeSpent'] as int),
      accuracy: (json['accuracy'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'timeSpent': timeSpent.inSeconds,
      'accuracy': accuracy,
    };
  }

  bool get isPassed => score >= 60.0;
}