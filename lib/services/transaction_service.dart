import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart' as app_transaction;
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
    await _checkMonthlySpending();
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
    await _checkMonthlySpending();
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );
    
    // Check spending after deleting transaction
    await _checkMonthlySpending();
  }

  // Get all transactions
  Future<List<app_transaction.Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return app_transaction.Transaction.fromMap(maps[i]);
    });
  }

  // Get transactions by type
  Future<List<app_transaction.Transaction>> getTransactionsByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return app_transaction.Transaction.fromMap(maps[i]);
    });
  }

  // Get transactions by date range
  Future<List<app_transaction.Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return app_transaction.Transaction.fromMap(maps[i]);
    });
  }

  // Clear all transactions
  Future<void> clearTransactions() async {
    final db = await database;
    await db.delete('transactions');
  }

  // Get monthly income and expenses
  Future<Map<String, double>> getMonthlyTotals() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final transactions = await getTransactionsByDateRange(startOfMonth, endOfMonth);

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
  Future<void> _checkMonthlySpending() async {
    // Check if notifications enabled
    if (!await NotificationService.isEnabled()) return;

    final totals = await getMonthlyTotals();
    final monthlyIncome = totals['income'] ?? 0;
    final monthlyExpense = totals['expense'] ?? 0;

    // Only check if there's income
    if (monthlyIncome <= 0) return;

    final spendingPercentage = (monthlyExpense / monthlyIncome) * 100;
    final threshold = await NotificationService.getThreshold();
    
    final now = DateTime.now();
    final lastPercent = await NotificationService.getLastNotifiedPercent(now);

    // Case 1: Spending dropped below previous notification level (e.g. deleted transaction)
    if (spendingPercentage < lastPercent) {
      // Reset the high water mark to current level so we can be notified again if it rises
      await NotificationService.setLastNotifiedPercent(now, spendingPercentage);
      return;
    }

    // Case 2: Spending is below threshold
    if (spendingPercentage < threshold) {
       // Ensure lastPercent is reset if we are below threshold (handled by Case 1 if lastPercent was high)
       return;
    }

    // Case 3: Spending increased and is above threshold
    // Calculate ALL milestones that need notification
    // Example: threshold=70, lastPercent=74, current=84 -> notify for 75, 80
    
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
      await _notificationService.showSpendingWarningNotification(
        percentage: spendingPercentage,
        totalSpent: monthlyExpense,
        monthlyIncome: monthlyIncome,
      );
    }

    // Save the highest milestone we've notified
    if (milestonesToNotify.isNotEmpty) {
      final highestMilestone = milestonesToNotify.last;
      await NotificationService.setLastNotifiedPercent(now, highestMilestone.toDouble());
    }
  }
}

