import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Card báo cáo chi tiêu tháng với biểu đồ cột
class MonthlyReportExpenseCard extends StatelessWidget {
  final double currentMonthExpense;
  final double previousMonthExpense;

  const MonthlyReportExpenseCard({
    super.key,
    required this.currentMonthExpense,
    required this.previousMonthExpense,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  String _formatCurrencyShort(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} K';
    }
    return '${value.toStringAsFixed(0)}đ';
  }

  @override
  Widget build(BuildContext context) {
    // Tính % thay đổi
    String percentageText;
    if (previousMonthExpense == 0) {
      percentageText =
          currentMonthExpense > 0 ? 'Mới bắt đầu' : 'Chưa có chi tiêu';
    } else {
      final change =
          ((currentMonthExpense - previousMonthExpense) / previousMonthExpense) *
              100;
      percentageText = change > 0
          ? '+${change.toStringAsFixed(1)}%'
          : '${change.toStringAsFixed(1)}%';
    }

    // Tính chiều cao cột cho bar chart
    final maxValue = currentMonthExpense > previousMonthExpense
        ? currentMonthExpense
        : previousMonthExpense;
    final currentHeight =
        maxValue > 0 ? (currentMonthExpense / maxValue) * 100 : 50.0;
    final previousHeight =
        maxValue > 0 ? (previousMonthExpense / maxValue) * 100 : 50.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.red.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Báo cáo tháng này',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Xem báo cáo',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Text(
            _formatCurrency(currentMonthExpense),
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tổng chi tháng này - $percentageText',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Bar Chart với dữ liệu thật
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBarColumn(
                height: previousHeight.clamp(30.0, 100.0),
                label: 'Tháng trước',
                isHighlighted: false,
              ),
              const SizedBox(width: 24),
              _buildBarColumn(
                height: currentHeight.clamp(30.0, 100.0),
                label: 'Tháng này',
                isHighlighted: true,
                topLabel: _formatCurrencyShort(currentMonthExpense),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn({
    required double height,
    required String label,
    required bool isHighlighted,
    String? topLabel,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topLabel != null) ...[
          Text(
            topLabel,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
        ],
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: isHighlighted
                ? LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      Colors.red.shade300.withOpacity(0.6),
                      Colors.red.shade400.withOpacity(0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            border: Border.all(
              color: isHighlighted ? Colors.red.shade700 : Colors.red.shade300,
              width: isHighlighted ? 1.5 : 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isHighlighted ? Colors.black87 : Colors.black54,
            fontSize: 11,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// Card báo cáo thu nhập tháng với biểu đồ cột
class MonthlyReportIncomeCard extends StatelessWidget {
  final double currentMonthIncome;
  final double previousMonthIncome;

  const MonthlyReportIncomeCard({
    super.key,
    required this.currentMonthIncome,
    required this.previousMonthIncome,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  String _formatCurrencyShort(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} K';
    }
    return '${value.toStringAsFixed(0)}đ';
  }

  @override
  Widget build(BuildContext context) {
    // Tính % thay đổi
    String percentageText;
    if (previousMonthIncome == 0) {
      percentageText =
          currentMonthIncome > 0 ? 'Mới bắt đầu' : 'Chưa có thu nhập';
    } else {
      final change =
          ((currentMonthIncome - previousMonthIncome) / previousMonthIncome) *
              100;
      percentageText = change > 0
          ? '+${change.toStringAsFixed(1)}%'
          : '${change.toStringAsFixed(1)}%';
    }

    // Tính chiều cao cột cho bar chart
    final maxValue = currentMonthIncome > previousMonthIncome
        ? currentMonthIncome
        : previousMonthIncome;
    final currentHeight =
        maxValue > 0 ? (currentMonthIncome / maxValue) * 100 : 50.0;
    final previousHeight =
        maxValue > 0 ? (previousMonthIncome / maxValue) * 100 : 50.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Báo cáo thu nhập',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Xem báo cáo',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Text(
            _formatCurrency(currentMonthIncome),
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tổng thu tháng này - $percentageText',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Bar Chart với dữ liệu thật
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBarColumn(
                height: previousHeight.clamp(30.0, 100.0),
                label: 'Tháng trước',
                isHighlighted: false,
              ),
              const SizedBox(width: 24),
              _buildBarColumn(
                height: currentHeight.clamp(30.0, 100.0),
                label: 'Tháng này',
                isHighlighted: true,
                topLabel: _formatCurrencyShort(currentMonthIncome),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn({
    required double height,
    required String label,
    required bool isHighlighted,
    String? topLabel,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topLabel != null) ...[
          Text(
            topLabel,
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
        ],
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: isHighlighted
                ? LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      Colors.green.shade300.withOpacity(0.6),
                      Colors.green.shade400.withOpacity(0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            border: Border.all(
              color:
                  isHighlighted ? Colors.green.shade700 : Colors.green.shade300,
              width: isHighlighted ? 1.5 : 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isHighlighted ? Colors.black87 : Colors.black54,
            fontSize: 11,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
