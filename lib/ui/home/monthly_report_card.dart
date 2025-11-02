import 'package:flutter/material.dart';
import 'home_helpers.dart';

/// Card báo cáo tháng này với biểu đồ cột
class MonthlyReportCard extends StatelessWidget {
  final double totalExpense;

  const MonthlyReportCard({
    super.key,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
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
            formatCurrency(totalExpense),
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Tổng chi tháng này - 0%',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Bar Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBarColumn(
                height: 70,
                label: 'Tháng trước',
                color: Colors.red.shade300.withOpacity(0.6),
                borderColor: Colors.red.shade300,
                isHighlighted: false,
              ),
              const SizedBox(width: 24),
              _buildBarColumn(
                height: 100,
                label: 'Tháng này',
                color: Colors.red.shade400,
                borderColor: Colors.red.shade700,
                isHighlighted: true,
                topLabel: '1 M',
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
    required Color color,
    required Color borderColor,
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
                      color,
                      Colors.red.shade400.withOpacity(0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            border: Border.all(
              color: borderColor,
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

