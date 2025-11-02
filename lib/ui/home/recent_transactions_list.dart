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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.pink.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1a1a2e),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to transactions screen
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
          child: ListTile(
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
                    parseColor(category.color).withOpacity(0.8),
                    parseColor(category.color),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: parseColor(category.color).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                getIconData(category.icon),
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
                      color: parseColor(category.color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: parseColor(category.color),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatDate(transaction.date),
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
                '${isIncome ? '+' : '-'}${formatCurrency(transaction.amount)}',
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
          ),
        );
      },
    );
  }
}


