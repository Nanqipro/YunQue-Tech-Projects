import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../errors/app_exception.dart';

/// 认证服务
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// 登录
  Future<AuthResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
          'remember_me': rememberMe,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('登录失败: $e');
    }
  }

  /// 注册
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('注册失败: $e');
    }
  }

  /// 第三方登录
  Future<AuthResponse> socialLogin({
    required String provider,
    required String accessToken,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.socialLogin,
        data: {
          'provider': provider,
          'access_token': accessToken,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('第三方登录失败: $e');
    }
  }

  /// 忘记密码
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('发送重置密码邮件失败: $e');
    }
  }

  /// 重置密码
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('重置密码失败: $e');
    }
  }

  /// 修改密码
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.put(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('修改密码失败: $e');
    }
  }

  /// 刷新Token
  Future<TokenRefreshResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      return TokenRefreshResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('刷新Token失败: $e');
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('登出失败: $e');
    }
  }

  /// 获取用户信息
  Future<User> getUserInfo() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userInfo);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('获取用户信息失败: $e');
    }
  }

  /// 获取当前用户信息（getUserInfo的别名）
  Future<User> getCurrentUser() async {
    return await getUserInfo();
  }

  /// 更新用户信息
  Future<User> updateUserInfo(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.userInfo,
        data: data,
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('更新用户信息失败: $e');
    }
  }

  /// 验证邮箱
  Future<void> verifyEmail(String token) async {
    try {
      await _apiClient.post(
        ApiEndpoints.verifyEmail,
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('验证邮箱失败: $e');
    }
  }

  /// 重新发送验证邮件
  Future<void> resendVerificationEmail() async {
    try {
      await _apiClient.post(ApiEndpoints.resendVerificationEmail);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('发送验证邮件失败: $e');
    }
  }

  /// 检查用户名是否可用
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.checkUsername}?username=$username',
      );
      return response.data['available'] ?? false;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('检查用户名失败: $e');
    }
  }

  /// 检查邮箱是否可用
  Future<bool> checkEmailAvailability(String email) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.checkEmail}?email=$email',
      );
      return response.data['available'] ?? false;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AppException('检查邮箱失败: $e');
    }
  }

  /// 处理Dio异常
  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException('连接超时');
      case DioExceptionType.sendTimeout:
        return NetworkException('发送超时');
      case DioExceptionType.receiveTimeout:
        return NetworkException('接收超时');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? '请求失败';
        
        switch (statusCode) {
          case 400:
            return ValidationException(message);
          case 401:
            return AuthException('认证失败');
          case 403:
            return AuthException('权限不足');
          case 404:
            return AppException('资源不存在');
          case 422:
            return ValidationException(message);
          case 500:
            return ServerException('服务器内部错误');
          default:
            return AppException('请求失败: $message');
        }
      case DioExceptionType.cancel:
        return AppException('请求已取消');
      case DioExceptionType.connectionError:
        return NetworkException('网络连接错误');
      case DioExceptionType.badCertificate:
        return NetworkException('证书错误');
      case DioExceptionType.unknown:
      default:
        return AppException('未知错误: ${e.message}');
    }
  }
}