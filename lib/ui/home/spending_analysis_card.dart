import 'package:flutter/material.dart';
import 'home_helpers.dart';

/// Card phân tích chi tiêu với progress bar
class SpendingAnalysisCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const SpendingAnalysisCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân tích chi tiêu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalIncome > 0
                    ? (totalExpense / totalIncome).clamp(0.0, 1.0)
                    : 0,
                minHeight: 12,
                backgroundColor: Colors.green.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  totalExpense > totalIncome ? Colors.red : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  totalIncome > 0
                      ? '${((totalExpense / totalIncome) * 100).toStringAsFixed(1)}% đã chi tiêu'
                      : '0% đã chi tiêu',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  totalIncome > totalExpense
                      ? 'Còn lại: ${formatCurrency(totalIncome - totalExpense)}'
                      : 'Vượt chi!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: totalIncome > totalExpense ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

