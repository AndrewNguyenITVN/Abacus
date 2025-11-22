import 'package:flutter/material.dart';
import '../shared/app_constants.dart';
import '../shared/app_helpers.dart';

class TransactionSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const TransactionSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer ?? colorScheme.surface,
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
          _buildRow(
            context: context,
            label: 'Thu nhập',
            amount: totalIncome,
            icon: Icons.trending_up_rounded,
            colors: AppConstants.incomeGradient,
            amountColor: AppConstants.incomeColor,
            isPositive: true,
          ),
          const SizedBox(height: 16),
          
          // Expense row
          _buildRow(
            context: context,
            label: 'Chi tiêu',
            amount: totalExpense,
            icon: Icons.trending_down_rounded,
            colors: AppConstants.expenseGradient,
            amountColor: AppConstants.expenseColor,
            isPositive: false,
          ),
          
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.outlineVariant.withOpacity(0.1),
                  colorScheme.outlineVariant,
                  colorScheme.outlineVariant.withOpacity(0.1),
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
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Số dư',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                AppHelpers.formatCurrency(balance),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required String label,
    required double amount,
    required IconData icon,
    required List<Color> colors,
    required Color amountColor,
    required bool isPositive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Text(
          AppHelpers.formatCurrency(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
