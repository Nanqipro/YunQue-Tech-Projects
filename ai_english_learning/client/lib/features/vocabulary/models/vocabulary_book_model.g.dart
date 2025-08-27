// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VocabularyBook _$VocabularyBookFromJson(Map<String, dynamic> json) =>
    VocabularyBook(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: $enumDecode(_$VocabularyBookTypeEnumMap, json['type']),
      difficulty:
          $enumDecode(_$VocabularyBookDifficultyEnumMap, json['difficulty']),
      coverImageUrl: json['coverImageUrl'] as String?,
      totalWords: (json['totalWords'] as num).toInt(),
      creatorId: json['creatorId'] as String?,
      creatorName: json['creatorName'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      category: json['category'] as String?,
      targetLevels: (json['targetLevels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      estimatedDays: (json['estimatedDays'] as num?)?.toInt() ?? 30,
      dailyWordCount: (json['dailyWordCount'] as num?)?.toInt() ?? 20,
      downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VocabularyBookToJson(VocabularyBook instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$VocabularyBookTypeEnumMap[instance.type]!,
      'difficulty': _$VocabularyBookDifficultyEnumMap[instance.difficulty]!,
      'coverImageUrl': instance.coverImageUrl,
      'totalWords': instance.totalWords,
      'creatorId': instance.creatorId,
      'creatorName': instance.creatorName,
      'isPublic': instance.isPublic,
      'tags': instance.tags,
      'category': instance.category,
      'targetLevels': instance.targetLevels,
      'estimatedDays': instance.estimatedDays,
      'dailyWordCount': instance.dailyWordCount,
      'downloadCount': instance.downloadCount,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$VocabularyBookTypeEnumMap = {
  VocabularyBookType.system: 'system',
  VocabularyBookType.custom: 'custom',
  VocabularyBookType.shared: 'shared',
};

const _$VocabularyBookDifficultyEnumMap = {
  VocabularyBookDifficulty.beginner: 'beginner',
  VocabularyBookDifficulty.elementary: 'elementary',
  VocabularyBookDifficulty.intermediate: 'intermediate',
  VocabularyBookDifficulty.advanced: 'advanced',
  VocabularyBookDifficulty.expert: 'expert',
};

UserVocabularyBookProgress _$UserVocabularyBookProgressFromJson(
        Map<String, dynamic> json) =>
    UserVocabularyBookProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vocabularyBookId: json['vocabularyBookId'] as String,
      learnedWords: (json['learnedWords'] as num?)?.toInt() ?? 0,
      masteredWords: (json['masteredWords'] as num?)?.toInt() ?? 0,
      progressPercentage:
          (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      totalStudyDays: (json['totalStudyDays'] as num?)?.toInt() ?? 0,
      averageDailyWords: (json['averageDailyWords'] as num?)?.toDouble() ?? 0.0,
      estimatedCompletionDate: json['estimatedCompletionDate'] == null
          ? null
          : DateTime.parse(json['estimatedCompletionDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      lastStudiedAt: DateTime.parse(json['lastStudiedAt'] as String),
    );

Map<String, dynamic> _$UserVocabularyBookProgressToJson(
        UserVocabularyBookProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'vocabularyBookId': instance.vocabularyBookId,
      'learnedWords': instance.learnedWords,
      'masteredWords': instance.masteredWords,
      'progressPercentage': instance.progressPercentage,
      'streakDays': instance.streakDays,
      'totalStudyDays': instance.totalStudyDays,
      'averageDailyWords': instance.averageDailyWords,
      'estimatedCompletionDate':
          instance.estimatedCompletionDate?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'startedAt': instance.startedAt.toIso8601String(),
      'lastStudiedAt': instance.lastStudiedAt.toIso8601String(),
    };

VocabularyBookWord _$VocabularyBookWordFromJson(Map<String, dynamic> json) =>
    VocabularyBookWord(
      id: json['id'] as String,
      vocabularyBookId: json['vocabularyBookId'] as String,
      wordId: json['wordId'] as String,
      order: (json['order'] as num).toInt(),
      word: json['word'] == null
          ? null
          : Word.fromJson(json['word'] as Map<String, dynamic>),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$VocabularyBookWordToJson(VocabularyBookWord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vocabularyBookId': instance.vocabularyBookId,
      'wordId': instance.wordId,
      'order': instance.order,
      'word': instance.word,
      'addedAt': instance.addedAt.toIso8601String(),
    };
