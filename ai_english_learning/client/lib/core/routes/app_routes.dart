import 'package:flutter/material.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/listening/screens/listening_home_screen.dart';
import '../../features/speaking/screens/speaking_screen.dart';
import '../widgets/not_found_screen.dart';

/// 路由名称常量
class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String vocabularyHome = '/vocabulary';
  static const String vocabularyList = '/vocabulary/list';
  static const String wordDetail = '/vocabulary/word';
  static const String vocabularyTest = '/vocabulary/test';
  static const String wordLearning = '/vocabulary/learning';
  static const String listeningHome = '/listening';
  static const String listeningExercise = '/listening/exercise';
  static const String readingHome = '/reading';
  static const String readingExercise = '/reading/exercise';
  static const String writingHome = '/writing';
  static const String writingExercise = '/writing/exercise';
  static const String speakingHome = '/speaking';
  static const String speakingExercise = '/speaking/exercise';
}

/// 应用路由配置
class AppRoutes {
  /// 路由映射表
  static final Map<String, WidgetBuilder> _routes = {
    Routes.splash: (context) => const SplashScreen(),
    Routes.listeningHome: (context) => const ListeningHomeScreen(),
    Routes.speakingHome: (context) => const SpeakingScreen(),
    // TODO: 添加其他页面路由
    // Routes.login: (context) => const LoginScreen(),
    // Routes.register: (context) => const RegisterScreen(),
    // Routes.home: (context) => const HomeScreen(),
  };
  
  /// 获取路由映射表
  static Map<String, WidgetBuilder> get routes => _routes;
  
  /// 路由生成器
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '';
    
    // 默认路由处理
    final WidgetBuilder? builder = _routes[routeName];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    
    // 未找到路由时的处理
    return MaterialPageRoute(
      builder: (context) => const NotFoundScreen(),
      settings: settings,
    );
  }
  
  /// 路由守卫 - 检查是否需要认证
  static bool requiresAuth(String routeName) {
    const publicRoutes = [
      Routes.splash,
      Routes.login,
      Routes.register,
      Routes.forgotPassword,
    ];
    
    return !publicRoutes.contains(routeName);
  }
  
  /// 获取初始路由
  static String getInitialRoute(bool isLoggedIn) {
    return isLoggedIn ? Routes.home : Routes.splash;
  }
}

/// 启动页面
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // TODO: 检查用户登录状态
    // TODO: 初始化应用配置
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // TODO: 根据登录状态导航到相应页面
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: 添加应用Logo
            Icon(
              Icons.school,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'AI英语学习',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '智能化英语学习平台',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// 404页面
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              '404',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '抱歉，您访问的页面不存在',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.home,
                  (route) => false,
                );
              },
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 路由导航辅助类
class AppNavigator {
  /// 导航到指定页面
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }
  
  /// 替换当前页面
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }
  
  /// 清空栈并导航到指定页面
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }
  
  /// 返回上一页
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }
  
  /// 返回到指定页面
  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }
  
  /// 检查是否可以返回
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}