/// 应用常量配置
class AppConstants {
  // 应用信息
  static const String appName = 'AI英语学习';
  static const String appVersion = '1.0.0';
  
  // API配置
  static const String baseUrl = 'https://api.aienglish.com/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // 存储键名
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userInfoKey = 'user_info';
  static const String settingsKey = 'app_settings';
  
  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // 学习配置
  static const int dailyWordGoal = 50;
  static const int maxRetryAttempts = 3;
  static const Duration studySessionDuration = Duration(minutes: 25);
  
  // 音频配置
  static const double defaultPlaybackSpeed = 1.0;
  static const double minPlaybackSpeed = 0.5;
  static const double maxPlaybackSpeed = 2.0;
  
  // 图片配置
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // 缓存配置
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
}

/// 路由常量
class RouteConstants {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String vocabulary = '/vocabulary';
  static const String vocabularyTest = '/vocabulary/test';
  static const String listening = '/listening';
  static const String reading = '/reading';
  static const String writing = '/writing';
  static const String speaking = '/speaking';
  static const String settings = '/settings';
}

/// 学习等级常量
enum LearningLevel {
  beginner('beginner', '初级'),
  intermediate('intermediate', '中级'),
  advanced('advanced', '高级');
  
  const LearningLevel(this.value, this.label);
  
  final String value;
  final String label;
}

/// 词库类型常量
enum VocabularyType {
  elementary('elementary', '小学'),
  junior('junior', '初中'),
  senior('senior', '高中'),
  cet4('cet4', '四级'),
  cet6('cet6', '六级'),
  toefl('toefl', '托福'),
  ielts('ielts', '雅思'),
  business('business', '商务'),
  daily('daily', '日常');
  
  const VocabularyType(this.value, this.label);
  
  final String value;
  final String label;
}