import 'package:sqflite/sqflite.dart';
import '../models/savings_goal.dart';
import 'database_service.dart';

class SavingsGoalService {
  final DatabaseService _dbService = DatabaseService();

  Future<Database> get database async {
    return await _dbService.database;
  }

  // Insert savings goal
  Future<void> insertGoal(SavingsGoal goal) async {
    final db = await database;
    await db.insert(
      'savings_goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update savings goal
  Future<void> updateGoal(SavingsGoal goal) async {
    final db = await database;
    await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  // Delete savings goal
  Future<void> deleteGoal(String goalId) async {
    final db = await database;
    await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  // Get all savings goals
  Future<List<SavingsGoal>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SavingsGoal.fromMap(maps[i]);
    });
  }

  // Get active goals (not completed)
  Future<List<SavingsGoal>> getActiveGoals() async {
    final goals = await getGoals();
    return goals.where((g) => !g.isCompleted).toList();
  }

  // Get completed goals
  Future<List<SavingsGoal>> getCompletedGoals() async {
    final goals = await getGoals();
    return goals.where((g) => g.isCompleted).toList();
  }

  // Get goal by id
  Future<SavingsGoal?> getGoalById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return SavingsGoal.fromMap(maps.first);
  }

  // Clear all savings goals
  Future<void> clearGoals() async {
    final db = await database;
    await db.delete('savings_goals');
  }
}

