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

  // Lấy thông tin màu sắc và text theo loại báo cáo
  _ReportConfig get _config {
    if (reportType == ReportType.expense) {
      return _ReportConfig(
        title: 'Báo cáo tháng này',
        subtitle: 'Tổng chi tháng này',
        emptyMessage: 'Chưa có chi tiêu',
        primaryColor: Colors.red,
        secondaryColor: Colors.orange,
        gradientColors: [Colors.orange.shade50, Colors.red.shade50],
        borderColor: Colors.orange.shade200,
        buttonColor: Colors.orange.shade700,
      );
    } else {
      return _ReportConfig(
        title: 'Báo cáo thu nhập',
        subtitle: 'Tổng thu tháng này',
        emptyMessage: 'Chưa có thu nhập',
        primaryColor: Colors.green,
        secondaryColor: Colors.teal,
        gradientColors: [Colors.green.shade50, Colors.teal.shade50],
        borderColor: Colors.green.shade200,
        buttonColor: Colors.green.shade700,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;

    // Tính % thay đổi
    String percentageText;
    if (previousMonthAmount == 0) {
      percentageText =
          currentMonthAmount > 0 ? 'Mới bắt đầu' : config.emptyMessage;
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
        gradient: LinearGradient(
          colors: config.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.borderColor),
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
                config.title,
                style: const TextStyle(
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
                    color: config.buttonColor,
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
              color: config.primaryColor.shade700,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${config.subtitle} - $percentageText',
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
                color: config.primaryColor,
              ),
              const SizedBox(width: 24),
              _buildBarColumn(
                height: currentHeight.clamp(30.0, 100.0),
                label: 'Tháng này',
                isHighlighted: true,
                topLabel: _formatCurrencyShort(currentMonthAmount),
                color: config.primaryColor,
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
    required MaterialColor color,
    String? topLabel,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topLabel != null) ...[
          Text(
            topLabel,
            style: TextStyle(
              color: color.shade700,
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
                    colors: [color.shade400, color.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      color.shade300.withOpacity(0.6),
                      color.shade400.withOpacity(0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            border: Border.all(
              color: isHighlighted ? color.shade700 : color.shade300,
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

// Class helper để quản lý config cho từng loại báo cáo
class _ReportConfig {
  final String title;
  final String subtitle;
  final String emptyMessage;
  final MaterialColor primaryColor;
  final MaterialColor secondaryColor;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color buttonColor;

  _ReportConfig({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradientColors,
    required this.borderColor,
    required this.buttonColor,
  });
}

