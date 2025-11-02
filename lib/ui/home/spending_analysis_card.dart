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
    final percentage = totalIncome > 0
        ? ((totalExpense / totalIncome) * 100).toStringAsFixed(1)
        : '0';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.purple.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Phân tích chi tiêu',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a2e),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Progress bar với gradient
            Stack(
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: totalIncome > 0
                      ? (totalExpense / totalIncome).clamp(0.0, 1.0)
                      : 0,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: totalExpense > totalIncome
                            ? [const Color(0xFFee0979), const Color(0xFFff6a00)]
                            : [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (totalExpense > totalIncome
                                  ? const Color(0xFFee0979)
                                  : const Color(0xFF11998e))
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: totalExpense > totalIncome
                            ? const Color(0xFFee0979)
                            : const Color(0xFF11998e),
                      ),
                    ),
                    Text(
                      'Đã chi tiêu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: totalIncome > totalExpense
                        ? const Color(0xFF11998e).withOpacity(0.1)
                        : const Color(0xFFee0979).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        totalIncome > totalExpense
                            ? Icons.check_circle_rounded
                            : Icons.warning_rounded,
                        size: 16,
                        color: totalIncome > totalExpense
                            ? const Color(0xFF11998e)
                            : const Color(0xFFee0979),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        totalIncome > totalExpense
                            ? formatCurrency(totalIncome - totalExpense)
                            : 'Vượt chi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: totalIncome > totalExpense
                              ? const Color(0xFF11998e)
                              : const Color(0xFFee0979),
                        ),
                      ),
                    ],
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

