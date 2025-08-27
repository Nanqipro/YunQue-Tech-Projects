// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySession _$StudySessionFromJson(Map<String, dynamic> json) => StudySession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vocabularyBookId: json['vocabularyBookId'] as String?,
      mode: $enumDecode(_$StudyModeEnumMap, json['mode']),
      targetWordCount: (json['targetWordCount'] as num).toInt(),
      actualWordCount: (json['actualWordCount'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      wrongAnswers: (json['wrongAnswers'] as num?)?.toInt() ?? 0,
      skippedAnswers: (json['skippedAnswers'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      experienceGained: (json['experienceGained'] as num?)?.toInt() ?? 0,
      pointsGained: (json['pointsGained'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StudySessionToJson(StudySession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'vocabularyBookId': instance.vocabularyBookId,
      'mode': _$StudyModeEnumMap[instance.mode]!,
      'targetWordCount': instance.targetWordCount,
      'actualWordCount': instance.actualWordCount,
      'correctAnswers': instance.correctAnswers,
      'wrongAnswers': instance.wrongAnswers,
      'skippedAnswers': instance.skippedAnswers,
      'durationSeconds': instance.durationSeconds,
      'accuracy': instance.accuracy,
      'experienceGained': instance.experienceGained,
      'pointsGained': instance.pointsGained,
      'isCompleted': instance.isCompleted,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$StudyModeEnumMap = {
  StudyMode.newWords: 'new_words',
  StudyMode.review: 'review',
  StudyMode.mixed: 'mixed',
  StudyMode.test: 'test',
  StudyMode.quickReview: 'quick_review',
};

WordExerciseRecord _$WordExerciseRecordFromJson(Map<String, dynamic> json) =>
    WordExerciseRecord(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      wordId: json['wordId'] as String,
      exerciseType: $enumDecode(_$ExerciseTypeEnumMap, json['exerciseType']),
      userAnswer: json['userAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      result: $enumDecode(_$AnswerResultEnumMap, json['result']),
      responseTimeSeconds: (json['responseTimeSeconds'] as num).toInt(),
      hintCount: (json['hintCount'] as num?)?.toInt() ?? 0,
      word: json['word'] == null
          ? null
          : Word.fromJson(json['word'] as Map<String, dynamic>),
      answeredAt: DateTime.parse(json['answeredAt'] as String),
    );

Map<String, dynamic> _$WordExerciseRecordToJson(WordExerciseRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'wordId': instance.wordId,
      'exerciseType': _$ExerciseTypeEnumMap[instance.exerciseType]!,
      'userAnswer': instance.userAnswer,
      'correctAnswer': instance.correctAnswer,
      'result': _$AnswerResultEnumMap[instance.result]!,
      'responseTimeSeconds': instance.responseTimeSeconds,
      'hintCount': instance.hintCount,
      'word': instance.word,
      'answeredAt': instance.answeredAt.toIso8601String(),
    };

const _$ExerciseTypeEnumMap = {
  ExerciseType.wordMeaning: 'word_meaning',
  ExerciseType.meaningWord: 'meaning_word',
  ExerciseType.spelling: 'spelling',
  ExerciseType.listening: 'listening',
  ExerciseType.sentenceCompletion: 'sentence_completion',
  ExerciseType.synonymAntonym: 'synonym_antonym',
  ExerciseType.imageWord: 'image_word',
};

const _$AnswerResultEnumMap = {
  AnswerResult.correct: 'correct',
  AnswerResult.wrong: 'wrong',
  AnswerResult.skipped: 'skipped',
};

StudyStatistics _$StudyStatisticsFromJson(Map<String, dynamic> json) =>
    StudyStatistics(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 0,
      wordsStudied: (json['wordsStudied'] as num?)?.toInt() ?? 0,
      newWordsLearned: (json['newWordsLearned'] as num?)?.toInt() ?? 0,
      wordsReviewed: (json['wordsReviewed'] as num?)?.toInt() ?? 0,
      wordsMastered: (json['wordsMastered'] as num?)?.toInt() ?? 0,
      totalStudyTimeSeconds:
          (json['totalStudyTimeSeconds'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      wrongAnswers: (json['wrongAnswers'] as num?)?.toInt() ?? 0,
      averageAccuracy: (json['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      experienceGained: (json['experienceGained'] as num?)?.toInt() ?? 0,
      pointsGained: (json['pointsGained'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StudyStatisticsToJson(StudyStatistics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'sessionCount': instance.sessionCount,
      'wordsStudied': instance.wordsStudied,
      'newWordsLearned': instance.newWordsLearned,
      'wordsReviewed': instance.wordsReviewed,
      'wordsMastered': instance.wordsMastered,
      'totalStudyTimeSeconds': instance.totalStudyTimeSeconds,
      'correctAnswers': instance.correctAnswers,
      'wrongAnswers': instance.wrongAnswers,
      'averageAccuracy': instance.averageAccuracy,
      'experienceGained': instance.experienceGained,
      'pointsGained': instance.pointsGained,
      'streakDays': instance.streakDays,
    };
