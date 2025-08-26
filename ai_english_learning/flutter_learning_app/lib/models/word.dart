class Word {
  final int? id;
  final String english;
  final String chinese;
  final String pronunciation;
  final String example;
  final int difficulty;
  bool isLearned;

  Word({
    this.id,
    required this.english,
    required this.chinese,
    required this.pronunciation,
    required this.example,
    this.difficulty = 1,
    this.isLearned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'chinese': chinese,
      'pronunciation': pronunciation,
      'example': example,
      'difficulty': difficulty,
      'isLearned': isLearned ? 1 : 0,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      english: map['english'],
      chinese: map['chinese'],
      pronunciation: map['pronunciation'],
      example: map['example'],
      difficulty: map['difficulty'],
      isLearned: map['isLearned'] == 1,
    );
  }
}