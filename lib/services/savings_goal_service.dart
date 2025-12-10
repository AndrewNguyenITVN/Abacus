import 'package:sqflite/sqflite.dart';
import '../models/savings_goal.dart';
import '../models/app_notification.dart';
import 'database_service.dart';
import 'notification_service.dart';

class SavingsGoalService {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

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
    // Get old goal to check if it just reached 100%
    final oldGoal = await getGoalById(goal.id);
    
    final db = await database;
    await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );

    // Check if savings goal notifications are enabled
    final isEnabled = await _notificationService.isSavingsGoalEnabled();
    
    // Check if goal just reached 100% (was not completed before, but is now)
    if (isEnabled && oldGoal != null && oldGoal.isCompleted == false && goal.isCompleted) {
      final title = '🎉 Chúc mừng! Bạn đã đạt mục tiêu!';
      final body =
          'Bạn đã đủ tiền để ${goal.name} với số tiền ${_formatCurrency(goal.targetAmount)}!';

      await _notificationService.showNotification(
        title: title,
        body: body,
        type: NotificationType.savingsGoal,
        payload: 'savings_goal_reached',
      );
    }
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

  // Get all savings goals for a specific user
  Future<List<SavingsGoal>> getGoals(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SavingsGoal.fromMap(maps[i]);
    });
  }

  // Get active goals (not completed)
  Future<List<SavingsGoal>> getActiveGoals(String userId) async {
    final goals = await getGoals(userId);
    return goals.where((g) => !g.isCompleted).toList();
  }

  // Get completed goals
  Future<List<SavingsGoal>> getCompletedGoals(String userId) async {
    final goals = await getGoals(userId);
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

  // Clear all savings goals for a specific user
  Future<void> clearGoals(String userId) async {
    final db = await database;
    await db.delete(
      'savings_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Format currency helper
  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} nghìn';
    }
    return amount.toStringAsFixed(0);
  }
}
