import 'writing_task.dart';

class WritingSubmission {
  final String id;
  final String taskId;
  final String userId;
  final String content;
  final int wordCount;
  final int timeSpent; // 秒
  final WritingStatus status;
  final DateTime submittedAt;
  final WritingFeedback? feedback;
  final WritingScore? score;

  const WritingSubmission({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    required this.wordCount,
    required this.timeSpent,
    required this.status,
    required this.submittedAt,
    this.feedback,
    this.score,
  });

  factory WritingSubmission.fromJson(Map<String, dynamic> json) {
    return WritingSubmission(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      wordCount: json['wordCount'] as int,
      timeSpent: json['timeSpent'] as int,
      status: WritingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WritingStatus.draft,
      ),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      feedback: json['feedback'] != null 
          ? WritingFeedback.fromJson(json['feedback'] as Map<String, dynamic>)
          : null,
      score: json['score'] != null 
          ? WritingScore.fromJson(json['score'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'content': content,
      'wordCount': wordCount,
      'timeSpent': timeSpent,
      'status': status.name,
      'submittedAt': submittedAt.toIso8601String(),
      'feedback': feedback?.toJson(),
      'score': score?.toJson(),
    };
  }

  WritingSubmission copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? content,
    int? wordCount,
    int? timeSpent,
    WritingStatus? status,
    DateTime? submittedAt,
    WritingFeedback? feedback,
    WritingScore? score,
  }) {
    return WritingSubmission(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      wordCount: wordCount ?? this.wordCount,
      timeSpent: timeSpent ?? this.timeSpent,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      feedback: feedback ?? this.feedback,
      score: score ?? this.score,
    );
  }
}

class WritingFeedback {
  final String id;
  final String submissionId;
  final String overallComment;
  final List<WritingCriteriaFeedback> criteriaFeedbacks;
  final List<WritingError> errors;
  final List<WritingSuggestion> suggestions;
  final DateTime createdAt;

  const WritingFeedback({
    required this.id,
    required this.submissionId,
    required this.overallComment,
    required this.criteriaFeedbacks,
    required this.errors,
    required this.suggestions,
    required this.createdAt,
  });

