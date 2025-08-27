/// API端点配置
class ApiEndpoints {
  // 基础URL
  static const String baseUrl = 'https://api.aienglishlearning.com';
  
  // 认证相关
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String socialLogin = '/auth/social-login';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerificationEmail = '/auth/resend-verification';
  
  // 用户相关
  static const String userInfo = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String uploadAvatar = '/user/avatar';
  static const String checkUsername = '/user/check-username';
  static const String checkEmail = '/user/check-email';
  
  // 学习相关
  static const String learningProgress = '/learning/progress';
  static const String learningStats = '/learning/stats';
  static const String dailyGoal = '/learning/daily-goal';
  
  // 词汇相关
  static const String vocabulary = '/vocabulary';
  static const String vocabularyTest = '/vocabulary/test';
  static const String vocabularyProgress = '/vocabulary/progress';
  static const String wordBooks = '/vocabulary/books';
  static const String wordLists = '/vocabulary/lists';
  
  // 听力相关
  static const String listening = '/listening';
  static const String listeningExercises = '/listening/exercises';
  static const String listeningProgress = '/listening/progress';
  
  // 阅读相关
  static const String reading = '/reading';
  static const String readingArticles = '/reading/articles';
  static const String readingProgress = '/reading/progress';
  
  // 写作相关
  static const String writing = '/writing';
  static const String writingTasks = '/writing/tasks';
  static const String writingSubmissions = '/writing/submissions';
  static const String writingFeedback = '/writing/feedback';
  
  // 口语相关
  static const String speaking = '/speaking';
  static const String speakingExercises = '/speaking/exercises';
  static const String speakingEvaluation = '/speaking/evaluation';
  
  // AI相关
  static const String aiChat = '/ai/chat';
  static const String aiCorrection = '/ai/correction';
  static const String aiSuggestion = '/ai/suggestion';
  
  // 文件上传
  static const String upload = '/upload';
  static const String uploadAudio = '/upload/audio';
  static const String uploadImage = '/upload/image';
  
  // 系统相关
  static const String version = '/system/version';
  static const String config = '/system/config';
  static const String feedback = '/system/feedback';
}