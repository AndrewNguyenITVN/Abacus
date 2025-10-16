import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/models/transaction.dart';
import '/ui/categories/categories_manager.dart';
import '/ui/shared/app_drawer.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ giao dịch'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildSummary(context, transactionsManager),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 100,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có giao dịch nào',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : _buildGroupedTransactionList(transactions, categoriesManager),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
      BuildContext context, TransactionsManager transactionsManager) {
    final currencyFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Thu nhập', style: TextStyle(fontSize: 16)),
                Text(
                  currencyFormat.format(transactionsManager.totalIncome),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Chi tiêu', style: TextStyle(fontSize: 16)),
                Text(
                  currencyFormat.format(transactionsManager.totalExpense),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Số dư',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  currencyFormat.format(transactionsManager.balance),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
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

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        dateText,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Builder(
        builder: (context) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _parseColor(category.color),
              child: Icon(
                _getIconData(category.icon),
                color: Colors.white,
              ),
            ),
            title: Text(transaction.description),
            subtitle: Text(category.name),
            trailing: Text(
              '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
