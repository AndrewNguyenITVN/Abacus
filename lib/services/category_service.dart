import 'package:sqflite/sqflite.dart';
import '../models/my_category.dart';
import 'database_service.dart';

class CategoryService {
  final DatabaseService _dbService = DatabaseService();

  Future<Database> get database async {
    return await _dbService.database;
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
      where: 'type = ? AND user_id = ?',
      whereArgs: ['expense', userId],
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
      where: 'type = ? AND user_id = ?',
      whereArgs: ['income', userId],
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
