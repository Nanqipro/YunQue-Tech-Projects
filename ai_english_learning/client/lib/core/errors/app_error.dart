/// 应用错误基类
abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });
  
  @override
  String toString() {
    return 'AppError(message: $message, code: $code)';
  }
}

/// 网络错误
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
  });
  
  factory NetworkError.connectionTimeout() {
    return const NetworkError(
      message: '连接超时，请检查网络连接',
      code: 'CONNECTION_TIMEOUT',
    );
  }
  
  factory NetworkError.noInternet() {
    return const NetworkError(
      message: '网络连接不可用，请检查网络设置',
      code: 'NO_INTERNET',
    );
  }
  
  factory NetworkError.serverError(int statusCode, [String? message]) {
    return NetworkError(
      message: message ?? '服务器错误 ($statusCode)',
      code: 'SERVER_ERROR_$statusCode',
    );
  }
  
  factory NetworkError.unknown([dynamic error]) {
    return NetworkError(
      message: '网络请求失败',
      code: 'UNKNOWN_NETWORK_ERROR',
      originalError: error,
    );
  }
}

/// 认证错误
class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.code,
    super.originalError,
  });
  
  factory AuthError.unauthorized() {
    return const AuthError(
      message: '未授权访问，请重新登录',
      code: 'UNAUTHORIZED',
    );
  }
  
  factory AuthError.tokenExpired() {
    return const AuthError(
      message: '登录已过期，请重新登录',
      code: 'TOKEN_EXPIRED',
    );
  }
  
  factory AuthError.invalidCredentials() {
    return const AuthError(
      message: '用户名或密码错误',
      code: 'INVALID_CREDENTIALS',
    );
  }
  
  factory AuthError.accountLocked() {
    return const AuthError(
      message: '账户已被锁定，请联系客服',
      code: 'ACCOUNT_LOCKED',
    );
  }
}

/// 验证错误
class ValidationError extends AppError {
  final Map<String, List<String>>? fieldErrors;
  
  const ValidationError({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });
  
  factory ValidationError.required(String field) {
    return ValidationError(
      message: '$field不能为空',
      code: 'FIELD_REQUIRED',
      fieldErrors: {field: ['不能为空']},
    );
  }
  
  factory ValidationError.invalid(String field, String reason) {
    return ValidationError(
      message: '$field格式不正确：$reason',
      code: 'FIELD_INVALID',
      fieldErrors: {field: [reason]},
    );
  }
  
  factory ValidationError.multiple(Map<String, List<String>> errors) {
    return ValidationError(
      message: '表单验证失败',
      code: 'VALIDATION_FAILED',
      fieldErrors: errors,
    );
  }
}

/// 业务逻辑错误
class BusinessError extends AppError {
  const BusinessError({
    required super.message,
    super.code,
    super.originalError,
  });
  
  factory BusinessError.notFound(String resource) {
    return BusinessError(
      message: '$resource不存在',
      code: 'RESOURCE_NOT_FOUND',
    );
  }
  
  factory BusinessError.alreadyExists(String resource) {
    return BusinessError(
      message: '$resource已存在',
      code: 'RESOURCE_ALREADY_EXISTS',
    );
  }
  
  factory BusinessError.operationNotAllowed(String operation) {
    return BusinessError(
      message: '不允许执行操作：$operation',
      code: 'OPERATION_NOT_ALLOWED',
    );
  }
  
  factory BusinessError.quotaExceeded(String resource) {
    return BusinessError(
      message: '$resource配额已用完',
      code: 'QUOTA_EXCEEDED',
    );
  }
}

/// 存储错误
class StorageError extends AppError {
  const StorageError({
    required super.message,
    super.code,
    super.originalError,
  });
  
  factory StorageError.readFailed(String key) {
    return StorageError(
      message: '读取数据失败：$key',
      code: 'STORAGE_READ_FAILED',
    );
  }
  
  factory StorageError.writeFailed(String key) {
    return StorageError(
      message: '写入数据失败：$key',
      code: 'STORAGE_WRITE_FAILED',
    );
  }
  
  factory StorageError.notInitialized() {
    return const StorageError(
      message: '存储服务未初始化',
      code: 'STORAGE_NOT_INITIALIZED',
    );
  }
}

/// 文件错误
class FileError extends AppError {
  const FileError({
    required super.message,
    super.code,
    super.originalError,
  });
  
  factory FileError.notFound(String path) {
    return FileError(
      message: '文件不存在：$path',
      code: 'FILE_NOT_FOUND',
    );
  }
  
  factory FileError.accessDenied(String path) {
    return FileError(
      message: '文件访问被拒绝：$path',
      code: 'FILE_ACCESS_DENIED',
    );
  }
  
  factory FileError.formatNotSupported(String format) {
    return FileError(
      message: '不支持的文件格式：$format',
      code: 'FILE_FORMAT_NOT_SUPPORTED',
    );
  }
  
  factory FileError.sizeTooLarge(int size, int maxSize) {
    return FileError(
      message: '文件大小超出限制：${size}B > ${maxSize}B',
      code: 'FILE_SIZE_TOO_LARGE',
    );
  }
}

/// 音频错误
class AudioError extends AppError {
  const AudioError({
    required super.message,
    super.code,
    super.originalError,
  });
  
  factory AudioError.playbackFailed() {
    return const AudioError(
      message: '音频播放失败',
      code: 'AUDIO_PLAYBACK_FAILED',
    );
  }
  
  factory AudioError.recordingFailed() {
    return const AudioError(
      message: '音频录制失败',
      code: 'AUDIO_RECORDING_FAILED',
    );
  }
  
  factory AudioError.permissionDenied() {
    return const AudioError(
      message: '音频权限被拒绝',
      code: 'AUDIO_PERMISSION_DENIED',
    );
  }
}

/// 学习相关错误
class LearningError extends AppError {
  const LearningError({
    required super.message,
    super.code,
    super.originalError,
  });
  
  factory LearningError.progressNotFound() {
    return const LearningError(
      message: '学习进度不存在',
      code: 'LEARNING_PROGRESS_NOT_FOUND',
    );
  }
  
  factory LearningError.vocabularyNotFound() {
    return const LearningError(
      message: '词汇不存在',
      code: 'VOCABULARY_NOT_FOUND',
    );
  }
  
  factory LearningError.testNotCompleted() {
    return const LearningError(
      message: '测试未完成',
      code: 'TEST_NOT_COMPLETED',
    );
  }
  
  factory LearningError.levelNotUnlocked() {
    return const LearningError(
      message: '等级未解锁',
      code: 'LEVEL_NOT_UNLOCKED',
    );
  }
}