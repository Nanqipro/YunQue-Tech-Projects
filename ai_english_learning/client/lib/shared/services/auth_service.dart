import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_error.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

/// 认证服务
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final ApiClient _apiClient = ApiClient.instance;
  
  /// 用户注册
  Future<ApiResponse<AuthResponse>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? nickname,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
          if (nickname != null) 'nickname': nickname,
          if (phone != null) 'phone': phone,
        },
      );
      
      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data['data']);
        await _saveTokens(authResponse);
        
        return ApiResponse.success(
          message: response.data['message'] ?? '注册成功',
          data: authResponse,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? '注册失败',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: '注册失败：$e',
        error: e.toString(),
      );
    }
  }
  
  /// 用户登录
  Future<ApiResponse<AuthResponse>> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          'remember_me': rememberMe,
        },
      );
      
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data['data']);
        await _saveTokens(authResponse);
        
        return ApiResponse.success(
          message: response.data['message'] ?? '登录成功',
          data: authResponse,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? '登录失败',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: '登录失败：$e',
        error: e.toString(),
      );
    }
  }
  
  /// 刷新Token
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    try {
      final refreshToken = StorageService.getString(AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        return ApiResponse.failure(
          message: 'Refresh token not found',
          code: 401,
        );
      }
      
      final response = await _apiClient.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );
      
      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data['data']);
        await _saveTokens(authResponse);
        
        return ApiResponse.success(
          message: 'Token refreshed successfully',
          data: authResponse,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Token refresh failed',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Token refresh failed: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 用户登出
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiClient.post('/auth/logout');
      
      // 无论服务器响应如何，都清除本地token
      await _clearTokens();
      
      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: response.data['message'] ?? '登出成功',
        );
      } else {
        return ApiResponse.success(
          message: '登出成功',
        );
      }
    } on DioException catch (e) {
      // 即使请求失败，也清除本地token
      await _clearTokens();
      return ApiResponse.success(
        message: '登出成功',
      );
    } catch (e) {
      await _clearTokens();
      return ApiResponse.success(
        message: '登出成功',
      );
    }
  }
  
  /// 获取当前用户信息
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['data']);
        await StorageService.setObject(AppConstants.userInfoKey, user.toJson());
        
        return ApiResponse.success(
          message: 'User info retrieved successfully',
          data: user,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to get user info',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to get user info: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 更新用户信息
  Future<ApiResponse<UserModel>> updateProfile({
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
    try {
      final data = <String, dynamic>{};
      if (nickname != null) data['nickname'] = nickname;
      if (avatar != null) data['avatar'] = avatar;
      if (phone != null) data['phone'] = phone;
      if (birthday != null) data['birthday'] = birthday.toIso8601String();
      if (gender != null) data['gender'] = gender;
      if (bio != null) data['bio'] = bio;
      if (learningLevel != null) data['learning_level'] = learningLevel;
      if (targetLanguage != null) data['target_language'] = targetLanguage;
      if (nativeLanguage != null) data['native_language'] = nativeLanguage;
      if (dailyGoal != null) data['daily_goal'] = dailyGoal;
      
      final response = await _apiClient.put('/auth/profile', data: data);
      
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['data']);
        await StorageService.setObject(AppConstants.userInfoKey, user.toJson());
        
        return ApiResponse.success(
          message: response.data['message'] ?? '个人信息更新成功',
          data: user,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? '个人信息更新失败',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: '个人信息更新失败：$e',
        error: e.toString(),
      );
    }
  }
  
  /// 修改密码
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.put(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      
      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: response.data['message'] ?? '密码修改成功',
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? '密码修改失败',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: '密码修改失败：$e',
        error: e.toString(),
      );
    }
  }
  
  /// 检查是否已登录
  bool isLoggedIn() {
    final token = StorageService.getString(AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }
  
  /// 获取本地存储的用户信息
  UserModel? getCachedUser() {
    final userJson = StorageService.getObject(AppConstants.userInfoKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(userJson);
      } catch (e) {
        print('Error parsing cached user: $e');
        return null;
      }
    }
    return null;
  }
  
  /// 保存tokens
  Future<void> _saveTokens(AuthResponse authResponse) async {
    await StorageService.setString(
      AppConstants.accessTokenKey,
      authResponse.accessToken,
    );
    await StorageService.setString(
      AppConstants.refreshTokenKey,
      authResponse.refreshToken,
    );
    
    if (authResponse.user != null) {
      await StorageService.setObject(
        AppConstants.userInfoKey,
        authResponse.user!,
      );
    }
  }
  
  /// 清除tokens
  Future<void> _clearTokens() async {
    await StorageService.remove(AppConstants.accessTokenKey);
    await StorageService.remove(AppConstants.refreshTokenKey);
    await StorageService.remove(AppConstants.userInfoKey);
  }
  
  /// 处理Dio错误
  ApiResponse<T> _handleDioError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.failure(
          message: '请求超时，请检查网络连接',
          error: 'TIMEOUT',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? '请求失败';
        return ApiResponse.failure(
          message: message,
          code: statusCode,
          error: 'BAD_RESPONSE',
        );
      case DioExceptionType.cancel:
        return ApiResponse.failure(
          message: '请求已取消',
          error: 'CANCELLED',
        );
      case DioExceptionType.connectionError:
        return ApiResponse.failure(
          message: '网络连接失败，请检查网络设置',
          error: 'CONNECTION_ERROR',
        );
      default:
        return ApiResponse.failure(
          message: '未知错误：${e.message}',
          error: 'UNKNOWN',
        );
    }
  }
}