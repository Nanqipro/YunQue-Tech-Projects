import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// 用户模型
@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? profile;
  final UserSettings? settings;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
    this.settings,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? profile,
    UserSettings? settings,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
    );
  }
}

/// 用户资料
@JsonSerializable()
class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? bio;
  final String? avatar;
  final String? realName;
  final String? gender;
  final DateTime? birthday;
  final String? location;
  final String? occupation;
  final String? education;
  final List<String>? interests;
  final LearningGoal? learningGoal;
  final EnglishLevel? currentLevel;
  final EnglishLevel? targetLevel;
  final EnglishLevel? englishLevel;
  final UserSettings? settings;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.phone,
    this.bio,
    this.avatar,
    this.realName,
    this.gender,
    this.birthday,
    this.location,
    this.occupation,
    this.education,
    this.interests,
    this.learningGoal,
    this.currentLevel,
    this.targetLevel,
    this.englishLevel,
    this.settings,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
    String? avatar,
    String? realName,
    String? gender,
    DateTime? birthday,
    String? location,
    String? occupation,
    String? education,
    List<String>? interests,
    LearningGoal? learningGoal,
    EnglishLevel? currentLevel,
    EnglishLevel? targetLevel,
    EnglishLevel? englishLevel,
    UserSettings? settings,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      realName: realName ?? this.realName,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      location: location ?? this.location,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      interests: interests ?? this.interests,
      learningGoal: learningGoal ?? this.learningGoal,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      englishLevel: englishLevel ?? this.englishLevel,
      settings: settings ?? this.settings,
    );
  }
}

/// 用户设置
@JsonSerializable()
class UserSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String language;
  final String theme;
  final int dailyGoal;
  final int dailyWordGoal;
  final int dailyStudyMinutes;
  final List<String> reminderTimes;
  final bool autoPlayAudio;
  final double audioSpeed;
  final bool showTranslation;
  final bool showPronunciation;

  const UserSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'zh-CN',
    this.theme = 'system',
    this.dailyGoal = 30,
    this.dailyWordGoal = 20,
    this.dailyStudyMinutes = 30,
    this.reminderTimes = const ['09:00', '20:00'],
    this.autoPlayAudio = true,
    this.audioSpeed = 1.0,
    this.showTranslation = true,
    this.showPronunciation = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? language,
    String? theme,
    int? dailyGoal,
    int? dailyWordGoal,
    int? dailyStudyMinutes,
    List<String>? reminderTimes,
    bool? autoPlayAudio,
    double? audioSpeed,
    bool? showTranslation,
    bool? showPronunciation,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      dailyWordGoal: dailyWordGoal ?? this.dailyWordGoal,
      dailyStudyMinutes: dailyStudyMinutes ?? this.dailyStudyMinutes,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      audioSpeed: audioSpeed ?? this.audioSpeed,
      showTranslation: showTranslation ?? this.showTranslation,
      showPronunciation: showPronunciation ?? this.showPronunciation,
    );
  }
}

/// 学习目标
enum LearningGoal {
  @JsonValue('daily_communication')
  dailyCommunication,
  @JsonValue('business_english')
  businessEnglish,
  @JsonValue('academic_study')
  academicStudy,
  @JsonValue('exam_preparation')
  examPreparation,
  @JsonValue('travel')
  travel,
  @JsonValue('hobby')
  hobby,
}

/// 英语水平
enum EnglishLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('elementary')
  elementary,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('upper_intermediate')
  upperIntermediate,
  @JsonValue('advanced')
  advanced,
  @JsonValue('proficient')
  proficient,
  @JsonValue('expert')
  expert,
}

/// 认证响应
@JsonSerializable()
class AuthResponse {
  final User user;
  final String token;
  final String? refreshToken;
  final DateTime expiresAt;

  const AuthResponse({
    required this.user,
    required this.token,
    this.refreshToken,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

/// Token刷新响应
@JsonSerializable()
class TokenRefreshResponse {
  final String token;
  final String? refreshToken;
  final DateTime expiresAt;

  const TokenRefreshResponse({
    required this.token,
    this.refreshToken,
    required this.expiresAt,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) => _$TokenRefreshResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenRefreshResponseToJson(this);
}