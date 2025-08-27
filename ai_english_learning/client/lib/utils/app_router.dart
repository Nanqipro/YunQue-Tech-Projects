import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/vocabulary/vocabulary_screen.dart';
import '../screens/vocabulary/vocabulary_study_screen.dart';
import '../screens/listening/listening_screen.dart';
import '../screens/listening/listening_practice_screen.dart';
import '../screens/reading/reading_screen.dart';
import '../screens/writing/writing_screen.dart';
import '../screens/speaking/speaking_screen.dart';
import '../constants/app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      // 主页面
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainScreen(),
      ),
      
      // 个人主页
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // 单词学习模块
      GoRoute(
        path: AppRoutes.vocabulary,
        builder: (context, state) => const VocabularyScreen(),
      ),
      GoRoute(
        path: AppRoutes.vocabularyStudy,
        builder: (context, state) {
          final bookId = state.uri.queryParameters['bookId'] ?? '';
          return VocabularyStudyScreen(bookId: bookId);
        },
      ),
      
      // 听力训练模块
      GoRoute(
        path: AppRoutes.listening,
        builder: (context, state) => const ListeningScreen(),
      ),
      GoRoute(
        path: AppRoutes.listeningPractice,
        builder: (context, state) {
          final lessonId = state.uri.queryParameters['lessonId'] ?? '';
          return ListeningPracticeScreen(lessonId: lessonId);
        },
      ),
      
      // 阅读理解模块
      GoRoute(
        path: AppRoutes.reading,
        builder: (context, state) => const ReadingScreen(),
      ),
      
      // 写作练习模块
      GoRoute(
        path: AppRoutes.writing,
        builder: (context, state) => const WritingScreen(),
      ),
      
      // 口语练习模块
      GoRoute(
        path: AppRoutes.speaking,
        builder: (context, state) => const SpeakingScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '页面未找到: ${state.uri.path}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}