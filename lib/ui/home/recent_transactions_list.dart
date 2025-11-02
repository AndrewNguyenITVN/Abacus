import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/ui/transactions/transactions_manager.dart';
import '/ui/categories/categories_manager.dart';
import 'home_helpers.dart';

/// Widget hiển thị danh sách giao dịch gần đây
class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionsManager = context.watch<TransactionsManager>();
    final categoriesManager = context.watch<CategoriesManager>();

    final recentTransactions = transactionsManager.transactions.take(7).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Giao dịch gần đây',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to transactions screen
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Transaction List
        recentTransactions.isEmpty
            ? _buildEmptyState()
            : _buildTransactionList(
                recentTransactions,
                categoriesManager,
              ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có giao dịch nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    List<dynamic> transactions,
    CategoriesManager categoriesManager,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final category = categoriesManager.items.firstWhere(
          (c) => c.id == transaction.categoryId,
          orElse: () => categoriesManager.items.first,
        );
        final isIncome = transaction.type == 'income';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: parseColor(category.color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                getIconData(category.icon),
                color: parseColor(category.color),
                size: 24,
              ),
            ),
            title: Text(
              transaction.description,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              '${category.name} • ${formatDate(transaction.date)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'} ${formatCurrency(transaction.amount)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }
}

