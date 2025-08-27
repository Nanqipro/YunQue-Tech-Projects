class WordModel {
  final String id;
  final String word;
  final String pronunciation;
  final String phonetic;
  final List<String> meanings;
  final List<String> examples;
  final String audioUrl;
  final String difficulty; // easy, medium, hard
  final List<String> tags;
  final DateTime createdAt;
  
  const WordModel({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.phonetic,
    required this.meanings,
    required this.examples,
    this.audioUrl = '',
    this.difficulty = 'medium',
    this.tags = const [],
    required this.createdAt,
  });
  
  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      phonetic: json['phonetic'] ?? '',
      meanings: List<String>.from(json['meanings'] ?? []),
      examples: List<String>.from(json['examples'] ?? []),
      audioUrl: json['audioUrl'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'pronunciation': pronunciation,
      'phonetic': phonetic,
      'meanings': meanings,
      'examples': examples,
      'audioUrl': audioUrl,
      'difficulty': difficulty,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class WordBookModel {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final int totalWords;
  final int learnedWords;
  final String category; // toefl, ielts, cet6, daily, business
  final String difficulty;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const WordBookModel({
    required this.id,
    required this.name,
    required this.description,
    this.coverImage = '',
    required this.totalWords,
    this.learnedWords = 0,
    required this.category,
    this.difficulty = 'medium',
    required this.createdAt,
    required this.updatedAt,
  });
  
  double get progress => totalWords > 0 ? learnedWords / totalWords : 0.0;
  
  factory WordBookModel.fromJson(Map<String, dynamic> json) {
    return WordBookModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['coverImage'] ?? '',
      totalWords: json['totalWords'] ?? 0,
      learnedWords: json['learnedWords'] ?? 0,
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'totalWords': totalWords,
      'learnedWords': learnedWords,
      'category': category,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}