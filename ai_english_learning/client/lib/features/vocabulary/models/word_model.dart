import 'package:json_annotation/json_annotation.dart';

part 'word_model.g.dart';

/// 单词难度等级
enum WordDifficulty {
  @JsonValue('beginner')
  beginner,
  @JsonValue('elementary')
  elementary,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
  @JsonValue('expert')
  expert,
}

/// 单词类型
enum WordType {
  @JsonValue('noun')
  noun,
  @JsonValue('verb')
  verb,
  @JsonValue('adjective')
  adjective,
  @JsonValue('adverb')
  adverb,
  @JsonValue('preposition')
  preposition,
  @JsonValue('conjunction')
  conjunction,
  @JsonValue('interjection')
  interjection,
  @JsonValue('pronoun')
  pronoun,
  @JsonValue('article')
  article,
  @JsonValue('phrase')
  phrase,
}

/// 学习状态
enum LearningStatus {
  @JsonValue('new')
  newWord,
  @JsonValue('learning')
  learning,
  @JsonValue('reviewing')
  reviewing,
  @JsonValue('mastered')
  mastered,
  @JsonValue('forgotten')
  forgotten,
}

/// 单词模型
@JsonSerializable()
class Word {
  /// 单词ID
  final String id;
  
  /// 单词
  final String word;
  
  /// 音标
  final String? phonetic;
  
  /// 音频URL
  final String? audioUrl;
  
  /// 词性和释义列表
  final List<WordDefinition> definitions;
  
  /// 例句列表
  final List<WordExample> examples;
  
  /// 同义词
  final List<String> synonyms;
  
  /// 反义词
  final List<String> antonyms;
  
  /// 词根词缀
  final WordEtymology? etymology;
  
  /// 难度等级
  final WordDifficulty difficulty;
  
  /// 频率等级 (1-5)
  final int frequency;
  
  /// 图片URL
  final String? imageUrl;
  
  /// 记忆技巧
  final String? memoryTip;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;

