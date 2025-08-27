// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listening_exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListeningQuestion _$ListeningQuestionFromJson(Map<String, dynamic> json) =>
    ListeningQuestion(
      id: json['id'] as String,
      type: $enumDecode(_$ListeningQuestionTypeEnumMap, json['type']),
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
      timeStart: (json['timeStart'] as num).toInt(),
      timeEnd: (json['timeEnd'] as num).toInt(),
      points: (json['points'] as num).toInt(),
    );

Map<String, dynamic> _$ListeningQuestionToJson(ListeningQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ListeningQuestionTypeEnumMap[instance.type]!,
      'question': instance.question,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation,
      'timeStart': instance.timeStart,
      'timeEnd': instance.timeEnd,
      'points': instance.points,
    };

const _$ListeningQuestionTypeEnumMap = {
  ListeningQuestionType.multipleChoice: 'multiple_choice',
  ListeningQuestionType.trueFalse: 'true_false',
  ListeningQuestionType.fillBlank: 'fill_blank',
  ListeningQuestionType.shortAnswer: 'short_answer',
  ListeningQuestionType.matching: 'matching',
};

ListeningExercise _$ListeningExerciseFromJson(Map<String, dynamic> json) =>
    ListeningExercise(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ListeningExerciseTypeEnumMap, json['type']),
      difficulty: $enumDecode(_$ListeningDifficultyEnumMap, json['difficulty']),
      audioUrl: json['audioUrl'] as String,
      duration: (json['duration'] as num).toInt(),
      transcript: json['transcript'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => ListeningQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      thumbnailUrl: json['thumbnailUrl'] as String,
      totalPoints: (json['totalPoints'] as num).toInt(),
      passingScore: (json['passingScore'] as num).toDouble(),
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      isPublic: json['isPublic'] as bool,
      playCount: (json['playCount'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ListeningExerciseToJson(ListeningExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$ListeningExerciseTypeEnumMap[instance.type]!,
      'difficulty': _$ListeningDifficultyEnumMap[instance.difficulty]!,
      'audioUrl': instance.audioUrl,
      'duration': instance.duration,
      'transcript': instance.transcript,
      'questions': instance.questions,
      'tags': instance.tags,
      'thumbnailUrl': instance.thumbnailUrl,
      'totalPoints': instance.totalPoints,
      'passingScore': instance.passingScore,
      'creatorId': instance.creatorId,
      'creatorName': instance.creatorName,
      'isPublic': instance.isPublic,
      'playCount': instance.playCount,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ListeningExerciseTypeEnumMap = {
  ListeningExerciseType.conversation: 'conversation',
  ListeningExerciseType.lecture: 'lecture',
  ListeningExerciseType.news: 'news',
  ListeningExerciseType.story: 'story',
  ListeningExerciseType.interview: 'interview',
  ListeningExerciseType.dialogue: 'dialogue',
};

const _$ListeningDifficultyEnumMap = {
  ListeningDifficulty.beginner: 'beginner',
  ListeningDifficulty.elementary: 'elementary',
  ListeningDifficulty.intermediate: 'intermediate',
  ListeningDifficulty.advanced: 'advanced',
  ListeningDifficulty.expert: 'expert',
};

ListeningExerciseResult _$ListeningExerciseResultFromJson(
        Map<String, dynamic> json) =>
    ListeningExerciseResult(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      userId: json['userId'] as String,
      userAnswers: (json['userAnswers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctAnswers: (json['correctAnswers'] as List<dynamic>)
          .map((e) => e as bool)
          .toList(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctCount: (json['correctCount'] as num).toInt(),
      score: (json['score'] as num).toDouble(),
      timeSpent: (json['timeSpent'] as num).toInt(),
      playCount: (json['playCount'] as num).toInt(),
      isPassed: json['isPassed'] as bool,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$ListeningExerciseResultToJson(
        ListeningExerciseResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'userId': instance.userId,
      'userAnswers': instance.userAnswers,
      'correctAnswers': instance.correctAnswers,
      'totalQuestions': instance.totalQuestions,
      'correctCount': instance.correctCount,
      'score': instance.score,
      'timeSpent': instance.timeSpent,
      'playCount': instance.playCount,
      'isPassed': instance.isPassed,
      'completedAt': instance.completedAt.toIso8601String(),
    };

ListeningStatistics _$ListeningStatisticsFromJson(Map<String, dynamic> json) =>
    ListeningStatistics(
      userId: json['userId'] as String,
      totalExercises: (json['totalExercises'] as num).toInt(),
      completedExercises: (json['completedExercises'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      averageScore: (json['averageScore'] as num).toDouble(),
      totalTimeSpent: (json['totalTimeSpent'] as num).toInt(),
      totalPlayCount: (json['totalPlayCount'] as num).toInt(),
      difficultyStats: (json['difficultyStats'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$ListeningDifficultyEnumMap, k), (e as num).toInt()),
      ),
      typeStats: (json['typeStats'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$ListeningExerciseTypeEnumMap, k), (e as num).toInt()),
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$ListeningStatisticsToJson(
        ListeningStatistics instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalExercises': instance.totalExercises,
      'completedExercises': instance.completedExercises,
      'totalQuestions': instance.totalQuestions,
      'correctAnswers': instance.correctAnswers,
      'averageScore': instance.averageScore,
      'totalTimeSpent': instance.totalTimeSpent,
      'totalPlayCount': instance.totalPlayCount,
      'difficultyStats': instance.difficultyStats
          .map((k, e) => MapEntry(_$ListeningDifficultyEnumMap[k]!, e)),
      'typeStats': instance.typeStats
          .map((k, e) => MapEntry(_$ListeningExerciseTypeEnumMap[k]!, e)),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
