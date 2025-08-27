import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_error.dart';
import '../models/api_response.dart';
import '../models/vocabulary_model.dart';

/// 词汇服务
class VocabularyService {
  static final VocabularyService _instance = VocabularyService._internal();
  factory VocabularyService() => _instance;
  VocabularyService._internal();
  
  final ApiClient _apiClient = ApiClient.instance;
  
  /// 获取词库列表
  Future<ApiResponse<List<VocabularyBookModel>>> getVocabularyBooks({
    String? category,
    String? level,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (category != null) queryParams['category'] = category;
      if (level != null) queryParams['level'] = level;
      
      final response = await _apiClient.get(
        '/vocabulary/books',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> booksJson = response.data['data']['items'];
        final books = booksJson
            .map((json) => VocabularyBookModel.fromJson(json))
            .toList();
        
        return ApiResponse.success(
          message: 'Vocabulary books retrieved successfully',
          data: books,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to get vocabulary books',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to get vocabulary books: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 获取词汇列表
  Future<ApiResponse<PaginatedResponse<VocabularyModel>>> getVocabularies({
    String? bookId,
    String? search,
    String? level,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (bookId != null) queryParams['book_id'] = bookId;
      if (search != null) queryParams['search'] = search;
      if (level != null) queryParams['level'] = level;
      
      final response = await _apiClient.get(
        '/vocabulary/words',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final paginatedResponse = PaginatedResponse<VocabularyModel>.fromJson(
          response.data['data'],
          (json) => VocabularyModel.fromJson(json),
        );
        
        return ApiResponse.success(
          message: 'Vocabularies retrieved successfully',
          data: paginatedResponse,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to get vocabularies',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to get vocabularies: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 获取单词详情
  Future<ApiResponse<VocabularyModel>> getWordDetail(String wordId) async {
    try {
      final response = await _apiClient.get('/vocabulary/words/$wordId');
      
      if (response.statusCode == 200) {
        final word = VocabularyModel.fromJson(response.data['data']);
        
        return ApiResponse.success(
          message: 'Word detail retrieved successfully',
          data: word,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to get word detail',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to get word detail: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 获取用户词汇学习记录
  Future<ApiResponse<PaginatedResponse<UserVocabularyModel>>> getUserVocabularies({
    LearningStatus? status,
    String? bookId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (status != null) queryParams['status'] = status.name;
      if (bookId != null) queryParams['book_id'] = bookId;
      
      final response = await _apiClient.get(
        '/vocabulary/user-words',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final paginatedResponse = PaginatedResponse<UserVocabularyModel>.fromJson(
          response.data['data'],
          (json) => UserVocabularyModel.fromJson(json),
        );
        
        return ApiResponse.success(
          message: 'User vocabularies retrieved successfully',
          data: paginatedResponse,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to get user vocabularies',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to get user vocabularies: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 更新单词学习状态
  Future<ApiResponse<UserVocabularyModel>> updateWordStatus({
    required String wordId,
    required LearningStatus status,
    int? correctCount,
    int? wrongCount,
    int? reviewCount,
    DateTime? nextReviewDate,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = <String, dynamic>{
        'status': status.name,
      };
      
      if (correctCount != null) data['correct_count'] = correctCount;
      if (wrongCount != null) data['wrong_count'] = wrongCount;
      if (reviewCount != null) data['review_count'] = reviewCount;
      if (nextReviewDate != null) {
        data['next_review_date'] = nextReviewDate.toIso8601String();
      }
      if (metadata != null) data['metadata'] = metadata;
      
      final response = await _apiClient.put(
        '/vocabulary/user-words/$wordId',
        data: data,
      );
      
      if (response.statusCode == 200) {
        final userWord = UserVocabularyModel.fromJson(response.data['data']);
        
        return ApiResponse.success(
          message: response.data['message'] ?? 'Word status updated successfully',
          data: userWord,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to update word status',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to update word status: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 添加单词到学习列表
  Future<ApiResponse<UserVocabularyModel>> addWordToLearning(String wordId) async {
    try {
      final response = await _apiClient.post(
        '/vocabulary/user-words',
        data: {'word_id': wordId},
      );
      
      if (response.statusCode == 201) {
        final userWord = UserVocabularyModel.fromJson(response.data['data']);
        
        return ApiResponse.success(
          message: response.data['message'] ?? 'Word added to learning list',
          data: userWord,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to add word to learning list',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to add word to learning list: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 从学习列表移除单词
  Future<ApiResponse<void>> removeWordFromLearning(String wordId) async {
    try {
      final response = await _apiClient.delete('/vocabulary/user-words/$wordId');
      
      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: response.data['message'] ?? 'Word removed from learning list',
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to remove word from learning list',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to remove word from learning list: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 获取今日复习单词
  Future<ApiResponse<List<UserVocabularyModel>>> getTodayReviewWords() async {
    try {
      final response = await _apiClient.get('/vocabulary/today-review');
      
      if (response.statusCode == 200) {
        final List<dynamic> wordsJson = response.data['data'];
        final words = wordsJson
            .map((json) => UserVocabularyModel.fromJson(json))
            .toList();
        
        return ApiResponse.success(
          message: 'Today review words retrieved successfully',
          data: words,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to get today review words',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to get today review words: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 获取新单词学习
  Future<ApiResponse<List<VocabularyModel>>> getNewWordsForLearning({
    String? bookId,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      
      if (bookId != null) queryParams['book_id'] = bookId;
      
      final response = await _apiClient.get(
        '/vocabulary/new-words',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> wordsJson = response.data['data'];
        final words = wordsJson
            .map((json) => VocabularyModel.fromJson(json))
            .toList();
        
        return ApiResponse.success(
          message: 'New words for learning retrieved successfully',
          data: words,
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to get new words for learning',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to get new words for learning: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 词汇量测试
  Future<ApiResponse<Map<String, dynamic>>> vocabularyTest({
    required List<String> wordIds,
    required List<String> answers,
  }) async {
    try {
      final response = await _apiClient.post(
        '/vocabulary/test',
        data: {
          'word_ids': wordIds,
          'answers': answers,
        },
      );
      
      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: 'Vocabulary test completed successfully',
          data: response.data['data'],
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Vocabulary test failed',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Vocabulary test failed: $e',
        error: e.toString(),
      );
    }
  }
  
  /// 获取学习统计
  Future<ApiResponse<Map<String, dynamic>>> getLearningStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      
      final response = await _apiClient.get(
        '/vocabulary/stats',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: 'Learning stats retrieved successfully',
          data: response.data['data'],
        );
      } else {
        return ApiResponse.failure(
          message: response.data['message'] ?? 'Failed to get learning stats',
          code: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.failure(
        message: 'Failed to get learning stats: $e',
        error: e.toString(),
      );
    }
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