import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/my_category.dart';

class CategoryService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'category_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories(
            id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            type TEXT NOT NULL,
            is_default INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (id, user_id)
          )
        ''');
      },
    );
  }

  // Insert category for a specific user
  Future<void> insertCategory(String userId, MyCategory category) async {
    final db = await database;
    await db.insert(
      'categories',
      {
        ...category.toMap(),
        'user_id': userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update category for a specific user
  Future<void> updateCategory(String userId, MyCategory category) async {
    final db = await database;
    await db.update(
      'categories',
      {
        ...category.toMap(),
        'user_id': userId,
      },
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, category.id],
    );
  }

  // Delete category for a specific user
  Future<void> deleteCategory(String userId, String categoryId) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'user_id = ? AND id = ?',
      whereArgs: [userId, categoryId],
    );
  }

  // Get all categories for a specific user
  Future<List<MyCategory>> getCategories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return MyCategory.fromMap(maps[i]);
    });
  }

  // Get expense categories for a specific user
  Future<List<MyCategory>> getExpenseCategories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, 'expense'],
    );

    return List.generate(maps.length, (i) {
      return MyCategory.fromMap(maps[i]);
    });
  }

  // Get income categories for a specific user
  Future<List<MyCategory>> getIncomeCategories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, 'income'],
    );

    return List.generate(maps.length, (i) {
      return MyCategory.fromMap(maps[i]);
    });
  }

  // Clear all categories for a specific user
  Future<void> clearCategories(String userId) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
