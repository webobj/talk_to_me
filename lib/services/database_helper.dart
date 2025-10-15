import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('conversations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        isUser INTEGER NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getAllMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    });
  }

  Future<List<Message>> getRecentMessages(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    }).reversed.toList();
  }

  Future<int> deleteMessage(int id) async {
    final db = await database;
    return await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
