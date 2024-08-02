import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE modules(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            difficulty TEXT,
            questionCount INTEGER,
            pdfPath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE questions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            moduleId INTEGER,
            question TEXT,
            correctAnswer TEXT,
            options TEXT,
            FOREIGN KEY (moduleId) REFERENCES modules (id)
          )
        ''');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String identifier) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ? OR username = ?',
      whereArgs: [identifier, identifier],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.update('users', user, where: 'id = ?', whereArgs: [user['id']]);
  }

  Future<int> insertModule(Map<String, dynamic> module) async {
    Database db = await database;
    return await db.insert('modules', module);
  }

  Future<int> insertQuestion(Map<String, dynamic> question) async {
    Database db = await database;
    return await db.insert('questions', question);
  }

  Future<int> updateModule(Map<String, dynamic> module) async {
    Database db = await database;
    return await db.update('modules', module, where: 'id = ?', whereArgs: [module['id']]);
  }

  Future<List<Map<String, dynamic>>> queryAllModules() async {
    Database db = await database;
    return await db.query('modules');
  }

  Future<List<Map<String, dynamic>>> queryQuestions(int moduleId) async {
    Database db = await database;
    return await db.query('questions', where: 'moduleId = ?', whereArgs: [moduleId]);
  }

  Future<int> deleteQuestions(int moduleId) async {
    Database db = await database;
    return await db.delete('questions', where: 'moduleId = ?', whereArgs: [moduleId]);
  }

  Future<int> deleteModule(int id) async {
    Database db = await database;
    await db.delete('questions', where: 'moduleId = ?', whereArgs: [id]);
    return await db.delete('modules', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    await databaseFactory.deleteDatabase(path);
  }
}
