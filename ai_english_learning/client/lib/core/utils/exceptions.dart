/// 应用异常基类
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});

  @override
  String toString() => 'NetworkException: $message';
}

/// 认证异常
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});

  @override
  String toString() => 'AuthException: $message';
}

/// 验证异常
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});

  @override
  String toString() => 'ValidationException: $message';
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.details});

  @override
  String toString() => 'ServerException: $message';
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.details});

  @override
  String toString() => 'CacheException: $message';
}

/// 文件异常
class FileException extends AppException {
  const FileException(super.message, {super.code, super.details});

  @override
  String toString() => 'FileException: $message';
}

/// 权限异常
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code, super.details});

  @override
  String toString() => 'PermissionException: $message';
}

/// 业务逻辑异常
class BusinessException extends AppException {
  const BusinessException(super.message, {super.code, super.details});

  @override
  String toString() => 'BusinessException: $message';
}

/// 超时异常
class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code, super.details});

  @override
  String toString() => 'TimeoutException: $message';
}

/// 数据解析异常
class ParseException extends AppException {
  const ParseException(super.message, {super.code, super.details});

  @override
  String toString() => 'ParseException: $message';
}

/// 通用应用异常
class GeneralAppException extends AppException {
  const GeneralAppException(super.message, {super.code, super.details});

  @override
  String toString() => 'GeneralAppException: $message';
}

/// 异常处理工具类
class ExceptionHandler {
  /// 处理异常并返回用户友好的错误信息
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is Exception) {
      return '发生了未知错误，请稍后重试';
    } else {
      return '系统错误，请联系客服';
    }
  }

  /// 记录异常
  static void logException(dynamic error, {StackTrace? stackTrace}) {
    // 这里可以集成日志记录服务，如Firebase Crashlytics
    print('Exception: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }

  /// 判断是否为网络相关异常
  static bool isNetworkError(dynamic error) {
    return error is NetworkException || 
           error is TimeoutException ||
           (error is AppException && error.code?.contains('network') == true);
  }

  /// 判断是否为认证相关异常
  static bool isAuthError(dynamic error) {
    return error is AuthException ||
           (error is AppException && error.code?.contains('auth') == true);
  }

  /// 判断是否为验证相关异常
  static bool isValidationError(dynamic error) {
    return error is ValidationException ||
           (error is AppException && error.code?.contains('validation') == true);
  }
}