enum SpeakingScenario {
  dailyConversation,
  businessMeeting,
  jobInterview,
  shopping,
  restaurant,
  travel,
  academic,
  socializing,
  phoneCall,
  presentation;

  String get displayName {
    switch (this) {
      case SpeakingScenario.dailyConversation:
        return '日常对话';
      case SpeakingScenario.businessMeeting:
        return '商务会议';
      case SpeakingScenario.jobInterview:
        return '求职面试';
      case SpeakingScenario.shopping:
        return '购物';
      case SpeakingScenario.restaurant:
        return '餐厅';
      case SpeakingScenario.travel:
        return '旅行';
      case SpeakingScenario.academic:
        return '学术讨论';
      case SpeakingScenario.socializing:
        return '社交聚会';
      case SpeakingScenario.phoneCall:
        return '电话通话';
      case SpeakingScenario.presentation:
        return '演讲展示';
    }
  }

  String get description {
    switch (this) {
      case SpeakingScenario.dailyConversation:
        return '练习日常生活中的基本对话';
      case SpeakingScenario.businessMeeting:
        return '提升商务环境下的沟通能力';
      case SpeakingScenario.jobInterview:
        return '准备求职面试的常见问题';
      case SpeakingScenario.shopping:
        return '学习购物时的实用表达';
      case SpeakingScenario.restaurant:
        return '掌握餐厅点餐的对话技巧';
      case SpeakingScenario.travel:
        return '旅行中的必备口语交流';
      case SpeakingScenario.academic:
        return '学术环境下的专业讨论';
      case SpeakingScenario.socializing:
        return '社交场合的自然交流';
      case SpeakingScenario.phoneCall:
        return '电话沟通的特殊技巧';
      case SpeakingScenario.presentation:
        return '公开演讲和展示技能';
    }
  }
}

enum SpeakingDifficulty {
  beginner,
  elementary,
  intermediate,
  upperIntermediate,
  advanced;

  String get displayName {
    switch (this) {
      case SpeakingDifficulty.beginner:
        return '初学者';
      case SpeakingDifficulty.elementary:
        return '基础';
      case SpeakingDifficulty.intermediate:
        return '中级';
      case SpeakingDifficulty.upperIntermediate:
        return '中高级';
      case SpeakingDifficulty.advanced:
        return '高级';
    }
  }
}

class SpeakingTask {
  final String id;
  final String title;
  final String description;
  final SpeakingScenario scenario;
  final SpeakingDifficulty difficulty;
  final List<String> objectives;
  final List<String> keyPhrases;
  final String? backgroundInfo;
  final int estimatedDuration; // 预估时长（分钟）
  final bool isRecommended; // 是否推荐
  final bool isFavorite; // 是否收藏
  final int completionCount; // 完成次数
  final DateTime createdAt;
  final DateTime updatedAt;

  const SpeakingTask({
    required this.id,
    required this.title,
    required this.description,
    required this.scenario,
    required this.difficulty,
    required this.objectives,
    required this.keyPhrases,
    this.backgroundInfo,
    required this.estimatedDuration,
    this.isRecommended = false,
    this.isFavorite = false,
    this.completionCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpeakingTask.fromJson(Map<String, dynamic> json) {
    return SpeakingTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scenario: SpeakingScenario.values.firstWhere(
        (e) => e.name == json['scenario'],
        orElse: () => SpeakingScenario.dailyConversation,
      ),
      difficulty: SpeakingDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => SpeakingDifficulty.intermediate,
      ),
      objectives: List<String>.from(json['objectives'] ?? []),
      keyPhrases: List<String>.from(json['keyPhrases'] ?? []),
      backgroundInfo: json['backgroundInfo'] as String?,
      estimatedDuration: json['estimatedDuration'] as int,
      isRecommended: json['isRecommended'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      completionCount: json['completionCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scenario': scenario.name,
      'difficulty': difficulty.name,
      'objectives': objectives,
      'keyPhrases': keyPhrases,
      'backgroundInfo': backgroundInfo,
      'estimatedDuration': estimatedDuration,
      'isRecommended': isRecommended,
      'isFavorite': isFavorite,
      'completionCount': completionCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}