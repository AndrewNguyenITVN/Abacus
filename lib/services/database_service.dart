import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'abacus_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tạo categories table
        await db.execute('''
          CREATE TABLE categories(
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL, 
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            type TEXT NOT NULL,
            is_default INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // Tạo transactions table
        await db.execute('''
          CREATE TABLE transactions(
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            amount REAL NOT NULL,
            description TEXT NOT NULL,
            date TEXT NOT NULL,
            category_id TEXT NOT NULL,
            type TEXT NOT NULL,
            note TEXT
          )
        ''');

        // Tạo savings_goals table
        await db.execute('''
          CREATE TABLE savings_goals(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            target_amount REAL NOT NULL,
            current_amount REAL NOT NULL DEFAULT 0,
            target_date TEXT,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Singleton pattern
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();
  factory DatabaseService() => instance;
}