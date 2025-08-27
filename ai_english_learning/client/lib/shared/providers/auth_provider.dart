import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';
import '../../core/storage/storage_service.dart';
import '../../core/constants/app_constants.dart';

/// 认证状态
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// 认证Provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;
  
  // Getters
  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  
  /// 初始化认证状态
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      if (_authService.isLoggedIn()) {
        final cachedUser = _authService.getCachedUser();
        if (cachedUser != null) {
          _user = cachedUser;
          _setState(AuthState.authenticated);
          
          // 尝试刷新用户信息
          await _refreshUserInfo();
        } else {
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('初始化失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// 用户注册
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? nickname,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.register(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        nickname: nickname,
        phone: phone,
      );
      
      if (response.success && response.data != null && response.data!.user != null) {
        _user = UserModel.fromJson(response.data!.user!);
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('注册失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 用户登录
  Future<bool> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.login(
        username: username,
        password: password,
        rememberMe: rememberMe,
      );
      
      if (response.success && response.data != null && response.data!.user != null) {
        _user = UserModel.fromJson(response.data!.user!);
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('登录失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 用户登出
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
    } catch (e) {
      // 即使登出请求失败，也要清除本地状态
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      _setState(AuthState.unauthenticated);
      _setLoading(false);
    }
  }
  
  /// 刷新用户信息
  Future<void> _refreshUserInfo() async {
    try {
      final response = await _authService.getCurrentUser();
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh user info error: $e');
    }
  }
  
  /// 更新用户信息
  Future<bool> updateProfile({
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
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.updateProfile(
        nickname: nickname,
        avatar: avatar,
        phone: phone,
        birthday: birthday,
        gender: gender,
        bio: bio,
        learningLevel: learningLevel,
        targetLanguage: targetLanguage,
        nativeLanguage: nativeLanguage,
        dailyGoal: dailyGoal,
      );
      
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('更新个人信息失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 修改密码
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      if (response.success) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('修改密码失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 刷新Token
  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      
      if (response.success && response.data != null && response.data!.user != null) {
        _user = UserModel.fromJson(response.data!.user!);
        if (_state != AuthState.authenticated) {
          _setState(AuthState.authenticated);
        }
        return true;
      } else {
        // Token刷新失败，需要重新登录
        _user = null;
        _setState(AuthState.unauthenticated);
        return false;
      }
    } catch (e) {
      _user = null;
      _setState(AuthState.unauthenticated);
      return false;
    }
  }
  
  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// 设置状态
  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }
  
  /// 设置错误信息
  void _setError(String message) {
    _errorMessage = message;
    _setState(AuthState.error);
  }
  
  /// 清除错误信息
  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
    }
  }
  
  /// 清除所有状态
  void clear() {
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    _setState(AuthState.initial);
  }
}