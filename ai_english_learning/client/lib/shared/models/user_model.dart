import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// 用户模型
@JsonSerializable()
class UserModel {
  @JsonKey(name: 'user_id')
  final int userId;
  
  final String username;
  final String email;
  final String? nickname;
  final String? avatar;
  final String? phone;
  final DateTime? birthday;
  final String? gender;
  final String? bio;
  
  @JsonKey(name: 'learning_level')
  final String learningLevel;
  
  @JsonKey(name: 'target_language')
  final String targetLanguage;
  
  @JsonKey(name: 'native_language')
  final String nativeLanguage;
  
  @JsonKey(name: 'daily_goal')
  final int dailyGoal;
  
  @JsonKey(name: 'study_streak')
  final int studyStreak;
  
  @JsonKey(name: 'total_study_days')
  final int totalStudyDays;
  
  @JsonKey(name: 'vocabulary_count')
  final int vocabularyCount;
  
  @JsonKey(name: 'experience_points')
  final int experiencePoints;
  
  @JsonKey(name: 'current_level')
  final int currentLevel;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;
  
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  
  @JsonKey(name: 'premium_expires_at')
  final DateTime? premiumExpiresAt;
  
  const UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.nickname,
    this.avatar,
    this.phone,
    this.birthday,
    this.gender,
    this.bio,
    required this.learningLevel,
    required this.targetLanguage,
    required this.nativeLanguage,
    required this.dailyGoal,
    required this.studyStreak,
    required this.totalStudyDays,
    required this.vocabularyCount,
    required this.experiencePoints,
    required this.currentLevel,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    required this.isPremium,
    this.premiumExpiresAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  UserModel copyWith({
    int? userId,
    String? username,
    String? email,
    String? nickname,
    String? avatar,
    String? phone,
    DateTime? birthday,
    String? gender,
    String? bio,
    String? learningLevel,
    String? targetLanguage,
    String? nativeLanguage,
    int? dailyGoal,
    int? studyStreak,
    int? totalStudyDays,
    int? vocabularyCount,
    int? experiencePoints,
    int? currentLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isPremium,
    DateTime? premiumExpiresAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      learningLevel: learningLevel ?? this.learningLevel,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      studyStreak: studyStreak ?? this.studyStreak,
      totalStudyDays: totalStudyDays ?? this.totalStudyDays,
      vocabularyCount: vocabularyCount ?? this.vocabularyCount,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      currentLevel: currentLevel ?? this.currentLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.userId == userId &&
        other.username == username &&
        other.email == email;
  }
  
  @override
  int get hashCode {
    return userId.hashCode ^
        username.hashCode ^
        email.hashCode;
  }
  
  @override
  String toString() {
    return 'UserModel(userId: $userId, username: $username, email: $email)';
  }
}

/// 用户统计信息模型
@JsonSerializable()
class UserStatsModel {
  @JsonKey(name: 'total_words_learned')
  final int totalWordsLearned;
  
  @JsonKey(name: 'words_learned_today')
  final int wordsLearnedToday;
  
  @JsonKey(name: 'study_time_today')
  final int studyTimeToday; // 分钟
  
  @JsonKey(name: 'total_study_time')
  final int totalStudyTime; // 分钟
  
  @JsonKey(name: 'listening_score')
  final double listeningScore;
  
  @JsonKey(name: 'reading_score')
  final double readingScore;
  
  @JsonKey(name: 'writing_score')
  final double writingScore;
  
  @JsonKey(name: 'speaking_score')
  final double speakingScore;
  
  @JsonKey(name: 'overall_score')
  final double overallScore;
  
  @JsonKey(name: 'weekly_progress')
  final List<int> weeklyProgress;
  
  @JsonKey(name: 'monthly_progress')
  final List<int> monthlyProgress;
  
  const UserStatsModel({
    required this.totalWordsLearned,
    required this.wordsLearnedToday,
    required this.studyTimeToday,
    required this.totalStudyTime,
    required this.listeningScore,
    required this.readingScore,
    required this.writingScore,
    required this.speakingScore,
    required this.overallScore,
    required this.weeklyProgress,
    required this.monthlyProgress,
  });
  
  factory UserStatsModel.fromJson(Map<String, dynamic> json) => _$UserStatsModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserStatsModelToJson(this);
}