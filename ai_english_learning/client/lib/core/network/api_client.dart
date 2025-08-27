import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

/// API客户端配置
class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;
  
  ApiClient._internal() {
    _dio = Dio();
    _setupInterceptors();
  }
  
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }
  
  Dio get dio => _dio;
  
  /// 配置拦截器
  void _setupInterceptors() {
    // 基础配置
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    // 请求拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加认证token
          final token = StorageService.getString(AppConstants.accessTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          // 处理401错误，尝试刷新token
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // 重新发送请求
              final options = error.requestOptions;
              final token = StorageService.getString(AppConstants.accessTokenKey);
              options.headers['Authorization'] = 'Bearer $token';
              
              try {
                final response = await _dio.fetch(options);
                handler.resolve(response);
                return;
              } catch (e) {
                // 刷新后仍然失败，清除token并跳转登录
                await _clearTokensAndRedirectToLogin();
              }
            } else {
              // 刷新失败，清除token并跳转登录
              await _clearTokensAndRedirectToLogin();
            }
          }
          
          handler.next(error);
        },
      ),
    );
    
    // 日志拦截器（仅在调试模式下）
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => print(obj),
        ),
      );
    }
  }
  
  /// 刷新token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = StorageService.getString(AppConstants.refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // 移除Authorization头
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        await StorageService.setString(AppConstants.accessTokenKey, data['access_token']);
        if (data['refresh_token'] != null) {
          await StorageService.setString(AppConstants.refreshTokenKey, data['refresh_token']);
        }
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    
    return false;
  }
  
  /// 清除token并跳转登录
  Future<void> _clearTokensAndRedirectToLogin() async {
    await StorageService.remove(AppConstants.accessTokenKey);
    await StorageService.remove(AppConstants.refreshTokenKey);
    await StorageService.remove(AppConstants.userInfoKey);
    
    // TODO: 跳转到登录页面
    // NavigationService.pushNamedAndClearStack(RouteConstants.login);
  }
  
  /// GET请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
  
  /// POST请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
  
  /// PUT请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
  
  /// DELETE请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
  
  /// 上传文件
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    return await _dio.post<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }
  
  /// 下载文件
  Future<Response> download(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.download(
      urlPath,
      savePath,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }
}