/// 词汇模型
class VocabularyModel {
  final int wordId;
  final String word;
  final String pronunciation;
  final String phonetic;
  final List<WordMeaning> meanings;
  final String? etymology;
  final List<String> examples;
  final String? imageUrl;
  final String? audioUrl;
  final int difficulty;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const VocabularyModel({
    required this.wordId,
    required this.word,
    required this.pronunciation,
    required this.phonetic,
    required this.meanings,
    this.etymology,
    required this.examples,
    this.imageUrl,
    this.audioUrl,
    required this.difficulty,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      wordId: json['word_id'] as int,
      word: json['word'] as String,
      pronunciation: json['pronunciation'] as String,
      phonetic: json['phonetic'] as String,
      meanings: (json['meanings'] as List)
          .map((e) => WordMeaning.fromJson(e as Map<String, dynamic>))
          .toList(),
      etymology: json['etymology'] as String?,
      examples: (json['examples'] as List).cast<String>(),
      imageUrl: json['image_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      difficulty: json['difficulty'] as int,
      tags: (json['tags'] as List).cast<String>(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'word_id': wordId,
      'word': word,
      'pronunciation': pronunciation,
      'phonetic': phonetic,
      'meanings': meanings.map((e) => e.toJson()).toList(),
      'etymology': etymology,
      'examples': examples,
      'image_url': imageUrl,
      'audio_url': audioUrl,
      'difficulty': difficulty,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  VocabularyModel copyWith({
    int? wordId,
    String? word,
    String? pronunciation,
    String? phonetic,
    List<WordMeaning>? meanings,
    String? etymology,
    List<String>? examples,
    String? imageUrl,
    String? audioUrl,
    int? difficulty,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VocabularyModel(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      pronunciation: pronunciation ?? this.pronunciation,
      phonetic: phonetic ?? this.phonetic,
      meanings: meanings ?? this.meanings,
      etymology: etymology ?? this.etymology,
      examples: examples ?? this.examples,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 词汇含义模型
class WordMeaning {
  final String partOfSpeech;
  final String definition;
  final String? chineseDefinition;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<String> examples;
  
  const WordMeaning({
    required this.partOfSpeech,
    required this.definition,
    this.chineseDefinition,
    required this.synonyms,
    required this.antonyms,
    required this.examples,
  });
  
  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    return WordMeaning(
      partOfSpeech: json['part_of_speech'] as String,
      definition: json['definition'] as String,
      chineseDefinition: json['chinese_definition'] as String?,
      synonyms: (json['synonyms'] as List).cast<String>(),
      antonyms: (json['antonyms'] as List).cast<String>(),
      examples: (json['examples'] as List).cast<String>(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'part_of_speech': partOfSpeech,
      'definition': definition,
      'chinese_definition': chineseDefinition,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'examples': examples,
    };
  }
}

/// 用户词汇学习记录模型
class UserVocabularyModel {
  final int userWordId;
  final int userId;
  final int wordId;
  final VocabularyModel? vocabulary;
  final LearningStatus status;
  final int reviewCount;
  final int correctCount;
  final int incorrectCount;
  final double masteryLevel;
  final DateTime? lastReviewAt;
  final DateTime? nextReviewAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const UserVocabularyModel({
    required this.userWordId,
    required this.userId,
    required this.wordId,
    this.vocabulary,
    required this.status,
    required this.reviewCount,
    required this.correctCount,
    required this.incorrectCount,
    required this.masteryLevel,
    this.lastReviewAt,
    this.nextReviewAt,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory UserVocabularyModel.fromJson(Map<String, dynamic> json) {
    return UserVocabularyModel(
      userWordId: json['user_word_id'] as int,
      userId: json['user_id'] as int,
      wordId: json['word_id'] as int,
      vocabulary: json['vocabulary'] != null
          ? VocabularyModel.fromJson(json['vocabulary'] as Map<String, dynamic>)
          : null,
      status: LearningStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LearningStatus.new_word,
      ),
      reviewCount: json['review_count'] as int,
      correctCount: json['correct_count'] as int,
      incorrectCount: json['incorrect_count'] as int,
      masteryLevel: (json['mastery_level'] as num).toDouble(),
      lastReviewAt: json['last_review_at'] != null
          ? DateTime.parse(json['last_review_at'] as String)
          : null,
      nextReviewAt: json['next_review_at'] != null
          ? DateTime.parse(json['next_review_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_word_id': userWordId,
      'user_id': userId,
      'word_id': wordId,
      'vocabulary': vocabulary?.toJson(),
      'status': status.name,
      'review_count': reviewCount,
      'correct_count': correctCount,
      'incorrect_count': incorrectCount,
      'mastery_level': masteryLevel,
      'last_review_at': lastReviewAt?.toIso8601String(),
      'next_review_at': nextReviewAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// 学习状态枚举
enum LearningStatus {
  new_word('new_word', '新单词'),
  learning('learning', '学习中'),
  reviewing('reviewing', '复习中'),
  mastered('mastered', '已掌握'),
  forgotten('forgotten', '已遗忘');
  
  const LearningStatus(this.value, this.label);
  
  final String value;
  final String label;
}

/// 词库模型
class VocabularyBookModel {
  final int bookId;
  final String name;
  final String description;
  final String category;
  final String level;
  final int totalWords;
  final String? coverImage;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const VocabularyBookModel({
    required this.bookId,
    required this.name,
    required this.description,
    required this.category,
    required this.level,
    required this.totalWords,
    this.coverImage,
    required this.isPremium,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory VocabularyBookModel.fromJson(Map<String, dynamic> json) {
    return VocabularyBookModel(
      bookId: json['book_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      totalWords: json['total_words'] as int,
      coverImage: json['cover_image'] as String?,
      isPremium: json['is_premium'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'name': name,
      'description': description,
      'category': category,
      'level': level,
      'total_words': totalWords,
      'cover_image': coverImage,
      'is_premium': isPremium,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}