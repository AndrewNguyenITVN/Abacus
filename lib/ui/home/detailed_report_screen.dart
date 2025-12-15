import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../transactions/transactions_manager.dart';
import '../categories/categories_manager.dart';
import '../shared/app_constants.dart';

class DetailedReportScreen extends StatefulWidget {
  final String type; // 'income' or 'expense'

  const DetailedReportScreen({super.key, required this.type});

  @override
  State<DetailedReportScreen> createState() => _DetailedReportScreenState();
}

class _DetailedReportScreenState extends State<DetailedReportScreen> {
  late String _currentType;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentType = widget.type;
  }

  Color _parseColor(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + months);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsManager = context.watch<TransactionsManager>();
    final categoriesManager = context.watch<CategoriesManager>();

    // 1. Prepare Data for Selected Month
    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    final allTransactions = transactionsManager.transactions;
    
    // Filter for current month view
    final monthlyTransactions = allTransactions.where((t) {
      return t.type == _currentType &&
          t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(endOfMonth.add(const Duration(seconds: 1)));
    }).toList();

    // Calculate Total for Selected Month
    final double totalAmount = monthlyTransactions.fold(0, (sum, t) => sum + t.amount);

    // Group by Category
    final Map<String, double> categoryTotals = {};
    for (var t in monthlyTransactions) {
      categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + t.amount;
    }

    final sortedCategoryIds = categoryTotals.keys.toList()
      ..sort((a, b) => categoryTotals[b]!.compareTo(categoryTotals[a]!));

    // 2. Prepare Data for Bar Chart (12 Months of the selected year)
    final List<Map<String, dynamic>> barChartData = [];
    final currentYear = _selectedMonth.year;
    
    for (int month = 1; month <= 12; month++) {
      final start = DateTime(currentYear, month, 1);
      final end = DateTime(currentYear, month + 1, 0, 23, 59, 59);
      
      final sum = allTransactions.where((t) {
        return t.type == _currentType &&
            t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end.add(const Duration(seconds: 1)));
      }).fold(0.0, (prev, t) => prev + t.amount);

      barChartData.add({
        'label': month.toString(),
        'amount': sum,
        'isCurrent': month == _selectedMonth.month,
      });
    }

    final isExpense = _currentType == 'expense';
    final primaryColor = isExpense ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(isExpense ? 'Báo cáo chi tiêu' : 'Báo cáo thu nhập'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              setState(() {
                _currentType = _currentType == 'expense' ? 'income' : 'expense';
              });
            },
            tooltip: 'Chuyển đổi Thu/Chi',
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Month Selector (Now acts as Year/Month selector context)
            _buildMonthSelector(),
            
            // 1. Bar Chart Section (Trends - 12 Months)
            Container(
              height: 220, // Increased height slightly
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _buildBarChart(barChartData, primaryColor),
            ),
            
            Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

            // 2. Current Month Summary
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                   Text(
                    'Tổng ${isExpense ? "chi tiêu" : "thu nhập"} tháng ${DateFormat('MM/yyyy').format(_selectedMonth)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalAmount),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Category Breakdown
            if (monthlyTransactions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Thống kê theo danh mục',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryStats(
                sortedCategoryIds,
                categoryTotals,
                totalAmount,
                categoriesManager,
              ),
              const SizedBox(height: 32),
            ] else 
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Text(
                  'Không có dữ liệu cho tháng này',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('MM/yyyy').format(_selectedMonth),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
               _changeMonth(1);
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data, Color color) {
    if (data.isEmpty) return const SizedBox();

    double maxAmount = 0;
    for (var item in data) {
      if (item['amount'] > maxAmount) maxAmount = item['amount'];
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate width for each bar to fit all 12 in available width
        final availableWidth = constraints.maxWidth;
        final barWidth = (availableWidth / data.length) * 0.6; // 60% of slot width

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute evenly
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((item) {
            final double amount = item['amount'];
            final double heightPercentage = maxAmount > 0 ? (amount / maxAmount) : 0;
            final bool isCurrent = item['isCurrent'];
            final displayColor = isCurrent ? color : color.withOpacity(0.3);

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCurrent && amount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      _compactCurrency(amount),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                Container(
                  width: barWidth.clamp(8.0, 24.0), // Min 8, Max 24
                  height: 140 * heightPercentage + 4, // Max height 140 + min 4
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['label'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryStats(
    List<String> sortedIds,
    Map<String, double> totals,
    double totalAmount,
    CategoriesManager categoriesManager,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedIds.length,
      itemBuilder: (context, index) {
        final catId = sortedIds[index];
        final category = categoriesManager.findById(catId);
        final amount = totals[catId]!;
        final percentage = totalAmount > 0 ? amount / totalAmount : 0.0;
        
        final catName = category?.name ?? 'Không xác định';
        final catColor = category != null 
            ? _parseColor(category.color) 
            : Colors.grey;
        final catIcon = category != null && AppConstants.iconMap.containsKey(category.icon)
            ? AppConstants.iconMap[category.icon]
            : Icons.category;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(catIcon, size: 16, color: catColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              catName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: Colors.grey[100],
                            valueColor: AlwaysStoppedAnimation<Color>(catColor),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(percentage * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _compactCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
