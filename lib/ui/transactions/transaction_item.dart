import 'package:flutter/material.dart';
import '/models/transaction.dart';
import '/models/my_category.dart';
import 'transaction_helpers.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final MyCategory category;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final categoryColor = TransactionHelpers.parseColor(category.color);

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
              colors: [categoryColor.withOpacity(0.8), categoryColor],
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
            TransactionHelpers.getIconData(category.icon),
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF1a1a2e),
            letterSpacing: -0.2,
          ),
        ),
        subtitle: transaction.description.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  transaction.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isIncome
                ? const Color(0xFF11998e).withOpacity(0.1)
                : const Color(0xFFee0979).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${isIncome ? '+' : '-'}${TransactionHelpers.formatCurrency(transaction.amount)}',
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
        onTap: onTap,
      ),
    );
  }
}


