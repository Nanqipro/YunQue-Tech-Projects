class User {
  final int? id;
  final String username;
  final String email;
  final int level;
  final int score;

  User({
    this.id,
    required this.username,
    required this.email,
    this.level = 1,
    this.score = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'level': level,
      'score': score,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      level: map['level'],
      score: map['score'],
    );
  }
}