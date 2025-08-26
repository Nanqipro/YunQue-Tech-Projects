# Flutter 跨平台应用开发完整教程

## 目录
1. [环境搭建](#环境搭建)
2. [创建第一个 Flutter 项目](#创建第一个-flutter-项目)
3. [项目结构解析](#项目结构解析)
4. [开发一个完整的交互应用](#开发一个完整的交互应用)
5. [运行和调试](#运行和调试)
6. [打包发布](#打包发布)

## 环境搭建

### 1. 安装 Flutter SDK

#### Linux 系统安装步骤：

```bash
# 1. 下载 Flutter SDK
cd ~/
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz

# 2. 解压
tar xf flutter_linux_3.16.0-stable.tar.xz

# 3. 添加到环境变量
echo 'export PATH="$PATH:`pwd`/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# 4. 验证安装
flutter --version
```

### 2. 安装依赖

```bash
# 安装必要的依赖
sudo apt-get update
sudo apt-get install curl git unzip xz-utils zip libglu1-mesa

# 安装 Android Studio 或 Android SDK（可选，用于 Android 开发）
# 这里我们主要关注 Web 和桌面应用
```

### 3. 配置开发环境

```bash
# 运行 Flutter 医生检查环境
flutter doctor

# 启用 Web 和桌面支持
flutter config --enable-web
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
```

### 4. VS Code 配置

在 VS Code 中安装以下插件：
- Flutter
- Dart
- Flutter Widget Snippets

## 创建第一个 Flutter 项目

### 1. 创建项目

```bash
# 进入工作目录
cd /home/nanqipro01/gitlocal/YunQue-Tech-Projects/ai_english_learning

# 创建 Flutter 项目
flutter create flutter_learning_app

# 进入项目目录
cd flutter_learning_app
```

### 2. 项目初始化

```bash
# 获取依赖
flutter pub get

# 运行项目（Web 版本）
flutter run -d web-server --web-port 8080
```

## 项目结构解析

```
flutter_learning_app/
├── lib/                 # 主要代码目录
│   ├── main.dart       # 应用入口文件
│   ├── models/         # 数据模型
│   ├── screens/        # 页面文件
│   ├── widgets/        # 自定义组件
│   └── services/       # 服务层
├── assets/             # 资源文件
│   ├── images/
│   └── fonts/
├── test/               # 测试文件
├── pubspec.yaml        # 项目配置文件
└── README.md
```

## 开发一个完整的交互应用

我们将开发一个英语学习应用，包含以下功能：
- 用户登录/注册
- 单词学习
- 练习测试
- 进度跟踪

### 1. 更新 pubspec.yaml

```yaml
name: flutter_learning_app
description: A Flutter English Learning App
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  sqflite: ^2.3.0
  path: ^1.8.3
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/data/
```

### 2. 创建数据模型

创建 `lib/models/user.dart`：

```dart
class User {
  final int? id;
  final String username;
  final String email;
  final int level;
  final int score;

  User({
    this.id,
    required this.username,
    required this.email,
    this.level = 1,
    this.score = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'level': level,
      'score': score,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      level: map['level'],
      score: map['score'],
    );
  }
}
```

创建 `lib/models/word.dart`：

```dart
class Word {
  final int? id;
  final String english;
  final String chinese;
  final String pronunciation;
  final String example;
  final int difficulty;
  bool isLearned;

  Word({
    this.id,
    required this.english,
    required this.chinese,
    required this.pronunciation,
    required this.example,
    this.difficulty = 1,
    this.isLearned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'chinese': chinese,
      'pronunciation': pronunciation,
      'example': example,
      'difficulty': difficulty,
      'isLearned': isLearned ? 1 : 0,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      english: map['english'],
      chinese: map['chinese'],
      pronunciation: map['pronunciation'],
      example: map['example'],
      difficulty: map['difficulty'],
      isLearned: map['isLearned'] == 1,
    );
  }
}
```

### 3. 创建数据库服务

创建 `lib/services/database_service.dart`：

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/word.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'learning_app.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        level INTEGER DEFAULT 1,
        score INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        english TEXT NOT NULL,
        chinese TEXT NOT NULL,
        pronunciation TEXT NOT NULL,
        example TEXT NOT NULL,
        difficulty INTEGER DEFAULT 1,
        isLearned INTEGER DEFAULT 0
      )
    ''');

    // 插入示例数据
    await _insertSampleWords(db);
  }

  Future<void> _insertSampleWords(Database db) async {
    List<Map<String, dynamic>> sampleWords = [
      {
        'english': 'hello',
        'chinese': '你好',
        'pronunciation': '/həˈloʊ/',
        'example': 'Hello, how are you?',
        'difficulty': 1
      },
      {
        'english': 'world',
        'chinese': '世界',
        'pronunciation': '/wɜːrld/',
        'example': 'Welcome to the world of programming.',
        'difficulty': 1
      },
      {
        'english': 'learning',
        'chinese': '学习',
        'pronunciation': '/ˈlɜːrnɪŋ/',
        'example': 'Learning English is fun.',
        'difficulty': 2
      },
    ];

    for (var word in sampleWords) {
      await db.insert('words', word);
    }
  }

  // 用户相关操作
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // 单词相关操作
  Future<List<Word>> getAllWords() async {
    final db = await database;
    final maps = await db.query('words');
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<void> updateWordLearned(int wordId, bool isLearned) async {
    final db = await database;
    await db.update(
      'words',
      {'isLearned': isLearned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [wordId],
    );
  }
}
```

### 4. 创建状态管理

创建 `lib/providers/app_provider.dart`：

```dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/word.dart';
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  List<Word> _words = [];
  int _currentWordIndex = 0;
  final DatabaseService _databaseService = DatabaseService();

  User? get currentUser => _currentUser;
  List<Word> get words => _words;
  Word? get currentWord => _words.isNotEmpty ? _words[_currentWordIndex] : null;
  int get currentWordIndex => _currentWordIndex;
  int get learnedWordsCount => _words.where((w) => w.isLearned).length;

  Future<bool> login(String email, String username) async {
    try {
      User? user = await _databaseService.getUser(email);
      if (user == null) {
        // 创建新用户
        user = User(username: username, email: email);
        await _databaseService.insertUser(user);
        user = await _databaseService.getUser(email);
      }
      _currentUser = user;
      await loadWords();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadWords() async {
    _words = await _databaseService.getAllWords();
    notifyListeners();
  }

  void nextWord() {
    if (_currentWordIndex < _words.length - 1) {
      _currentWordIndex++;
      notifyListeners();
    }
  }

  void previousWord() {
    if (_currentWordIndex > 0) {
      _currentWordIndex--;
      notifyListeners();
    }
  }

  Future<void> markWordAsLearned(int wordId) async {
    await _databaseService.updateWordLearned(wordId, true);
    final wordIndex = _words.indexWhere((w) => w.id == wordId);
    if (wordIndex != -1) {
      _words[wordIndex].isLearned = true;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _words.clear();
    _currentWordIndex = 0;
    notifyListeners();
  }
}
```

### 5. 创建登录页面

创建 `lib/screens/login_screen.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.purple.shade400],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school,
                        size: 64,
                        color: Colors.blue.shade600,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '英语学习助手',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 32),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: '用户名',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入用户名';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: '邮箱',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入邮箱';
                          }
                          if (!value.contains('@')) {
                            return '请输入有效的邮箱地址';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  '登录/注册',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final provider = Provider.of<AppProvider>(context, listen: false);
      bool success = await provider.login(
        _emailController.text,
        _usernameController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败，请重试')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
```

### 6. 创建主页面

创建 `lib/screens/home_screen.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'learning_screen.dart';
import 'progress_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      LearningScreen(),
      ProgressScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('英语学习助手'),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('退出登录'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: '学习',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: '进度',
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() {
    Provider.of<AppProvider>(context, listen: false).logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
```

### 7. 创建学习页面

创建 `lib/screens/learning_screen.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/word.dart';

class LearningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.words.isEmpty) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        Word? currentWord = provider.currentWord;
        if (currentWord == null) {
          return Center(
            child: Text('没有可学习的单词'),
          );
        }

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // 进度指示器
              LinearProgressIndicator(
                value: (provider.currentWordIndex + 1) / provider.words.length,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
              SizedBox(height: 8),
              Text(
                '${provider.currentWordIndex + 1} / ${provider.words.length}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 32),
              
              // 单词卡片
              Expanded(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: currentWord.isLearned
                            ? [Colors.green.shade100, Colors.green.shade200]
                            : [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (currentWord.isLearned)
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 32,
                          ),
                        SizedBox(height: 16),
                        Text(
                          currentWord.english,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          currentWord.pronunciation,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 24),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentWord.chinese,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '例句:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                currentWord.example,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // 控制按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: provider.currentWordIndex > 0
                        ? provider.previousWord
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  
                  if (!currentWord.isLearned)
                    ElevatedButton(
                      onPressed: () {
                        provider.markWordAsLearned(currentWord.id!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '已掌握',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  
                  ElevatedButton(
                    onPressed: provider.currentWordIndex < provider.words.length - 1
                        ? provider.nextWord
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 8. 创建进度页面

创建 `lib/screens/progress_screen.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        int totalWords = provider.words.length;
        int learnedWords = provider.learnedWordsCount;
        double progress = totalWords > 0 ? learnedWords / totalWords : 0;

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息卡片
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade600,
                        child: Text(
                          provider.currentUser?.username.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.currentUser?.username ?? '用户',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              provider.currentUser?.email ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '等级: ${provider.currentUser?.level ?? 1}',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // 学习进度
              Text(
                '学习进度',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '已掌握单词',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '$learnedWords / $totalWords',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green.shade600,
                        ),
                        minHeight: 8,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}% 完成',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // 统计信息
              Text(
                '学习统计',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '总单词数',
                      totalWords.toString(),
                      Icons.book,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '已掌握',
                      learnedWords.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '待学习',
                      (totalWords - learnedWords).toString(),
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '完成率',
                      '${(progress * 100).toStringAsFixed(0)}%',
                      Icons.analytics,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

### 9. 更新主入口文件

更新 `lib/main.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'Flutter 英语学习应用',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

## 运行和调试

### 1. 安装依赖

```bash
cd flutter_learning_app
flutter pub get
```

### 2. 运行应用

```bash
# Web 版本
flutter run -d web-server --web-port 8080

# 桌面版本（Linux）
flutter run -d linux

# 如果有 Android 设备或模拟器
flutter run -d android
```

### 3. 调试技巧

- 使用 `flutter doctor` 检查环境
- 使用 `flutter logs` 查看日志
- 在 VS Code 中设置断点进行调试
- 使用 Flutter Inspector 查看 Widget 树

## 打包发布

### Web 版本

```bash
flutter build web
# 构建文件在 build/web/ 目录下
```

### 桌面版本

```bash
# Linux
flutter build linux

# Windows
flutter build windows

# macOS
flutter build macos
```

### Android 版本

```bash
flutter build apk
# 或者构建 App Bundle
flutter build appbundle
```

## 总结

这个完整的 Flutter 应用包含了：

1. **用户认证系统** - 登录/注册功能
2. **数据持久化** - SQLite 数据库存储
3. **状态管理** - Provider 模式
4. **响应式 UI** - Material Design
5. **跨平台支持** - Web、桌面、移动端
6. **交互功能** - 单词学习、进度跟踪

通过这个教程，你可以学会如何使用 Flutter 开发一个完整的跨平台应用。你可以在此基础上添加更多功能，如：

- 语音播放
- 在线同步
- 更多学习模式
- 社交功能
- 推送通知

开始你的 Flutter 开发之旅吧！