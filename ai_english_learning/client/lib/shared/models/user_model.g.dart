// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      userId: (json['user_id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      birthday: json['birthday'] == null
          ? null
          : DateTime.parse(json['birthday'] as String),
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      learningLevel: json['learning_level'] as String,
      targetLanguage: json['target_language'] as String,
      nativeLanguage: json['native_language'] as String,
      dailyGoal: (json['daily_goal'] as num).toInt(),
      studyStreak: (json['study_streak'] as num).toInt(),
      totalStudyDays: (json['total_study_days'] as num).toInt(),
      vocabularyCount: (json['vocabulary_count'] as num).toInt(),
      experiencePoints: (json['experience_points'] as num).toInt(),
      currentLevel: (json['current_level'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLoginAt: json['last_login_at'] == null
          ? null
          : DateTime.parse(json['last_login_at'] as String),
      isPremium: json['is_premium'] as bool,
      premiumExpiresAt: json['premium_expires_at'] == null
          ? null
          : DateTime.parse(json['premium_expires_at'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'phone': instance.phone,
      'birthday': instance.birthday?.toIso8601String(),
      'gender': instance.gender,
      'bio': instance.bio,
      'learning_level': instance.learningLevel,
      'target_language': instance.targetLanguage,
      'native_language': instance.nativeLanguage,
      'daily_goal': instance.dailyGoal,
      'study_streak': instance.studyStreak,
      'total_study_days': instance.totalStudyDays,
      'vocabulary_count': instance.vocabularyCount,
      'experience_points': instance.experiencePoints,
      'current_level': instance.currentLevel,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'last_login_at': instance.lastLoginAt?.toIso8601String(),
      'is_premium': instance.isPremium,
      'premium_expires_at': instance.premiumExpiresAt?.toIso8601String(),
    };

UserStatsModel _$UserStatsModelFromJson(Map<String, dynamic> json) =>
    UserStatsModel(
      totalWordsLearned: (json['total_words_learned'] as num).toInt(),
      wordsLearnedToday: (json['words_learned_today'] as num).toInt(),
      studyTimeToday: (json['study_time_today'] as num).toInt(),
      totalStudyTime: (json['total_study_time'] as num).toInt(),
      listeningScore: (json['listening_score'] as num).toDouble(),
      readingScore: (json['reading_score'] as num).toDouble(),
      writingScore: (json['writing_score'] as num).toDouble(),
      speakingScore: (json['speaking_score'] as num).toDouble(),
      overallScore: (json['overall_score'] as num).toDouble(),
      weeklyProgress: (json['weekly_progress'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      monthlyProgress: (json['monthly_progress'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$UserStatsModelToJson(UserStatsModel instance) =>
    <String, dynamic>{
      'total_words_learned': instance.totalWordsLearned,
      'words_learned_today': instance.wordsLearnedToday,
      'study_time_today': instance.studyTimeToday,
      'total_study_time': instance.totalStudyTime,
      'listening_score': instance.listeningScore,
      'reading_score': instance.readingScore,
      'writing_score': instance.writingScore,
      'speaking_score': instance.speakingScore,
      'overall_score': instance.overallScore,
      'weekly_progress': instance.weeklyProgress,
      'monthly_progress': instance.monthlyProgress,
    };
