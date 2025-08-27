import 'speaking_scenario.dart';
import 'pronunciation_assessment.dart';

class SpeakingStats {
  final int totalSessions;
  final int totalMinutes;
  final double averageScore;
  final Map<SpeakingScenario, int> scenarioStats;
  final Map<SpeakingDifficulty, int> difficultyStats;
  final List<SpeakingProgressData> progressData;
  final SpeakingSkillAnalysis skillAnalysis;
  final DateTime lastUpdated;

  const SpeakingStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.averageScore,
    required this.scenarioStats,
    required this.difficultyStats,
    required this.progressData,
    required this.skillAnalysis,
    required this.lastUpdated,
  });

  factory SpeakingStats.fromJson(Map<String, dynamic> json) {
    final scenarioStatsJson = json['scenarioStats'] as Map<String, dynamic>? ?? {};
    final scenarioStats = <SpeakingScenario, int>{};
    for (final scenario in SpeakingScenario.values) {
      scenarioStats[scenario] = scenarioStatsJson[scenario.name] as int? ?? 0;
    }

    final difficultyStatsJson = json['difficultyStats'] as Map<String, dynamic>? ?? {};
    final difficultyStats = <SpeakingDifficulty, int>{};
    for (final difficulty in SpeakingDifficulty.values) {
      difficultyStats[difficulty] = difficultyStatsJson[difficulty.name] as int? ?? 0;
    }

    return SpeakingStats(
      totalSessions: json['totalSessions'] as int,
      totalMinutes: json['totalMinutes'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      scenarioStats: scenarioStats,
      difficultyStats: difficultyStats,
      progressData: (json['progressData'] as List<dynamic>? ?? [])
          .map((e) => SpeakingProgressData.fromJson(e as Map<String, dynamic>))
          .toList(),
      skillAnalysis: SpeakingSkillAnalysis.fromJson(
        json['skillAnalysis'] as Map<String, dynamic>,
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final scenarioStatsJson = <String, int>{};
    for (final entry in scenarioStats.entries) {
      scenarioStatsJson[entry.key.name] = entry.value;
    }

    final difficultyStatsJson = <String, int>{};
    for (final entry in difficultyStats.entries) {
      difficultyStatsJson[entry.key.name] = entry.value;
    }

    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'averageScore': averageScore,
      'scenarioStats': scenarioStatsJson,
      'difficultyStats': difficultyStatsJson,
      'progressData': progressData.map((e) => e.toJson()).toList(),
      'skillAnalysis': skillAnalysis.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class SpeakingProgressData {
  final DateTime date;
  final double averageScore;
  final int sessionCount;
  final int totalMinutes;
  final Map<PronunciationCriteria, double> criteriaScores;

  const SpeakingProgressData({
    required this.date,
    required this.averageScore,
    required this.sessionCount,
    required this.totalMinutes,
    required this.criteriaScores,
  });

  factory SpeakingProgressData.fromJson(Map<String, dynamic> json) {
    final criteriaScoresJson = json['criteriaScores'] as Map<String, dynamic>? ?? {};
    final criteriaScores = <PronunciationCriteria, double>{};
    for (final criteria in PronunciationCriteria.values) {
      criteriaScores[criteria] = (criteriaScoresJson[criteria.name] as num?)?.toDouble() ?? 0.0;
    }

    return SpeakingProgressData(
      date: DateTime.parse(json['date'] as String),
      averageScore: (json['averageScore'] as num).toDouble(),
      sessionCount: json['sessionCount'] as int,
      totalMinutes: json['totalMinutes'] as int,
      criteriaScores: criteriaScores,
    );
  }

  Map<String, dynamic> toJson() {
    final criteriaScoresJson = <String, double>{};
    for (final entry in criteriaScores.entries) {
      criteriaScoresJson[entry.key.name] = entry.value;
    }

    return {
      'date': date.toIso8601String(),
      'averageScore': averageScore,
      'sessionCount': sessionCount,
      'totalMinutes': totalMinutes,
      'criteriaScores': criteriaScoresJson,
    };
  }
}

class SpeakingSkillAnalysis {
  final Map<PronunciationCriteria, double> criteriaScores;
  final Map<String, int> commonErrors;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final double improvementRate; // 改进速度
  final DateTime lastAnalyzed;

  const SpeakingSkillAnalysis({
    required this.criteriaScores,
    required this.commonErrors,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.improvementRate,
    required this.lastAnalyzed,
  });

  factory SpeakingSkillAnalysis.fromJson(Map<String, dynamic> json) {
    final criteriaScoresJson = json['criteriaScores'] as Map<String, dynamic>? ?? {};
    final criteriaScores = <PronunciationCriteria, double>{};
    for (final criteria in PronunciationCriteria.values) {
      criteriaScores[criteria] = (criteriaScoresJson[criteria.name] as num?)?.toDouble() ?? 0.0;
    }

    return SpeakingSkillAnalysis(
      criteriaScores: criteriaScores,
      commonErrors: Map<String, int>.from(json['commonErrors'] ?? {}),
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      improvementRate: (json['improvementRate'] as num).toDouble(),
      lastAnalyzed: DateTime.parse(json['lastAnalyzed'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final criteriaScoresJson = <String, double>{};
    for (final entry in criteriaScores.entries) {
      criteriaScoresJson[entry.key.name] = entry.value;
    }

    return {
      'criteriaScores': criteriaScoresJson,
      'commonErrors': commonErrors,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations,
      'improvementRate': improvementRate,
      'lastAnalyzed': lastAnalyzed.toIso8601String(),
    };
  }

  String get overallLevel {
    final averageScore = criteriaScores.values.reduce((a, b) => a + b) / criteriaScores.length;
    if (averageScore >= 90) return '优秀';
    if (averageScore >= 80) return '良好';
    if (averageScore >= 70) return '中等';
    if (averageScore >= 60) return '及格';
    return '需要改进';
  }

  PronunciationCriteria get strongestSkill {
    return criteriaScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  PronunciationCriteria get weakestSkill {
    return criteriaScores.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }
}