import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/errors/app_exception.dart';

/// 认证状态
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 认证状态管理器
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthNotifier(this._authService, this._storageService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// 检查认证状态
  Future<void> _checkAuthStatus() async {
    try {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      // 忽略错误，保持未认证状态
    }
  }

  /// 登录
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      
      // 保存token
      await _storageService.saveToken(result.token);
      if (result.refreshToken != null) {
        await _storageService.saveRefreshToken(result.refreshToken!);
      }
      
      state = state.copyWith(
        user: result.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 注册
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.register(
        email: email,
        password: password,
        username: username,
        confirmPassword: password,
      );
      
      // 保存token
      await _storageService.saveToken(result.token);
      if (result.refreshToken != null) {
        await _storageService.saveRefreshToken(result.refreshToken!);
      }
      
      state = state.copyWith(
        user: result.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.logout();
      await _storageService.clearTokens();
      
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 忘记密码
  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.forgotPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 重置密码
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 更新用户信息
  Future<void> updateProfile({
    String? username,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    if (state.user == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedUser = await _authService.updateUserInfo({
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
      });
      
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 修改密码
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 认证服务提供者
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ApiClient.instance);
});

/// 存储服务提供者
final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.getInstance();
});

/// 认证状态提供者
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final storageServiceAsync = ref.watch(storageServiceProvider);
  
  // 如果StorageService还在加载中，返回一个临时的notifier
  return storageServiceAsync.when(
    data: (storageService) => AuthNotifier(authService, storageService),
    loading: () => AuthNotifier(authService, StorageService.getInstance().then((value) => value) as StorageService),
    error: (error, stack) => throw error,
  );
});

/// 是否已认证的提供者
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// 当前用户提供者
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});