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
      {
        'english': 'computer',
        'chinese': '计算机',
        'pronunciation': '/kəmˈpjuːtər/',
        'example': 'I use a computer every day.',
        'difficulty': 2
      },
      {
        'english': 'programming',
        'chinese': '编程',
        'pronunciation': '/ˈproʊɡræmɪŋ/',
        'example': 'Programming is a valuable skill.',
        'difficulty': 3
      },
      {
        'english': 'beautiful',
        'chinese': '美丽的',
        'pronunciation': '/ˈbjuːtɪfl/',
        'example': 'The sunset is beautiful.',
        'difficulty': 2
      },
      {
        'english': 'knowledge',
        'chinese': '知识',
        'pronunciation': '/ˈnɑːlɪdʒ/',
        'example': 'Knowledge is power.',
        'difficulty': 3
      },
      {
        'english': 'friendship',
        'chinese': '友谊',
        'pronunciation': '/ˈfrendʃɪp/',
        'example': 'Friendship is very important.',
        'difficulty': 3
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

  Future<void> updateUserScore(int userId, int score) async {
    final db = await database;
    await db.update(
      'users',
      {'score': score},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // 单词相关操作
  Future<List<Word>> getAllWords() async {
    final db = await database;
    final maps = await db.query('words', orderBy: 'difficulty ASC, id ASC');
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

  Future<List<Word>> getWordsByDifficulty(int difficulty) async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'difficulty = ?',
      whereArgs: [difficulty],
    );
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }

  Future<List<Word>> getLearnedWords() async {
    final db = await database;
    final maps = await db.query(
      'words',
      where: 'isLearned = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Word.fromMap(maps[i]));
  }
}