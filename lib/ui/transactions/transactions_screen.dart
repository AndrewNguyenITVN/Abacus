import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/transaction.dart';
import '/ui/categories/categories_manager.dart';
import '/ui/transactions/transactions_manager.dart';
import '/ui/transactions/edit_transaction_screen.dart';
import '../shared/app_helpers.dart';
import 'transaction_item.dart';
import 'transaction_summary_card.dart';

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

  // Layout dọc (Portrait)
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
          TransactionSummaryCard(
            totalIncome: transactionsManager.totalIncome,
            totalExpense: transactionsManager.totalExpense,
            balance: transactionsManager.balance,
          ),
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState()
                : _buildGroupedTransactionList(transactions, categoriesManager),
          ),
        ],
      ),
    );
  }

  // Layout ngang (Landscape)
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
              child: TransactionSummaryCard(
                totalIncome: transactionsManager.totalIncome,
                totalExpense: transactionsManager.totalExpense,
                balance: transactionsManager.balance,
              ),
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
                colors: [Colors.blue.shade100, Colors.purple.shade100],
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedTransactionList(
    List<Transaction> transactions,
    CategoriesManager categoriesManager,
  ) {
    final items = [];
    DateTime? lastDate;

    for (var transaction in transactions) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
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
          // Find category securely
          final category = categoriesManager.items.firstWhere(
            (c) => c.id == item.categoryId,
            orElse: () => categoriesManager.items.first, // Fallback safety
          );
          
          return TransactionItem(
            transaction: item,
            category: category,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditTransactionScreen(transaction: item),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
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
                colors: [Colors.orange.shade300, Colors.pink.shade300],
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
            AppHelpers.formatLongDate(date),
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
}
