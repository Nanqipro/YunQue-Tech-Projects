enum PronunciationCriteria {
  accuracy,
  fluency,
  completeness,
  prosody;

  String get displayName {
    switch (this) {
      case PronunciationCriteria.accuracy:
        return '准确性';
      case PronunciationCriteria.fluency:
        return '流利度';
      case PronunciationCriteria.completeness:
        return '完整性';
      case PronunciationCriteria.prosody:
        return '韵律';
    }
  }

  String get description {
    switch (this) {
      case PronunciationCriteria.accuracy:
        return '发音的准确程度';
      case PronunciationCriteria.fluency:
        return '语音的流畅程度';
      case PronunciationCriteria.completeness:
        return '内容的完整程度';
      case PronunciationCriteria.prosody:
        return '语调和节奏的自然程度';
    }
  }
}

class WordPronunciation {
  final String word;
  final double accuracyScore; // 0-100
  final String? errorType;
  final List<String> phonemes;
  final List<double> phonemeScores;
  final int startTime; // 毫秒
  final int endTime; // 毫秒

  const WordPronunciation({
    required this.word,
    required this.accuracyScore,
    this.errorType,
    required this.phonemes,
    required this.phonemeScores,
    required this.startTime,
    required this.endTime,
  });

  factory WordPronunciation.fromJson(Map<String, dynamic> json) {
    return WordPronunciation(
      word: json['word'] as String,
      accuracyScore: (json['accuracyScore'] as num).toDouble(),
      errorType: json['errorType'] as String?,
      phonemes: List<String>.from(json['phonemes'] ?? []),
      phonemeScores: List<double>.from(
        (json['phonemeScores'] as List<dynamic>? ?? [])
            .map((e) => (e as num).toDouble()),
      ),
      startTime: json['startTime'] as int,
      endTime: json['endTime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'accuracyScore': accuracyScore,
      'errorType': errorType,
      'phonemes': phonemes,
      'phonemeScores': phonemeScores,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class PronunciationAssessment {
  final String id;
  final String conversationId;
  final String messageId;
  final String originalText;
  final String recognizedText;
  final Map<PronunciationCriteria, double> scores; // 0-100
  final double overallScore; // 0-100
  final List<WordPronunciation> wordDetails;
  final List<String> suggestions;
  final DateTime assessedAt;
  final Map<String, dynamic>? metadata;

  const PronunciationAssessment({
    required this.id,
    required this.conversationId,
    required this.messageId,
    required this.originalText,
    required this.recognizedText,
    required this.scores,
    required this.overallScore,
    required this.wordDetails,
    required this.suggestions,
    required this.assessedAt,
    this.metadata,
  });

  factory PronunciationAssessment.fromJson(Map<String, dynamic> json) {
    final scoresMap = <PronunciationCriteria, double>{};
    final scoresJson = json['scores'] as Map<String, dynamic>? ?? {};
    for (final criteria in PronunciationCriteria.values) {
      scoresMap[criteria] = (scoresJson[criteria.name] as num?)?.toDouble() ?? 0.0;
    }

    return PronunciationAssessment(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      messageId: json['messageId'] as String,
      originalText: json['originalText'] as String,
      recognizedText: json['recognizedText'] as String,
      scores: scoresMap,
      overallScore: (json['overallScore'] as num).toDouble(),
      wordDetails: (json['wordDetails'] as List<dynamic>? ?? [])
          .map((e) => WordPronunciation.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      assessedAt: DateTime.parse(json['assessedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final scoresJson = <String, double>{};
    for (final entry in scores.entries) {
      scoresJson[entry.key.name] = entry.value;
    }

    return {
      'id': id,
      'conversationId': conversationId,
      'messageId': messageId,
      'originalText': originalText,
      'recognizedText': recognizedText,
      'scores': scoresJson,
      'overallScore': overallScore,
      'wordDetails': wordDetails.map((e) => e.toJson()).toList(),
      'suggestions': suggestions,
      'assessedAt': assessedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  String get accuracyLevel {
    if (overallScore >= 90) return '优秀';
    if (overallScore >= 80) return '良好';
    if (overallScore >= 70) return '中等';
    if (overallScore >= 60) return '及格';
    return '需要改进';
  }

  List<String> get mainIssues {
    final issues = <String>[];
    
    if (scores[PronunciationCriteria.accuracy]! < 70) {
      issues.add('发音准确性需要提高');
    }
    if (scores[PronunciationCriteria.fluency]! < 70) {
      issues.add('语音流利度有待改善');
    }
    if (scores[PronunciationCriteria.prosody]! < 70) {
      issues.add('语调和节奏需要调整');
    }
    
    return issues;
  }
}