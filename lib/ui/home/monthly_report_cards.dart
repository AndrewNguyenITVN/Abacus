import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ReportType { expense, income }

class MonthlyReportCard extends StatelessWidget {
  final double currentMonthAmount;
  final double previousMonthAmount;
  final ReportType reportType;

  const MonthlyReportCard({
    super.key,
    required this.currentMonthAmount,
    required this.previousMonthAmount,
    required this.reportType,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Define configuration based on report type and theme
    String title;
    String subtitle;
    String emptyMessage;
    Color primaryColor;
    Color containerBg;
    Color borderColor;

    if (reportType == ReportType.expense) {
      title = 'Báo cáo tháng này';
      subtitle = 'Tổng chi tháng này';
      emptyMessage = 'Chưa có chi tiêu';
      primaryColor = Colors.red;
      containerBg = isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50;
      borderColor = isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade200;
    } else {
      title = 'Báo cáo thu nhập';
      subtitle = 'Tổng thu tháng này';
      emptyMessage = 'Chưa có thu nhập';
      primaryColor = Colors.green;
      containerBg = isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50;
      borderColor = isDark ? Colors.green.withOpacity(0.3) : Colors.green.shade200;
    }

    // Tính % thay đổi
    String percentageText;
    if (previousMonthAmount == 0) {
      percentageText =
          currentMonthAmount > 0 ? 'Mới bắt đầu' : emptyMessage;
    } else {
      final change =
          ((currentMonthAmount - previousMonthAmount) / previousMonthAmount) *
              100;
      percentageText = change > 0
          ? '+${change.toStringAsFixed(1)}%'
          : '${change.toStringAsFixed(1)}%';
    }

    // Tính chiều cao cột cho bar chart
    final maxValue = currentMonthAmount > previousMonthAmount
        ? currentMonthAmount
        : previousMonthAmount;
    final currentHeight =
        maxValue > 0 ? (currentMonthAmount / maxValue) * 100 : 50.0;
    final previousHeight =
        maxValue > 0 ? (previousMonthAmount / maxValue) * 100 : 50.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
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
              Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurface,
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
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Text(
            _formatCurrency(currentMonthAmount),
            style: TextStyle(
              color: primaryColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$subtitle - $percentageText',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          // Bar Chart với dữ liệu thật
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBarColumn(
                context: context,
                height: previousHeight.clamp(30.0, 100.0),
                label: 'Tháng trước',
                isHighlighted: false,
                color: primaryColor,
              ),
              const SizedBox(width: 24),
              _buildBarColumn(
                context: context,
                height: currentHeight.clamp(30.0, 100.0),
                label: 'Tháng này',
                isHighlighted: true,
                topLabel: _formatCurrencyShort(currentMonthAmount),
                color: primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn({
    required BuildContext context,
    required double height,
    required String label,
    required bool isHighlighted,
    required Color color,
    String? topLabel,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topLabel != null) ...[
          Text(
            topLabel,
            style: TextStyle(
              color: color,
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
                    colors: [color.withOpacity(0.7), color],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            border: Border.all(
              color: isHighlighted ? color : color.withOpacity(0.5),
              width: isHighlighted ? 1.5 : 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isHighlighted 
                ? colorScheme.onSurface 
                : colorScheme.onSurface.withOpacity(0.6),
            fontSize: 11,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
