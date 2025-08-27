// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      profile: json['profile'] == null
          ? null
          : UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      settings: json['settings'] == null
          ? null
          : UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'profile': instance.profile,
      'settings': instance.settings,
    };

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      avatar: json['avatar'] as String?,
      realName: json['realName'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] == null
          ? null
          : DateTime.parse(json['birthday'] as String),
      location: json['location'] as String?,
      occupation: json['occupation'] as String?,
      education: json['education'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      learningGoal:
          $enumDecodeNullable(_$LearningGoalEnumMap, json['learningGoal']),
      currentLevel:
          $enumDecodeNullable(_$EnglishLevelEnumMap, json['currentLevel']),
      targetLevel:
          $enumDecodeNullable(_$EnglishLevelEnumMap, json['targetLevel']),
      englishLevel:
          $enumDecodeNullable(_$EnglishLevelEnumMap, json['englishLevel']),
      settings: json['settings'] == null
          ? null
          : UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'bio': instance.bio,
      'avatar': instance.avatar,
      'realName': instance.realName,
      'gender': instance.gender,
      'birthday': instance.birthday?.toIso8601String(),
      'location': instance.location,
      'occupation': instance.occupation,
      'education': instance.education,
      'interests': instance.interests,
      'learningGoal': _$LearningGoalEnumMap[instance.learningGoal],
      'currentLevel': _$EnglishLevelEnumMap[instance.currentLevel],
      'targetLevel': _$EnglishLevelEnumMap[instance.targetLevel],
      'englishLevel': _$EnglishLevelEnumMap[instance.englishLevel],
      'settings': instance.settings,
    };

const _$LearningGoalEnumMap = {
  LearningGoal.dailyCommunication: 'daily_communication',
  LearningGoal.businessEnglish: 'business_english',
  LearningGoal.academicStudy: 'academic_study',
  LearningGoal.examPreparation: 'exam_preparation',
  LearningGoal.travel: 'travel',
  LearningGoal.hobby: 'hobby',
};

const _$EnglishLevelEnumMap = {
  EnglishLevel.beginner: 'beginner',
  EnglishLevel.elementary: 'elementary',
  EnglishLevel.intermediate: 'intermediate',
  EnglishLevel.upperIntermediate: 'upper_intermediate',
  EnglishLevel.advanced: 'advanced',
  EnglishLevel.proficient: 'proficient',
  EnglishLevel.expert: 'expert',
};

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'zh-CN',
      theme: json['theme'] as String? ?? 'system',
      dailyGoal: (json['dailyGoal'] as num?)?.toInt() ?? 30,
      dailyWordGoal: (json['dailyWordGoal'] as num?)?.toInt() ?? 20,
      dailyStudyMinutes: (json['dailyStudyMinutes'] as num?)?.toInt() ?? 30,
      reminderTimes: (json['reminderTimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['09:00', '20:00'],
      autoPlayAudio: json['autoPlayAudio'] as bool? ?? true,
      audioSpeed: (json['audioSpeed'] as num?)?.toDouble() ?? 1.0,
      showTranslation: json['showTranslation'] as bool? ?? true,
      showPronunciation: json['showPronunciation'] as bool? ?? true,
    );

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'language': instance.language,
      'theme': instance.theme,
      'dailyGoal': instance.dailyGoal,
      'dailyWordGoal': instance.dailyWordGoal,
      'dailyStudyMinutes': instance.dailyStudyMinutes,
      'reminderTimes': instance.reminderTimes,
      'autoPlayAudio': instance.autoPlayAudio,
      'audioSpeed': instance.audioSpeed,
      'showTranslation': instance.showTranslation,
      'showPronunciation': instance.showPronunciation,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

TokenRefreshResponse _$TokenRefreshResponseFromJson(
        Map<String, dynamic> json) =>
    TokenRefreshResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$TokenRefreshResponseToJson(
        TokenRefreshResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
