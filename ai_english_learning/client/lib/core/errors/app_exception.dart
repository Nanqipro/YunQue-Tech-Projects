/// 应用异常基类
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() {
    return 'AppException: $message';
  }
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.details,
  });
}

/// 认证异常
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.details,
  });
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.code,
    super.details,
  });
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.code,
    super.details,
  });
}

/// 验证异常
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    super.details,
  });
}