  const Word({
    required this.id,
    required this.word,
    this.phonetic,
    this.audioUrl,
    required this.definitions,
    this.examples = const [],
    this.synonyms = const [],
    this.antonyms = const [],
    this.etymology,
    required this.difficulty,
    required this.frequency,
    this.imageUrl,
    this.memoryTip,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);

  Word copyWith({
    String? id,
    String? word,
    String? phonetic,
    String? audioUrl,
    List<WordDefinition>? definitions,
    List<WordExample>? examples,
    List<String>? synonyms,
    List<String>? antonyms,
    WordEtymology? etymology,
    WordDifficulty? difficulty,
    int? frequency,
    String? imageUrl,
    String? memoryTip,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      audioUrl: audioUrl ?? this.audioUrl,
      definitions: definitions ?? this.definitions,
      examples: examples ?? this.examples,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      etymology: etymology ?? this.etymology,
      difficulty: difficulty ?? this.difficulty,
      frequency: frequency ?? this.frequency,
      imageUrl: imageUrl ?? this.imageUrl,
      memoryTip: memoryTip ?? this.memoryTip,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 单词释义
@JsonSerializable()
class WordDefinition {
  /// 词性
  final WordType type;
  
  /// 释义
  final String definition;
  
  /// 中文翻译
  final String translation;
  
  /// 使用频率 (1-5)
  final int frequency;

  const WordDefinition({
    required this.type,
    required this.definition,
    required this.translation,
    this.frequency = 3,
  });

  factory WordDefinition.fromJson(Map<String, dynamic> json) => _$WordDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$WordDefinitionToJson(this);

  WordDefinition copyWith({
    WordType? type,
    String? definition,
    String? translation,
    int? frequency,
  }) {
    return WordDefinition(
      type: type ?? this.type,
      definition: definition ?? this.definition,
      translation: translation ?? this.translation,
      frequency: frequency ?? this.frequency,
    );
  }
}

/// 单词例句
@JsonSerializable()
class WordExample {
  /// 例句
  final String sentence;
  
  /// 中文翻译
  final String translation;
  
  /// 音频URL
  final String? audioUrl;
  
  /// 来源
  final String? source;

  const WordExample({
    required this.sentence,
    required this.translation,
    this.audioUrl,
    this.source,
  });

  factory WordExample.fromJson(Map<String, dynamic> json) => _$WordExampleFromJson(json);
  Map<String, dynamic> toJson() => _$WordExampleToJson(this);

  WordExample copyWith({
    String? sentence,
    String? translation,
    String? audioUrl,
    String? source,
  }) {
    return WordExample(
      sentence: sentence ?? this.sentence,
      translation: translation ?? this.translation,
      audioUrl: audioUrl ?? this.audioUrl,
      source: source ?? this.source,
    );
  }
}

/// 词根词缀
@JsonSerializable()
class WordEtymology {
  /// 词根
  final List<String> roots;
  
  /// 前缀
  final List<String> prefixes;
  
  /// 后缀
  final List<String> suffixes;
  
  /// 词源说明
  final String? origin;

  const WordEtymology({
    this.roots = const [],
    this.prefixes = const [],
    this.suffixes = const [],
    this.origin,
  });

  factory WordEtymology.fromJson(Map<String, dynamic> json) => _$WordEtymologyFromJson(json);
  Map<String, dynamic> toJson() => _$WordEtymologyToJson(this);

  WordEtymology copyWith({
    List<String>? roots,
    List<String>? prefixes,
    List<String>? suffixes,
    String? origin,
  }) {
    return WordEtymology(
      roots: roots ?? this.roots,
      prefixes: prefixes ?? this.prefixes,
      suffixes: suffixes ?? this.suffixes,
      origin: origin ?? this.origin,
    );
  }
}

/// 用户单词学习记录
@JsonSerializable()
class UserWordProgress {
  /// 记录ID
  final String id;
  
  /// 用户ID
  final String userId;
  
  /// 单词ID
  final String wordId;
  
  /// 学习状态
  final LearningStatus status;
  
  /// 学习次数
  final int studyCount;
  
  /// 正确次数
  final int correctCount;
  
  /// 错误次数
  final int wrongCount;
  
  /// 熟练度 (0-100)
  final int proficiency;
  
  /// 下次复习时间
  final DateTime? nextReviewAt;
  
  /// 复习间隔 (天)
  final int reviewInterval;
  
  /// 首次学习时间
  final DateTime firstStudiedAt;
  
  /// 最后学习时间
  final DateTime lastStudiedAt;
  
  /// 掌握时间
  final DateTime? masteredAt;

  const UserWordProgress({
    required this.id,
    required this.userId,
    required this.wordId,
    required this.status,
    this.studyCount = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.proficiency = 0,
    this.nextReviewAt,
    this.reviewInterval = 1,
    required this.firstStudiedAt,
    required this.lastStudiedAt,
    this.masteredAt,
  });

  factory UserWordProgress.fromJson(Map<String, dynamic> json) => _$UserWordProgressFromJson(json);
  Map<String, dynamic> toJson() => _$UserWordProgressToJson(this);

  UserWordProgress copyWith({
    String? id,
    String? userId,
    String? wordId,
    LearningStatus? status,
    int? studyCount,
    int? correctCount,
    int? wrongCount,
    int? proficiency,
    DateTime? nextReviewAt,
    int? reviewInterval,
    DateTime? firstStudiedAt,
    DateTime? lastStudiedAt,
    DateTime? masteredAt,
  }) {
    return UserWordProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      wordId: wordId ?? this.wordId,
      status: status ?? this.status,
      studyCount: studyCount ?? this.studyCount,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      proficiency: proficiency ?? this.proficiency,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      reviewInterval: reviewInterval ?? this.reviewInterval,
      firstStudiedAt: firstStudiedAt ?? this.firstStudiedAt,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      masteredAt: masteredAt ?? this.masteredAt,
    );
  }

  /// 计算学习准确率
  double get accuracy {
    if (studyCount == 0) return 0.0;
    return correctCount / studyCount;
  }

  /// 是否需要复习
  bool get needsReview {
    if (nextReviewAt == null) return false;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  /// 是否为新单词
  bool get isNew => status == LearningStatus.newWord;

  /// 是否已掌握
  bool get isMastered => status == LearningStatus.mastered;
}