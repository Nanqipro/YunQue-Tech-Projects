import 'package:json_annotation/json_annotation.dart';
import 'word_model.dart';

part 'vocabulary_book_model.g.dart';

/// 词汇书类型
enum VocabularyBookType {
  @JsonValue('system')
  system, // 系统词汇书
  @JsonValue('custom')
  custom, // 用户自定义词汇书
  @JsonValue('shared')
  shared, // 共享词汇书
}

/// 词汇书难度
enum VocabularyBookDifficulty {
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

/// 词汇书模型
@JsonSerializable()
class VocabularyBook {
  /// 词汇书ID
  final String id;
  
  /// 词汇书名称
  final String name;
  
  /// 词汇书描述
  final String? description;
  
  /// 词汇书类型
  final VocabularyBookType type;
  
  /// 难度等级
  final VocabularyBookDifficulty difficulty;
  
  /// 封面图片URL
  final String? coverImageUrl;
  
  /// 单词总数
  final int totalWords;
  
  /// 创建者ID
  final String? creatorId;
  
  /// 创建者名称
  final String? creatorName;
  
  /// 是否公开
  final bool isPublic;
  
  /// 标签列表
  final List<String> tags;
  
  /// 分类
  final String? category;
  
  /// 适用等级
  final List<String> targetLevels;
  
  /// 预计学习天数
  final int estimatedDays;
  
  /// 每日学习单词数
  final int dailyWordCount;
  
  /// 下载次数
  final int downloadCount;
  
  /// 评分 (1-5)
  final double rating;
  
  /// 评价数量
  final int reviewCount;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;

  const VocabularyBook({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.difficulty,
    this.coverImageUrl,
    required this.totalWords,
    this.creatorId,
    this.creatorName,
    this.isPublic = false,
    this.tags = const [],
    this.category,
    this.targetLevels = const [],
    this.estimatedDays = 30,
    this.dailyWordCount = 20,
    this.downloadCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabularyBook.fromJson(Map<String, dynamic> json) => _$VocabularyBookFromJson(json);
  Map<String, dynamic> toJson() => _$VocabularyBookToJson(this);

  VocabularyBook copyWith({
    String? id,
    String? name,
    String? description,
    VocabularyBookType? type,
    VocabularyBookDifficulty? difficulty,
    String? coverImageUrl,
    int? totalWords,
    String? creatorId,
    String? creatorName,
    bool? isPublic,
    List<String>? tags,
    String? category,
    List<String>? targetLevels,
    int? estimatedDays,
    int? dailyWordCount,
    int? downloadCount,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VocabularyBook(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      totalWords: totalWords ?? this.totalWords,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      targetLevels: targetLevels ?? this.targetLevels,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      dailyWordCount: dailyWordCount ?? this.dailyWordCount,
      downloadCount: downloadCount ?? this.downloadCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 用户词汇书学习进度
@JsonSerializable()
class UserVocabularyBookProgress {
  /// 进度ID
  final String id;
  
  /// 用户ID
  final String userId;
  
  /// 词汇书ID
  final String vocabularyBookId;
  
  /// 已学习单词数
  final int learnedWords;
  
  /// 已掌握单词数
  final int masteredWords;
  
  /// 学习进度百分比 (0-100)
  final double progressPercentage;
  
  /// 连续学习天数
  final int streakDays;
  
  /// 总学习天数
  final int totalStudyDays;
  
  /// 平均每日学习单词数
  final double averageDailyWords;
  
  /// 预计完成时间
  final DateTime? estimatedCompletionDate;
  
  /// 是否已完成
  final bool isCompleted;
  
  /// 完成时间
  final DateTime? completedAt;
  
  /// 开始学习时间
  final DateTime startedAt;
  
  /// 最后学习时间
  final DateTime lastStudiedAt;

  const UserVocabularyBookProgress({
    required this.id,
    required this.userId,
    required this.vocabularyBookId,
    this.learnedWords = 0,
    this.masteredWords = 0,
    this.progressPercentage = 0.0,
    this.streakDays = 0,
    this.totalStudyDays = 0,
    this.averageDailyWords = 0.0,
    this.estimatedCompletionDate,
    this.isCompleted = false,
    this.completedAt,
    required this.startedAt,
    required this.lastStudiedAt,
  });

  factory UserVocabularyBookProgress.fromJson(Map<String, dynamic> json) => _$UserVocabularyBookProgressFromJson(json);
  Map<String, dynamic> toJson() => _$UserVocabularyBookProgressToJson(this);

  UserVocabularyBookProgress copyWith({
    String? id,
    String? userId,
    String? vocabularyBookId,
    int? learnedWords,
    int? masteredWords,
    double? progressPercentage,
    int? streakDays,
    int? totalStudyDays,
    double? averageDailyWords,
    DateTime? estimatedCompletionDate,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? startedAt,
    DateTime? lastStudiedAt,
  }) {
    return UserVocabularyBookProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vocabularyBookId: vocabularyBookId ?? this.vocabularyBookId,
      learnedWords: learnedWords ?? this.learnedWords,
      masteredWords: masteredWords ?? this.masteredWords,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      streakDays: streakDays ?? this.streakDays,
      totalStudyDays: totalStudyDays ?? this.totalStudyDays,
      averageDailyWords: averageDailyWords ?? this.averageDailyWords,
      estimatedCompletionDate: estimatedCompletionDate ?? this.estimatedCompletionDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      startedAt: startedAt ?? this.startedAt,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
    );
  }
}

/// 词汇书单词关联
@JsonSerializable()
class VocabularyBookWord {
  /// 关联ID
  final String id;
  
  /// 词汇书ID
  final String vocabularyBookId;
  
  /// 单词ID
  final String wordId;
  
  /// 在词汇书中的顺序
  final int order;
  
  /// 单词信息
  final Word? word;
  
  /// 添加时间
  final DateTime addedAt;

  const VocabularyBookWord({
    required this.id,
    required this.vocabularyBookId,
    required this.wordId,
    required this.order,
    this.word,
    required this.addedAt,
  });

  factory VocabularyBookWord.fromJson(Map<String, dynamic> json) => _$VocabularyBookWordFromJson(json);
  Map<String, dynamic> toJson() => _$VocabularyBookWordToJson(this);

  VocabularyBookWord copyWith({
    String? id,
    String? vocabularyBookId,
    String? wordId,
    int? order,
    Word? word,
    DateTime? addedAt,
  }) {
    return VocabularyBookWord(
      id: id ?? this.id,
      vocabularyBookId: vocabularyBookId ?? this.vocabularyBookId,
      wordId: wordId ?? this.wordId,
      order: order ?? this.order,
      word: word ?? this.word,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}