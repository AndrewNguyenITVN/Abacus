import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/app_notification.dart';
import 'database_service.dart';
import 'notification_service.dart';

class TransactionService {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  Future<Database> get database async {
    return await _dbService.database;
  }

  // Insert transaction
  Future<void> insertTransaction(app_transaction.Transaction transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Check spending after adding any transaction (income or expense affects %)
    await _checkMonthlySpending(transaction.userId);
  }

  // Update transaction
  Future<void> updateTransaction(app_transaction.Transaction transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    
    // Check spending after updating transaction
    await _checkMonthlySpending(transaction.userId);
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId, String userId) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );
    
    // Check spending after deleting transaction
    await _checkMonthlySpending(userId);
  }

  // Get all transactions for a specific user
  Future<List<app_transaction.Transaction>> getTransactions(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return app_transaction.Transaction.fromMap(maps[i]);
    });
  }

  // Get transactions by type for a specific user
  Future<List<app_transaction.Transaction>> getTransactionsByType(String type, String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ? AND user_id = ?',
      whereArgs: [type, userId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return app_transaction.Transaction.fromMap(maps[i]);
    });
  }

  // Get transactions by date range for a specific user
  Future<List<app_transaction.Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
    String userId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ? AND user_id = ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
        userId,
      ],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return app_transaction.Transaction.fromMap(maps[i]);
    });
  }

  // Clear all transactions for a specific user
  Future<void> clearTransactions(String userId) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Get monthly income and expenses for a specific user
  Future<Map<String, double>> getMonthlyTotals(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final transactions = await getTransactionsByDateRange(startOfMonth, endOfMonth, userId);

    double totalIncome = 0;
    double totalExpense = 0;

    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else if (transaction.type == 'expense') {
        totalExpense += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expense': totalExpense,
    };
  }

  // Check monthly spending and send notification if needed
  Future<void> _checkMonthlySpending(String? userId) async {
    if (userId == null) return;
    
    // Check if notifications enabled
    if (!await _notificationService.isEnabled()) return;

    final totals = await getMonthlyTotals(userId);
    final monthlyIncome = totals['income'] ?? 0;
    final monthlyExpense = totals['expense'] ?? 0;

    // Only check if there's income
    if (monthlyIncome <= 0) return;

    final spendingPercentage = (monthlyExpense / monthlyIncome) * 100;
    final threshold = await _notificationService.getThreshold();
    
    final now = DateTime.now();
    final lastPercent = await _notificationService.getLastNotifiedPercent(now);

    // Case 1: Spending dropped below previous notification level (e.g. deleted transaction)
    if (spendingPercentage < lastPercent) {
      // Reset the high water mark to current level so we can be notified again if it rises
      await _notificationService.setLastNotifiedPercent(now, spendingPercentage);
      return;
    }

    // Case 2: Spending is below threshold
    if (spendingPercentage < threshold) {
       // Ensure lastPercent is reset if we are below threshold (handled by Case 1 if lastPercent was high)
       return;
    }

    // Case 3: Spending increased and is above threshold
    // Calculate ALL milestones that need notification
    
    List<int> milestonesToNotify = [];
    int currentMilestone = threshold;
    
    while (currentMilestone <= spendingPercentage) {
      // Collect all milestones we haven't notified yet
      if (currentMilestone > lastPercent) {
        milestonesToNotify.add(currentMilestone);
      }
      currentMilestone += 5;
    }

    // Send notification if we crossed any milestones
    // Even if we crossed multiple milestones (e.g. +15%), we only send ONE notification
    if (milestonesToNotify.isNotEmpty) {
      // Determine severity based on percentage
      final bool isCritical = spendingPercentage >= 90;
      final String emoji = isCritical ? '🚨' : '⚠️';

      final String title = isCritical
          ? '$emoji Cảnh báo: Chi tiêu vượt mức!'
          : '$emoji Thông báo: Chi tiêu cao!';

      final String body =
          'Bạn đã chi ${_formatCurrency(monthlyExpense)} (${spendingPercentage.toStringAsFixed(0)}% thu nhập tháng ${_formatCurrency(monthlyIncome)})';

      await _notificationService.showNotification(
        title: title,
        body: body,
        type: NotificationType.spending,
        payload: 'spending_warning_$spendingPercentage',
      );
    }

    // Save the highest milestone we've notified
    if (milestonesToNotify.isNotEmpty) {
      final highestMilestone = milestonesToNotify.last;
      await _notificationService.setLastNotifiedPercent(now, highestMilestone.toDouble());
    }
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
