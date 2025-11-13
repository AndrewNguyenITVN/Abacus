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
