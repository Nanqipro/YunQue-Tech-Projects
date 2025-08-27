import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/reading_article.dart';
import '../models/reading_question.dart';
import '../models/reading_stats.dart';

/// 阅读服务类
class ReadingService {
  final ApiClient _apiClient = ApiClient.instance;

  /// 获取文章列表
  Future<List<ReadingArticle>> getArticles({
    String? category,
    String? difficulty,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.readingArticles,
        queryParameters: {
          if (category != null) 'category': category,
          if (difficulty != null) 'difficulty': difficulty,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ReadingArticle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

  /// 获取单篇文章详情
  Future<ReadingArticle> getArticle(String articleId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.readingArticles}/$articleId',
      );

      if (response.statusCode == 200) {
        return ReadingArticle.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load article');
      }
    } catch (e) {
      throw Exception('Error fetching article: $e');
    }
  }

  /// 获取文章练习题
  Future<ReadingExercise> getArticleExercise(String articleId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.reading}/exercises/$articleId',
      );

      if (response.statusCode == 200) {
        return ReadingExercise.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load exercise');
      }
    } catch (e) {
      throw Exception('Error fetching exercise: $e');
    }
  }

  /// 提交练习答案
  Future<ReadingExercise> submitExercise(ReadingExercise exercise) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.reading}/exercises/${exercise.id}/submit',
        data: exercise.toJson(),
      );

      if (response.statusCode == 200) {
        return ReadingExercise.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to submit exercise');
      }
    } catch (e) {
      throw Exception('Error submitting exercise: $e');
    }
  }

  /// 记录阅读进度
  Future<void> recordReadingProgress({
    required String articleId,
    required int readingTime,
    required bool completed,
    double? comprehensionScore,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.readingProgress,
        data: {
          'article_id': articleId,
          'reading_time': readingTime,
          'completed': completed,
          if (comprehensionScore != null) 'comprehension_score': comprehensionScore,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to record progress');
      }
    } catch (e) {
      throw Exception('Error recording progress: $e');
    }
  }

  /// 获取阅读统计
  Future<ReadingStats> getReadingStats() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.readingProgress,
      );

      if (response.statusCode == 200) {
        return ReadingStats.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load reading stats');
      }
    } catch (e) {
      throw Exception('Error fetching reading stats: $e');
    }
  }

  /// 获取推荐文章
  Future<List<ReadingArticle>> getRecommendedArticles({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.readingArticles}/recommended',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ReadingArticle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recommended articles');
      }
    } catch (e) {
      throw Exception('Error fetching recommended articles: $e');
    }
  }

  /// 搜索文章
  Future<List<ReadingArticle>> searchArticles({
    required String query,
    String? category,
    String? difficulty,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.readingArticles}/search',
        queryParameters: {
          'q': query,
          if (category != null) 'category': category,
          if (difficulty != null) 'difficulty': difficulty,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ReadingArticle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search articles');
      }
    } catch (e) {
      throw Exception('Error searching articles: $e');
    }
  }

  /// 收藏文章
  Future<void> favoriteArticle(String articleId) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.readingArticles}/$articleId/favorite',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to favorite article');
      }
    } catch (e) {
      throw Exception('Error favoriting article: $e');
    }
  }

  /// 取消收藏文章
  Future<void> unfavoriteArticle(String articleId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.readingArticles}/$articleId/favorite',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unfavorite article');
      }
    } catch (e) {
      throw Exception('Error unfavoriting article: $e');
    }
  }

  /// 获取收藏文章
  Future<List<ReadingArticle>> getFavoriteArticles({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.readingArticles}/favorites',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ReadingArticle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load favorite articles');
      }
    } catch (e) {
      throw Exception('Error fetching favorite articles: $e');
    }
  }

  /// 获取阅读历史
  Future<List<ReadingArticle>> getReadingHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.readingArticles}/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ReadingArticle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reading history');
      }
    } catch (e) {
      throw Exception('Error fetching reading history: $e');
    }
  }
}