  factory WritingFeedback.fromJson(Map<String, dynamic> json) {
    return WritingFeedback(
      id: json['id'] as String,
      submissionId: json['submissionId'] as String,
      overallComment: json['overallComment'] as String,
      criteriaFeedbacks: (json['criteriaFeedbacks'] as List<dynamic>)
          .map((e) => WritingCriteriaFeedback.fromJson(e as Map<String, dynamic>))
          .toList(),
      errors: (json['errors'] as List<dynamic>)
          .map((e) => WritingError.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => WritingSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submissionId': submissionId,
      'overallComment': overallComment,
      'criteriaFeedbacks': criteriaFeedbacks.map((e) => e.toJson()).toList(),
      'errors': errors.map((e) => e.toJson()).toList(),
      'suggestions': suggestions.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class WritingScore {
  final String id;
  final String submissionId;
  final double totalScore;
  final double maxScore;
  final Map<WritingCriteria, double> criteriaScores;
  final String grade;
  final DateTime createdAt;

  const WritingScore({
    required this.id,
    required this.submissionId,
    required this.totalScore,
    required this.maxScore,
    required this.criteriaScores,
    required this.grade,
    required this.createdAt,
  });

  double get percentage => (totalScore / maxScore) * 100;

  factory WritingScore.fromJson(Map<String, dynamic> json) {
    return WritingScore(
      id: json['id'] as String,
      submissionId: json['submissionId'] as String,
      totalScore: (json['totalScore'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      criteriaScores: Map<WritingCriteria, double>.fromEntries(
        (json['criteriaScores'] as Map<String, dynamic>).entries.map(
          (e) => MapEntry(
            WritingCriteria.values.firstWhere((c) => c.name == e.key),
            (e.value as num).toDouble(),
          ),
        ),
      ),
      grade: json['grade'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'submissionId': submissionId,
      'totalScore': totalScore,
      'maxScore': maxScore,
      'criteriaScores': Map<String, dynamic>.fromEntries(
        criteriaScores.entries.map(
          (e) => MapEntry(e.key.name, e.value),
        ),
      ),
      'grade': grade,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class WritingCriteriaFeedback {
  final WritingCriteria criteria;
  final double score;
  final double maxScore;
  final String comment;
  final List<String> strengths;
  final List<String> improvements;

  const WritingCriteriaFeedback({
    required this.criteria,
    required this.score,
    required this.maxScore,
    required this.comment,
    required this.strengths,
    required this.improvements,
  });

  factory WritingCriteriaFeedback.fromJson(Map<String, dynamic> json) {
    return WritingCriteriaFeedback(
      criteria: WritingCriteria.values.firstWhere(
        (e) => e.name == json['criteria'],
      ),
      score: (json['score'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      comment: json['comment'] as String,
      strengths: List<String>.from(json['strengths'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criteria': criteria.name,
      'score': score,
      'maxScore': maxScore,
      'comment': comment,
      'strengths': strengths,
      'improvements': improvements,
    };
  }
}

class WritingError {
  final WritingErrorType type;
  final String description;
  final String originalText;
  final String? suggestedText;
  final int startPosition;
  final int endPosition;
  final String explanation;

  const WritingError({
    required this.type,
    required this.description,
    required this.originalText,
    this.suggestedText,
    required this.startPosition,
    required this.endPosition,
    required this.explanation,
  });

  factory WritingError.fromJson(Map<String, dynamic> json) {
    return WritingError(
      type: WritingErrorType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      description: json['description'] as String,
      originalText: json['originalText'] as String,
      suggestedText: json['suggestedText'] as String?,
      startPosition: json['startPosition'] as int,
      endPosition: json['endPosition'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'description': description,
      'originalText': originalText,
      'suggestedText': suggestedText,
      'startPosition': startPosition,
      'endPosition': endPosition,
      'explanation': explanation,
    };
  }
}

class WritingSuggestion {
  final WritingSuggestionType type;
  final String title;
  final String description;
  final String? example;
  final int? position;

  const WritingSuggestion({
    required this.type,
    required this.title,
    required this.description,
    this.example,
    this.position,
  });

  factory WritingSuggestion.fromJson(Map<String, dynamic> json) {
    return WritingSuggestion(
      type: WritingSuggestionType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      example: json['example'] as String?,
      position: json['position'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'example': example,
      'position': position,
    };
  }
}

enum WritingStatus {
  draft,
  submitted,
  grading,
  graded,
  revised,
}

enum WritingCriteria {
  content,
  organization,
  vocabulary,
  grammar,
  mechanics,
}

enum WritingErrorType {
  grammar,
  spelling,
  punctuation,
  vocabulary,
  structure,
  style,
}

enum WritingSuggestionType {
  improvement,
  enhancement,
  alternative,
  clarification,
}

extension WritingStatusExtension on WritingStatus {
  String get displayName {
    switch (this) {
      case WritingStatus.draft:
        return '草稿';
      case WritingStatus.submitted:
        return '已提交';
      case WritingStatus.grading:
        return '评分中';
      case WritingStatus.graded:
        return '已评分';
      case WritingStatus.revised:
        return '已修改';
    }
  }
}

extension WritingCriteriaExtension on WritingCriteria {
  String get displayName {
    switch (this) {
      case WritingCriteria.content:
        return '内容';
      case WritingCriteria.organization:
        return '结构';
      case WritingCriteria.vocabulary:
        return '词汇';
      case WritingCriteria.grammar:
        return '语法';
      case WritingCriteria.mechanics:
        return '拼写标点';
    }
  }
}

extension WritingErrorTypeExtension on WritingErrorType {
  String get displayName {
    switch (this) {
      case WritingErrorType.grammar:
        return '语法错误';
      case WritingErrorType.spelling:
        return '拼写错误';
      case WritingErrorType.punctuation:
        return '标点错误';
      case WritingErrorType.vocabulary:
        return '词汇错误';
      case WritingErrorType.structure:
        return '结构错误';
      case WritingErrorType.style:
        return '风格问题';
    }
  }
}