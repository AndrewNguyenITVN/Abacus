import 'package:flutter/material.dart';
import 'home_helpers.dart';

/// Cards hiển thị thu nhập và chi tiêu
class IncomeExpenseCards extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const IncomeExpenseCards({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Income Card
          Expanded(
            child: _buildIncomeCard(),
          ),
          const SizedBox(width: 12),
          // Expense Card
          Expanded(
            child: _buildExpenseCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Thu nhập',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatCurrency(totalIncome),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Chi tiêu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatCurrency(totalExpense),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

