import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/listening_exercise_model.dart';

/// 听力训练服务
class ListeningService {
  static const String _baseUrl = 'https://api.example.com/listening';

  /// 获取听力练习列表
  static Future<List<ListeningExercise>> getListeningExercises({
    ListeningExerciseType? type,
    ListeningDifficulty? difficulty,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (type != null) {
        queryParams['type'] = type.name;
      }
      
      if (difficulty != null) {
        queryParams['difficulty'] = difficulty.name;
      }

      final uri = Uri.parse('$_baseUrl/exercises').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> exercisesJson = data['data'] ?? [];
        return exercisesJson
            .map((json) => ListeningExercise.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load listening exercises: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting listening exercises: $e');
      rethrow;
    }
  }

  /// 获取单个听力练习详情
  static Future<ListeningExercise> getListeningExercise(String exerciseId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/$exerciseId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListeningExercise.fromJson(data['data']);
      } else {
        throw Exception('Failed to load listening exercise: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting listening exercise: $e');
      rethrow;
    }
  }

  /// 提交听力练习答案
  static Future<ListeningExerciseResult> submitListeningExercise({
    required String exerciseId,
    required String userId,
    required List<String> userAnswers,
    required int timeSpent,
    required int playCount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/exercises/$exerciseId/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'userAnswers': userAnswers,
          'timeSpent': timeSpent,
          'playCount': playCount,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListeningExerciseResult.fromJson(data['data']);
      } else {
        throw Exception('Failed to submit listening exercise: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting listening exercise: $e');
      rethrow;
    }
  }

  /// 获取用户听力练习历史
  static Future<List<ListeningExerciseResult>> getUserListeningHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$_baseUrl/users/$userId/history').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> historyJson = data['data'] ?? [];
        return historyJson
            .map((json) => ListeningExerciseResult.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load listening history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting listening history: $e');
      rethrow;
    }
  }

  /// 获取用户听力学习统计
  static Future<ListeningStatistics> getUserListeningStatistics(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ListeningStatistics.fromJson(data['data']);
      } else {
        throw Exception('Failed to load listening statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting listening statistics: $e');
      rethrow;
    }
  }

  /// 搜索听力练习
  static Future<List<ListeningExercise>> searchListeningExercises({
    required String query,
    ListeningExerciseType? type,
    ListeningDifficulty? difficulty,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (type != null) {
        queryParams['type'] = type.name;
      }
      
      if (difficulty != null) {
        queryParams['difficulty'] = difficulty.name;
      }

      final uri = Uri.parse('$_baseUrl/exercises/search').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> exercisesJson = data['data'] ?? [];
        return exercisesJson
            .map((json) => ListeningExercise.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to search listening exercises: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching listening exercises: $e');
      rethrow;
    }
  }

  /// 获取推荐的听力练习
  static Future<List<ListeningExercise>> getRecommendedListeningExercises({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$_baseUrl/users/$userId/recommendations').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> exercisesJson = data['data'] ?? [];
        return exercisesJson
            .map((json) => ListeningExercise.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load recommended exercises: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting recommended exercises: $e');
      rethrow;
    }
  }
}