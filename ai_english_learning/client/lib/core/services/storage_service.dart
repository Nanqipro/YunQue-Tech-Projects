import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/exceptions.dart';

/// 存储服务
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  /// 获取单例实例
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// 初始化
  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw CacheException('初始化存储服务失败: $e');
    }
  }

  // ==================== 普通存储 ====================

  /// 存储字符串
  Future<bool> setString(String key, String value) async {
    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      throw CacheException('存储字符串失败: $e');
    }
  }

  /// 获取字符串
  String? getString(String key, {String? defaultValue}) {
    try {
      return _prefs!.getString(key) ?? defaultValue;
    } catch (e) {
      throw CacheException('获取字符串失败: $e');
    }
  }

  /// 存储整数
  Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs!.setInt(key, value);
    } catch (e) {
      throw CacheException('存储整数失败: $e');
    }
  }

  /// 获取整数
  int? getInt(String key, {int? defaultValue}) {
    try {
      return _prefs!.getInt(key) ?? defaultValue;
    } catch (e) {
      throw CacheException('获取整数失败: $e');
    }
  }

  /// 存储布尔值
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs!.setBool(key, value);
    } catch (e) {
      throw CacheException('存储布尔值失败: $e');
    }
  }

  /// 获取布尔值
  bool? getBool(String key, {bool? defaultValue}) {
    try {
      return _prefs!.getBool(key) ?? defaultValue;
    } catch (e) {
      throw CacheException('获取布尔值失败: $e');
    }
  }

  /// 存储双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs!.setDouble(key, value);
    } catch (e) {
      throw CacheException('存储双精度浮点数失败: $e');
    }
  }

  /// 获取双精度浮点数
  double? getDouble(String key, {double? defaultValue}) {
    try {
      return _prefs!.getDouble(key) ?? defaultValue;
    } catch (e) {
      throw CacheException('获取双精度浮点数失败: $e');
    }
  }

  /// 存储字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs!.setStringList(key, value);
    } catch (e) {
      throw CacheException('存储字符串列表失败: $e');
    }
  }

  /// 获取字符串列表
  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    try {
      return _prefs!.getStringList(key) ?? defaultValue;
    } catch (e) {
      throw CacheException('获取字符串列表失败: $e');
    }
  }

  /// 存储JSON对象
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      throw CacheException('存储JSON对象失败: $e');
    }
  }

  /// 获取JSON对象
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('获取JSON对象失败: $e');
    }
  }

  /// 删除指定键的数据
  Future<bool> remove(String key) async {
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      throw CacheException('删除数据失败: $e');
    }
  }

  /// 清空所有数据
  Future<bool> clear() async {
    try {
      return await _prefs!.clear();
    } catch (e) {
      throw CacheException('清空数据失败: $e');
    }
  }

  /// 检查是否包含指定键
  bool containsKey(String key) {
    try {
      return _prefs!.containsKey(key);
    } catch (e) {
      throw CacheException('检查键是否存在失败: $e');
    }
  }

  /// 获取所有键
  Set<String> getKeys() {
    try {
      return _prefs!.getKeys();
    } catch (e) {
      throw CacheException('获取所有键失败: $e');
    }
  }

  // ==================== 安全存储 ====================

  /// 安全存储字符串（用于敏感信息如Token）
  Future<void> setSecureString(String key, String value) async {
    try {
      await _prefs!.setString('secure_$key', value);
    } catch (e) {
      throw CacheException('安全存储字符串失败: $e');
    }
  }

  /// 安全获取字符串
  Future<String?> getSecureString(String key) async {
    try {
      return _prefs!.getString('secure_$key');
    } catch (e) {
      throw CacheException('安全获取字符串失败: $e');
    }
  }

  /// 安全存储JSON对象
  Future<void> setSecureJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      await setSecureString(key, jsonString);
    } catch (e) {
      throw CacheException('安全存储JSON对象失败: $e');
    }
  }

  /// 安全获取JSON对象
  Future<Map<String, dynamic>?> getSecureJson(String key) async {
    try {
      final jsonString = await getSecureString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('安全获取JSON对象失败: $e');
    }
  }

  /// 安全删除指定键的数据
  Future<void> removeSecure(String key) async {
    try {
      await _prefs!.remove('secure_$key');
    } catch (e) {
      throw CacheException('安全删除数据失败: $e');
    }
  }

  /// 安全清空所有数据
  Future<void> clearSecure() async {
    try {
      final keys = _prefs!.getKeys().where((key) => key.startsWith('secure_')).toList();
      for (final key in keys) {
        await _prefs!.remove(key);
      }
    } catch (e) {
      throw CacheException('安全清空数据失败: $e');
    }
  }

  /// 安全检查是否包含指定键
  Future<bool> containsSecureKey(String key) async {
    try {
      return _prefs!.containsKey('secure_$key');
    } catch (e) {
      throw CacheException('安全检查键是否存在失败: $e');
    }
  }

  /// 安全获取所有键
  Future<Map<String, String>> getAllSecure() async {
    try {
      final result = <String, String>{};
      final keys = _prefs!.getKeys().where((key) => key.startsWith('secure_'));
      for (final key in keys) {
        final value = _prefs!.getString(key);
        if (value != null) {
          result[key.substring(7)] = value; // 移除 'secure_' 前缀
        }
      }
      return result;
    } catch (e) {
      throw CacheException('安全获取所有数据失败: $e');
    }
  }

  // ==================== Token 相关便捷方法 ====================

  /// 保存访问令牌
  Future<void> saveToken(String token) async {
    await setSecureString(StorageKeys.accessToken, token);
  }

  /// 获取访问令牌
  Future<String?> getToken() async {
    return await getSecureString(StorageKeys.accessToken);
  }

  /// 保存刷新令牌
  Future<void> saveRefreshToken(String refreshToken) async {
    await setSecureString(StorageKeys.refreshToken, refreshToken);
  }

  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    return await getSecureString(StorageKeys.refreshToken);
  }

  /// 清除所有令牌
  Future<void> clearTokens() async {
    await removeSecure(StorageKeys.accessToken);
    await removeSecure(StorageKeys.refreshToken);
  }
}

/// 存储键常量
class StorageKeys {
  // 用户相关
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userInfo = 'user_info';
  static const String isLoggedIn = 'is_logged_in';
  static const String rememberMe = 'remember_me';
  
  // 应用设置
  static const String appLanguage = 'app_language';
  static const String appTheme = 'app_theme';
  static const String firstLaunch = 'first_launch';
  static const String onboardingCompleted = 'onboarding_completed';
  
  // 学习设置
  static const String dailyGoal = 'daily_goal';
  static const String reminderTimes = 'reminder_times';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';
  
  // 学习数据
  static const String learningProgress = 'learning_progress';
  static const String vocabularyProgress = 'vocabulary_progress';
  static const String listeningProgress = 'listening_progress';
  static const String readingProgress = 'reading_progress';
  static const String writingProgress = 'writing_progress';
  static const String speakingProgress = 'speaking_progress';
  
  // 缓存数据
  static const String cachedWordBooks = 'cached_word_books';
  static const String cachedArticles = 'cached_articles';
  static const String cachedExercises = 'cached_exercises';
  
  // 临时数据
  static const String tempData = 'temp_data';
  static const String draftData = 'draft_data';
}