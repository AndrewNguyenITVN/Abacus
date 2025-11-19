import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/models/transaction.dart';
import '/ui/categories/categories_manager.dart';
import '/ui/transactions/transactions_manager.dart';
import '/ui/transactions/edit_transaction_screen.dart';

// Helper functions to mock dialogs and helpers from the original project
Color _parseColor(String hexCode) {
  return Color(int.parse(hexCode.substring(1, 7), radix: 16) + 0xFF000000);
}

IconData _getIconData(String iconName) {
  // A simple map to mock the icon picker
  const iconMap = {
    'shopping_bag': Icons.shopping_bag,
    'restaurant': Icons.restaurant,
    'movie': Icons.movie,
    'house': Icons.house,
    'local_gas_station': Icons.local_gas_station,
    'school': Icons.school,
    'work': Icons.work,
    'attach_money': Icons.attach_money,
    'local_hospital': Icons.local_hospital,
    'fitness_center': Icons.fitness_center,
    'flight': Icons.flight,
    'phone': Icons.phone,
    'computer': Icons.computer,
    'directions_car': Icons.directions_car,
    'pets': Icons.pets,
    'games': Icons.games,
  };
  return iconMap[iconName] ?? Icons.help_outline;
}

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionsManager = context.watch<TransactionsManager>();
    final categoriesManager = context.watch<CategoriesManager>();
    final transactions = transactionsManager.transactions;

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return _buildLandscapeLayout(
            context,
            transactionsManager,
            categoriesManager,
            transactions,
          );
        } else {
          return _buildPortraitLayout(
            context,
            transactionsManager,
            categoriesManager,
            transactions,
          );
        }
      },
    );
  }

  // Layout dọc (Portrait) - giao diện hiện tại
  Widget _buildPortraitLayout(
    BuildContext context,
    TransactionsManager transactionsManager,
    CategoriesManager categoriesManager,
    List<Transaction> transactions,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Sổ giao dịch',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FD),
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildSummary(context, transactionsManager),
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState()
                : _buildGroupedTransactionList(transactions, categoriesManager),
          ),
        ],
      ),
    );
  }

  // Layout ngang (Landscape) - giao diện 2 cột
  Widget _buildLandscapeLayout(
    BuildContext context,
    TransactionsManager transactionsManager,
    CategoriesManager categoriesManager,
    List<Transaction> transactions,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Sổ giao dịch',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FD),
        surfaceTintColor: Colors.transparent,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT COLUMN (35%) - Summary Card
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildSummary(context, transactionsManager),
            ),
          ),

          // RIGHT COLUMN (65%) - Transaction List
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState()
                : _buildGroupedTransactionList(transactions, categoriesManager),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade100,
                  Colors.purple.shade100,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 60,
              color: Colors.blue.shade300,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có giao dịch nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a2e),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu bằng cách thêm giao dịch đầu tiên',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
      BuildContext context, TransactionsManager transactionsManager) {
    final currencyFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Income row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Thu nhập',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                ],
              ),
              Text(
                currencyFormat.format(transactionsManager.totalIncome),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF11998e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Expense row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFee0979), Color(0xFFff6a00)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.trending_down_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Chi tiêu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                ],
              ),
              Text(
                currencyFormat.format(transactionsManager.totalExpense),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFee0979),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade100,
                  Colors.grey.shade200,
                ],
              ),
            ),
          ),
          // Balance row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.purple.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Số dư',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                ],
              ),
              Text(
                currencyFormat.format(transactionsManager.balance),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedTransactionList(
      List<Transaction> transactions, CategoriesManager categoriesManager) {
    final items = [];
    DateTime? lastDate;

    for (var transaction in transactions) {
      final transactionDate = DateTime(
          transaction.date.year, transaction.date.month, transaction.date.day);
      if (lastDate == null || transactionDate.isBefore(lastDate)) {
        items.add(transactionDate);
        lastDate = transactionDate;
      }
      items.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is DateTime) {
          return _buildDateHeader(item);
        } else if (item is Transaction) {
          return _buildTransactionTile(item, categoriesManager);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final dateText = DateFormat('d MMMM, y', 'vi_VN').format(date);

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade300,
                  Colors.pink.shade300,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            dateText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a2e),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(
      Transaction transaction, CategoriesManager categoriesManager) {
    final currencyFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final category = categoriesManager.items
        .firstWhere((c) => c.id == transaction.categoryId);
    final isIncome = transaction.type == 'income';
    final categoryColor = _parseColor(category.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Builder(
        builder: (context) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    categoryColor.withOpacity(0.8),
                    categoryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getIconData(category.icon),
                color: Colors.white,
                size: 22,
              ),
            ),
            title: Text(
              transaction.description,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF1a1a2e),
                letterSpacing: -0.2,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('HH:mm', 'vi_VN').format(transaction.date),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isIncome
                    ? const Color(0xFF11998e).withOpacity(0.1)
                    : const Color(0xFFee0979).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
                style: TextStyle(
                  color: isIncome
                      ? const Color(0xFF11998e)
                      : const Color(0xFFee0979),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditTransactionScreen(transaction: transaction),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
