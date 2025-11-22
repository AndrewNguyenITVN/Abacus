import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum SummaryCardType { balance, incomeExpense, spendingAnalysis }

/// Card tổng quan cho màn hình Home (Balance, Income/Expense, Spending Analysis)
class HomeSummaryCard extends StatelessWidget {
  final SummaryCardType cardType;
  final double? balance;
  final double? totalIncome;
  final double? totalExpense;

  const HomeSummaryCard.balance({
    super.key,
    required this.balance,
  })  : cardType = SummaryCardType.balance,
        totalIncome = null,
        totalExpense = null;

  const HomeSummaryCard.incomeExpense({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  })  : cardType = SummaryCardType.incomeExpense,
        balance = null;

  const HomeSummaryCard.spendingAnalysis({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  })  : cardType = SummaryCardType.spendingAnalysis,
        balance = null;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  String _formatCurrencyShort(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} Tỷ';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} K';
    }
    return '${value.toStringAsFixed(0)}đ';
  }

  @override
  Widget build(BuildContext context) {
    switch (cardType) {
      case SummaryCardType.balance:
        return _buildBalanceCard(context);
      case SummaryCardType.incomeExpense:
        return _buildIncomeExpenseCard(context);
      case SummaryCardType.spendingAnalysis:
        return _buildSpendingAnalysisCard(context);
    }
  }

  // Card hiển thị số dư hiện tại
  Widget _buildBalanceCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary, // Use primary and secondary for gradient
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: colorScheme.onPrimary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Số dư hiện tại',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(balance ?? 0),
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Card hiển thị thu nhập và chi tiêu
  Widget _buildIncomeExpenseCard(BuildContext context) {
    return Row(
      children: [
        // Income Card
        Expanded(
          child: _buildAmountCard(
            context: context,
            icon: Icons.arrow_downward,
            label: 'Thu nhập',
            amount: totalIncome ?? 0,
            baseColor: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        // Expense Card
        Expanded(
          child: _buildAmountCard(
            context: context,
            icon: Icons.arrow_upward,
            label: 'Chi tiêu',
            amount: totalExpense ?? 0,
            baseColor: Colors.red,
          ),
        ),
      ],
    );
  }

  // Helper widget để build Income/Expense card
  Widget _buildAmountCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required double amount,
    required Color baseColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Adjust background opacity based on theme mode
        color: baseColor.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: baseColor.withOpacity(isDark ? 0.3 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: Colors.white, // Always white on colored bg
                  size: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface, // Adapt text color
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: baseColor, // Keep semantic color for amount
            ),
          ),
        ],
      ),
    );
  }

  // Card phân tích chi tiêu với progress bar
  Widget _buildSpendingAnalysisCard(BuildContext context) {
    final income = totalIncome ?? 0;
    final expense = totalExpense ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích chi tiêu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface, // Adapt text color
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: income > 0 ? (expense / income).clamp(0.0, 1.0) : 0,
              minHeight: 10,
              backgroundColor: Colors.green.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                expense > income ? Colors.red : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                income > 0
                    ? '${((expense / income) * 100).toStringAsFixed(1)}%'
                    : '0%',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant, // Subtle text color
                ),
              ),
              Text(
                income > expense
                    ? 'Còn lại: ${_formatCurrencyShort(income - expense)}'
                    : 'Vượt chi!',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: income > expense ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeBalanceCard extends StatelessWidget {
  final double balance;

  const HomeBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return HomeSummaryCard.balance(balance: balance);
  }
}

class HomeIncomeExpenseCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const HomeIncomeExpenseCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return HomeSummaryCard.incomeExpense(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    );
  }
}

class HomeSpendingAnalysis extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const HomeSpendingAnalysis({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return HomeSummaryCard.spendingAnalysis(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    );
  }
}
