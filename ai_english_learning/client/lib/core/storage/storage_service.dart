import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 本地存储服务
class StorageService {
  static SharedPreferences? _prefs;
  
  /// 初始化存储服务
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// 获取SharedPreferences实例
  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call StorageService.init() first.');
    }
    return _prefs!;
  }
  
  /// 存储字符串
  static Future<bool> setString(String key, String value) async {
    return await _instance.setString(key, value);
  }
  
  /// 获取字符串
  static String? getString(String key) {
    return _instance.getString(key);
  }
  
  /// 存储整数
  static Future<bool> setInt(String key, int value) async {
    return await _instance.setInt(key, value);
  }
  
  /// 获取整数
  static int? getInt(String key) {
    return _instance.getInt(key);
  }
  
  /// 存储双精度浮点数
  static Future<bool> setDouble(String key, double value) async {
    return await _instance.setDouble(key, value);
  }
  
  /// 获取双精度浮点数
  static double? getDouble(String key) {
    return _instance.getDouble(key);
  }
  
  /// 存储布尔值
  static Future<bool> setBool(String key, bool value) async {
    return await _instance.setBool(key, value);
  }
  
  /// 获取布尔值
  static bool? getBool(String key) {
    return _instance.getBool(key);
  }
  
  /// 存储字符串列表
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _instance.setStringList(key, value);
  }
  
  /// 获取字符串列表
  static List<String>? getStringList(String key) {
    return _instance.getStringList(key);
  }
  
  /// 存储对象（JSON序列化）
  static Future<bool> setObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return await setString(key, jsonString);
  }
  
  /// 获取对象（JSON反序列化）
  static Map<String, dynamic>? getObject(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding JSON for key $key: $e');
      return null;
    }
  }
  
  /// 存储对象列表（JSON序列化）
  static Future<bool> setObjectList(String key, List<Map<String, dynamic>> value) async {
    final jsonString = jsonEncode(value);
    return await setString(key, jsonString);
  }
  
  /// 获取对象列表（JSON反序列化）
  static List<Map<String, dynamic>>? getObjectList(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error decoding JSON list for key $key: $e');
      return null;
    }
  }
  
  /// 检查键是否存在
  static bool containsKey(String key) {
    return _instance.containsKey(key);
  }
  
  /// 删除指定键
  static Future<bool> remove(String key) async {
    return await _instance.remove(key);
  }
  
  /// 清空所有数据
  static Future<bool> clear() async {
    return await _instance.clear();
  }
  
  /// 获取所有键
  static Set<String> getKeys() {
    return _instance.getKeys();
  }
  
  /// 重新加载数据
  static Future<void> reload() async {
    await _instance.reload();
  }
}

/// 存储键名常量
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userInfo = 'user_info';
  static const String appSettings = 'app_settings';
  static const String learningProgress = 'learning_progress';
  static const String vocabularyCache = 'vocabulary_cache';
  static const String studyHistory = 'study_history';
  static const String offlineData = 'offline_data';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String firstLaunch = 'first_launch';
  static const String onboardingCompleted = 'onboarding_completed';
}