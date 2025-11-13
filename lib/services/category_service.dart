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
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            type TEXT NOT NULL,
            is_default INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // Insert category
  Future<void> insertCategory(MyCategory category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update category
  Future<void> updateCategory(MyCategory category) async {
    final db = await database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  // Get all categories
  Future<List<MyCategory>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    return List.generate(maps.length, (i) {
      return MyCategory.fromMap(maps[i]);
    });
  }

  // Get expense categories
  Future<List<MyCategory>> getExpenseCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: ['expense'],
    );

    return List.generate(maps.length, (i) {
      return MyCategory.fromMap(maps[i]);
    });
  }

  // Get income categories
  Future<List<MyCategory>> getIncomeCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: ['income'],
    );

    return List.generate(maps.length, (i) {
      return MyCategory.fromMap(maps[i]);
    });
  }

  // Clear all categories
  Future<void> clearCategories() async {
    final db = await database;
    await db.delete('categories');
  }
}
