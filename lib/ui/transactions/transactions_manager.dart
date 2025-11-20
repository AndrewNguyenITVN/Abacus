import 'package:flutter/foundation.dart';
import '/models/transaction.dart';
import '/ui/categories/categories_manager.dart';
import '/services/transaction_service.dart';

class TransactionsManager extends ChangeNotifier {
  final CategoriesManager categoriesManager;
  final TransactionService _transactionService = TransactionService();

  List<Transaction> _transactions = [];
  bool _isLoaded = false;

  TransactionsManager(this.categoriesManager) {
    _loadTransactions();
  }

  List<Transaction> get transactions {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    return [..._transactions];
  }

  bool get isLoaded => _isLoaded;

  double get totalIncome {
    return transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;

  // Lấy danh sách giao dịch gần đây (giới hạn số lượng)
  List<Transaction> getRecentTransactions(int limit) {
    return transactions.take(limit).toList();
  }

  // Tính tổng thu nhập tháng trước
  double get previousMonthIncome {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final startOfLastMonth = DateTime(lastMonth.year, lastMonth.month, 1);
    final endOfLastMonth = DateTime(
      lastMonth.year,
      lastMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    return transactions
        .where(
          (t) =>
              t.type == 'income' &&
              t.date.isAfter(
                startOfLastMonth.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(endOfLastMonth.add(const Duration(seconds: 1))),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Tính tổng chi tiêu tháng trước
  double get previousMonthExpense {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final startOfLastMonth = DateTime(lastMonth.year, lastMonth.month, 1);
    final endOfLastMonth = DateTime(
      lastMonth.year,
      lastMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    return transactions
        .where(
          (t) =>
              t.type == 'expense' &&
              t.date.isAfter(
                startOfLastMonth.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(endOfLastMonth.add(const Duration(seconds: 1))),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Load transactions từ SQLite
  Future<void> _loadTransactions() async {
    try {
      _transactions = await _transactionService.getTransactions();
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      print('Error loading transactions: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  // Thêm transaction mới
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _transactionService.insertTransaction(transaction);
      _transactions.add(transaction);
      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // Cập nhật transaction
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _transactionService.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  // Xóa transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Refresh transactions từ database
  Future<void> refreshTransactions() async {
    _isLoaded = false;
    await _loadTransactions();
  }
}
