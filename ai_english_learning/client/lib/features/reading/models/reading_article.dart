class ReadingArticle {
  final String id;
  final String title;
  final String content;
  final String category;
  final String difficulty;
  final int wordCount;
  final int estimatedReadingTime; // in minutes
  final List<String> tags;
  final String source;
  final DateTime publishDate;
  final bool isCompleted;
  final double? comprehensionScore;
  final int? readingTime; // actual reading time in seconds

  const ReadingArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.difficulty,
    required this.wordCount,
    required this.estimatedReadingTime,
    required this.tags,
    required this.source,
    required this.publishDate,
    this.isCompleted = false,
    this.comprehensionScore,
    this.readingTime,
  });

  factory ReadingArticle.fromJson(Map<String, dynamic> json) {
    return ReadingArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      wordCount: json['wordCount'] as int,
      estimatedReadingTime: json['estimatedReadingTime'] as int,
      tags: List<String>.from(json['tags'] as List),
      source: json['source'] as String,
      publishDate: DateTime.parse(json['publishDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      comprehensionScore: json['comprehensionScore'] as double?,
      readingTime: json['readingTime'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'difficulty': difficulty,
      'wordCount': wordCount,
      'estimatedReadingTime': estimatedReadingTime,
      'tags': tags,
      'source': source,
      'publishDate': publishDate.toIso8601String(),
      'isCompleted': isCompleted,
      'comprehensionScore': comprehensionScore,
      'readingTime': readingTime,
    };
  }

  ReadingArticle copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? difficulty,
    int? wordCount,
    int? estimatedReadingTime,
    List<String>? tags,
    String? source,
    DateTime? publishDate,
    bool? isCompleted,
    double? comprehensionScore,
    int? readingTime,
  }) {
    return ReadingArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      wordCount: wordCount ?? this.wordCount,
      estimatedReadingTime: estimatedReadingTime ?? this.estimatedReadingTime,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      publishDate: publishDate ?? this.publishDate,
      isCompleted: isCompleted ?? this.isCompleted,
      comprehensionScore: comprehensionScore ?? this.comprehensionScore,
      readingTime: readingTime ?? this.readingTime,
    );
  }

  String get difficultyLabel {
    switch (difficulty.toLowerCase()) {
      case 'a1':
      case 'a2':
        return '初级';
      case 'b1':
      case 'b2':
        return '中级';
      case 'c1':
      case 'c2':
        return '高级';
      default:
        return '未知';
    }
  }

  String get categoryLabel {
    switch (category.toLowerCase()) {
      case 'cet4':
        return '四级阅读';
      case 'cet6':
        return '六级阅读';
      case 'toefl':
        return '托福阅读';
      case 'ielts':
        return '雅思阅读';
      case 'daily':
        return '日常阅读';
      case 'business':
        return '商务阅读';
      case 'academic':
        return '学术阅读';
      case 'news':
        return '新闻阅读';
      default:
        return category;
    }
  }
}