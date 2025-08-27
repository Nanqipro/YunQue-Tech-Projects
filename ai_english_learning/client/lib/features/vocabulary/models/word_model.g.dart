// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word(
      id: json['id'] as String,
      word: json['word'] as String,
      phonetic: json['phonetic'] as String?,
      audioUrl: json['audioUrl'] as String?,
      definitions: (json['definitions'] as List<dynamic>)
          .map((e) => WordDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => WordExample.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      antonyms: (json['antonyms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      etymology: json['etymology'] == null
          ? null
          : WordEtymology.fromJson(json['etymology'] as Map<String, dynamic>),
      difficulty: $enumDecode(_$WordDifficultyEnumMap, json['difficulty']),
      frequency: (json['frequency'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      memoryTip: json['memoryTip'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'phonetic': instance.phonetic,
      'audioUrl': instance.audioUrl,
      'definitions': instance.definitions,
      'examples': instance.examples,
      'synonyms': instance.synonyms,
      'antonyms': instance.antonyms,
      'etymology': instance.etymology,
      'difficulty': _$WordDifficultyEnumMap[instance.difficulty]!,
      'frequency': instance.frequency,
      'imageUrl': instance.imageUrl,
      'memoryTip': instance.memoryTip,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$WordDifficultyEnumMap = {
  WordDifficulty.beginner: 'beginner',
  WordDifficulty.elementary: 'elementary',
  WordDifficulty.intermediate: 'intermediate',
  WordDifficulty.advanced: 'advanced',
  WordDifficulty.expert: 'expert',
};

WordDefinition _$WordDefinitionFromJson(Map<String, dynamic> json) =>
    WordDefinition(
      type: $enumDecode(_$WordTypeEnumMap, json['type']),
      definition: json['definition'] as String,
      translation: json['translation'] as String,
      frequency: (json['frequency'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$WordDefinitionToJson(WordDefinition instance) =>
    <String, dynamic>{
      'type': _$WordTypeEnumMap[instance.type]!,
      'definition': instance.definition,
      'translation': instance.translation,
      'frequency': instance.frequency,
    };

const _$WordTypeEnumMap = {
  WordType.noun: 'noun',
  WordType.verb: 'verb',
  WordType.adjective: 'adjective',
  WordType.adverb: 'adverb',
  WordType.preposition: 'preposition',
  WordType.conjunction: 'conjunction',
  WordType.interjection: 'interjection',
  WordType.pronoun: 'pronoun',
  WordType.article: 'article',
  WordType.phrase: 'phrase',
};

WordExample _$WordExampleFromJson(Map<String, dynamic> json) => WordExample(
      sentence: json['sentence'] as String,
      translation: json['translation'] as String,
      audioUrl: json['audioUrl'] as String?,
      source: json['source'] as String?,
    );

Map<String, dynamic> _$WordExampleToJson(WordExample instance) =>
    <String, dynamic>{
      'sentence': instance.sentence,
      'translation': instance.translation,
      'audioUrl': instance.audioUrl,
      'source': instance.source,
    };

WordEtymology _$WordEtymologyFromJson(Map<String, dynamic> json) =>
    WordEtymology(
      roots:
          (json['roots'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      prefixes: (json['prefixes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      suffixes: (json['suffixes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      origin: json['origin'] as String?,
    );

Map<String, dynamic> _$WordEtymologyToJson(WordEtymology instance) =>
    <String, dynamic>{
      'roots': instance.roots,
      'prefixes': instance.prefixes,
      'suffixes': instance.suffixes,
      'origin': instance.origin,
    };

UserWordProgress _$UserWordProgressFromJson(Map<String, dynamic> json) =>
    UserWordProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      wordId: json['wordId'] as String,
      status: $enumDecode(_$LearningStatusEnumMap, json['status']),
      studyCount: (json['studyCount'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      proficiency: (json['proficiency'] as num?)?.toInt() ?? 0,
      nextReviewAt: json['nextReviewAt'] == null
          ? null
          : DateTime.parse(json['nextReviewAt'] as String),
      reviewInterval: (json['reviewInterval'] as num?)?.toInt() ?? 1,
      firstStudiedAt: DateTime.parse(json['firstStudiedAt'] as String),
      lastStudiedAt: DateTime.parse(json['lastStudiedAt'] as String),
      masteredAt: json['masteredAt'] == null
          ? null
          : DateTime.parse(json['masteredAt'] as String),
    );

Map<String, dynamic> _$UserWordProgressToJson(UserWordProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'wordId': instance.wordId,
      'status': _$LearningStatusEnumMap[instance.status]!,
      'studyCount': instance.studyCount,
      'correctCount': instance.correctCount,
      'wrongCount': instance.wrongCount,
      'proficiency': instance.proficiency,
      'nextReviewAt': instance.nextReviewAt?.toIso8601String(),
      'reviewInterval': instance.reviewInterval,
      'firstStudiedAt': instance.firstStudiedAt.toIso8601String(),
      'lastStudiedAt': instance.lastStudiedAt.toIso8601String(),
      'masteredAt': instance.masteredAt?.toIso8601String(),
    };

const _$LearningStatusEnumMap = {
  LearningStatus.newWord: 'new',
  LearningStatus.learning: 'learning',
  LearningStatus.reviewing: 'reviewing',
  LearningStatus.mastered: 'mastered',
  LearningStatus.forgotten: 'forgotten',
};
