import '/models/transaction.dart';
import '/ui/categories/categories_manager.dart';

class TransactionsManager {
  final CategoriesManager _categoriesManager = CategoriesManager();

  final List<Transaction> _transactions = [];

  TransactionsManager() {
    final now = DateTime.now();
    final expenseCategories = _categoriesManager.expenseCategories;
    final incomeCategories = _categoriesManager.incomeCategories;
    _transactions.addAll([
      Transaction(
        id: 't1',
        amount: 65000,
        description: 'Bữa trưa',
        date: now.subtract(const Duration(days: 1)),
        categoryId: expenseCategories[0].id,
        type: 'expense',
        note: 'Ăn cùng bạn bè',
      ),
      Transaction(
        id: 't2',
        amount: 1500000,
        description: 'Mua sắm',
        date: now.subtract(const Duration(days: 2)),
        categoryId: expenseCategories[1].id,
        type: 'expense',
      ),
      Transaction(
        id: 't3',
        amount: 10000000,
        description: 'Lương tháng này',
        date: now,
        categoryId: incomeCategories[0].id,
        type: 'income',
      ),
      Transaction(
        id: 't4',
        amount: 500000,
        description: 'Tiền xăng xe',
        date: now.subtract(const Duration(hours: 5)),
        categoryId: expenseCategories[2].id,
        type: 'expense',
      ),
       Transaction(
        id: 't5',
        amount: 2000000,
        description: 'Tiền thưởng',
        date: now.subtract(const Duration(days: 5)),
        categoryId: incomeCategories[1].id,
        type: 'income',
      ),
    ]);
  }

  List<Transaction> get transactions {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    return [..._transactions];
  }

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
}
