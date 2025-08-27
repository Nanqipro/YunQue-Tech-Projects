/// API响应基础模型
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;
  final int? code;
  final Map<String, dynamic>? meta;
  
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.code,
    this.meta,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'] as String?,
      code: json['code'] as int?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'error': error,
      'code': code,
      'meta': meta,
    };
  }
  
  /// 成功响应
  factory ApiResponse.success({
    required String message,
    T? data,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      meta: meta,
    );
  }
  
  /// 失败响应
  factory ApiResponse.failure({
    required String message,
    String? error,
    int? code,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      error: error,
      code: code,
      meta: meta,
    );
  }
  
  /// 是否成功
  bool get isSuccess => success;
  
  /// 是否失败
  bool get isFailure => !success;
  
  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data, error: $error)';
  }
}

/// 分页响应模型
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta pagination;
  
  const PaginatedResponse({
    required this.data,
    required this.pagination,
  });
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'pagination': pagination.toJson(),
    };
  }
}

/// 分页元数据模型
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;
  
  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
  
  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalItems: json['total_items'] as int,
      itemsPerPage: json['items_per_page'] as int,
      hasNextPage: json['has_next_page'] as bool,
      hasPreviousPage: json['has_previous_page'] as bool,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }
}

/// 认证响应模型
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final Map<String, dynamic>? user;
  
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int,
      user: json['user'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user,
    };
  }
}

/// 错误响应模型
class ErrorResponse {
  final String message;
  final String? code;
  final List<ValidationError>? validationErrors;
  final Map<String, dynamic>? details;
  
  const ErrorResponse({
    required this.message,
    this.code,
    this.validationErrors,
    this.details,
  });
  
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] as String,
      code: json['code'] as String?,
      validationErrors: json['validation_errors'] != null
          ? (json['validation_errors'] as List)
              .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      details: json['details'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
      'validation_errors': validationErrors?.map((e) => e.toJson()).toList(),
      'details': details,
    };
  }
}

/// 验证错误模型
class ValidationError {
  final String field;
  final String message;
  final String? code;
  
  const ValidationError({
    required this.field,
    required this.message,
    this.code,
  });
  
  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] as String,
      message: json['message'] as String,
      code: json['code'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
      'code': code,
    };
  }
}