class WritingTask {
  final String id;
  final String title;
  final String description;
  final WritingType type;
  final WritingDifficulty difficulty;
  final int timeLimit; // 分钟
  final int wordLimit;
  final List<String> keywords;
  final List<String> requirements;
  final String? prompt;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WritingTask({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.timeLimit,
    required this.wordLimit,
    required this.keywords,
    required this.requirements,
    this.prompt,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory WritingTask.fromJson(Map<String, dynamic> json) {
    return WritingTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: WritingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WritingType.essay,
      ),
      difficulty: WritingDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => WritingDifficulty.intermediate,
      ),
      timeLimit: json['timeLimit'] as int,
      wordLimit: json['wordLimit'] as int,
      keywords: List<String>.from(json['keywords'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      prompt: json['prompt'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'difficulty': difficulty.name,
      'timeLimit': timeLimit,
      'wordLimit': wordLimit,
      'keywords': keywords,
      'requirements': requirements,
      'prompt': prompt,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  WritingTask copyWith({
    String? id,
    String? title,
    String? description,
    WritingType? type,
    WritingDifficulty? difficulty,
    int? timeLimit,
    int? wordLimit,
    List<String>? keywords,
    List<String>? requirements,
    String? prompt,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WritingTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      timeLimit: timeLimit ?? this.timeLimit,
      wordLimit: wordLimit ?? this.wordLimit,
      keywords: keywords ?? this.keywords,
      requirements: requirements ?? this.requirements,
      prompt: prompt ?? this.prompt,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum WritingType {
  essay,
  letter,
  email,
  report,
  story,
  review,
  article,
  diary,
  description,
  argument,
}

enum WritingDifficulty {
  beginner,
  elementary,
  intermediate,
  upperIntermediate,
  advanced,
}

extension WritingTypeExtension on WritingType {
  String get displayName {
    switch (this) {
      case WritingType.essay:
        return '议论文';
      case WritingType.letter:
        return '书信';
      case WritingType.email:
        return '邮件';
      case WritingType.report:
        return '报告';
      case WritingType.story:
        return '故事';
      case WritingType.review:
        return '评论';
      case WritingType.article:
        return '文章';
      case WritingType.diary:
        return '日记';
      case WritingType.description:
        return '描述文';
      case WritingType.argument:
        return '辩论文';
    }
  }
}

extension WritingDifficultyExtension on WritingDifficulty {
  String get displayName {
    switch (this) {
      case WritingDifficulty.beginner:
        return '初级';
      case WritingDifficulty.elementary:
        return '基础';
      case WritingDifficulty.intermediate:
        return '中级';
      case WritingDifficulty.upperIntermediate:
        return '中高级';
      case WritingDifficulty.advanced:
        return '高级';
    }
  }

  int get level {
    switch (this) {
      case WritingDifficulty.beginner:
        return 1;
      case WritingDifficulty.elementary:
        return 2;
      case WritingDifficulty.intermediate:
        return 3;
      case WritingDifficulty.upperIntermediate:
        return 4;
      case WritingDifficulty.advanced:
        return 5;
    }
  }
}