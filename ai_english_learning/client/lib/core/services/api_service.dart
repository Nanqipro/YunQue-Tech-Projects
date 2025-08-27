import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class ApiResponse {
  final dynamic data;
  final int statusCode;
  final String? message;

  ApiResponse({
    required this.data,
    required this.statusCode,
    this.message,
  });
}

class ApiService {
  late final Dio _dio;
  final StorageService _storageService;
  static const String baseUrl = 'https://api.yunque-english.com';

  ApiService({required StorageService storageService})
      : _storageService = storageService {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加认证token
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        if (kDebugMode) {
          print('API Request: ${options.method} ${options.uri}');
          print('Headers: ${options.headers}');
          if (options.data != null) {
            print('Data: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('API Response: ${response.statusCode} ${response.requestOptions.uri}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('API Error: ${error.message}');
          print('Response: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));
  }

  // GET请求
  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
        options: options,
      );
      return ApiResponse(
        data: response.data,
        statusCode: response.statusCode ?? 200,
        message: response.statusMessage,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST请求
  Future<ApiResponse> post(
    String path,
    dynamic data, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      return ApiResponse(
        data: response.data,
        statusCode: response.statusCode ?? 200,
        message: response.statusMessage,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT请求
  Future<ApiResponse> put(
    String path,
    dynamic data, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      return ApiResponse(
        data: response.data,
        statusCode: response.statusCode ?? 200,
        message: response.statusMessage,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH请求
  Future<ApiResponse> patch(
    String path,
    dynamic data, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      return ApiResponse(
        data: response.data,
        statusCode: response.statusCode ?? 200,
        message: response.statusMessage,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE请求
  Future<ApiResponse> delete(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParams,
        options: options,
      );
      return ApiResponse(
        data: response.data,
        statusCode: response.statusCode ?? 200,
        message: response.statusMessage,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 上传文件
  Future<ApiResponse> uploadFile(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: onSendProgress,
      );

      return ApiResponse(
        data: response.data,
        statusCode: response.statusCode ?? 200,
        message: response.statusMessage,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 下载文件
  Future<void> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 错误处理
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('网络连接超时，请检查网络设置');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? '请求失败';
        switch (statusCode) {
          case 400:
            return Exception('请求参数错误: $message');
          case 401:
            return Exception('认证失败，请重新登录');
          case 403:
            return Exception('权限不足: $message');
          case 404:
            return Exception('请求的资源不存在');
          case 500:
            return Exception('服务器内部错误，请稍后重试');
          default:
            return Exception('请求失败($statusCode): $message');
        }
      case DioExceptionType.cancel:
        return Exception('请求已取消');
      case DioExceptionType.connectionError:
        return Exception('网络连接失败，请检查网络设置');
      case DioExceptionType.unknown:
      default:
        return Exception('未知错误: ${error.message}');
    }
  }

  // 取消所有请求
  void cancelRequests() {
    _dio.close();
  }
}