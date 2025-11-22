import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/transaction.dart';
import '/models/my_category.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final List<MyCategory> categories;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.categories,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
    return formatter.format(date);
  }

  IconData _getIconData(String iconName) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'shopping_bag': Icons.shopping_bag,
      'local_gas_station': Icons.local_gas_station,
      'house': Icons.house,
      'work': Icons.work,
      'attach_money': Icons.attach_money,
      'movie': Icons.movie,
      'school': Icons.school,
      'local_hospital': Icons.local_hospital,
      'fitness_center': Icons.fitness_center,
      'flight': Icons.flight,
      'phone': Icons.phone,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Color _parseColor(String hexColor) {
    try {
      final hexCode = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có giao dịch nào',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final category = categories.firstWhere(
          (c) => c.id == transaction.categoryId,
          orElse: () => categories.first,
        );
        final isIncome = transaction.type == 'income';
        final categoryColor = _parseColor(category.color);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer ?? colorScheme.surface,
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
                color: categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(category.icon),
                color: categoryColor,
                size: 24,
              ),
            ),
            title: Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              _formatDate(transaction.date),
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'} ${_formatCurrency(transaction.amount)}',
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
