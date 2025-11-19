import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/models/transaction.dart';
import '/ui/shared/app_drawer.dart';
import '/ui/transactions/transactions_manager.dart';
import '/ui/categories/categories_manager.dart';
import '/ui/savings_goals/savings_goals_block.dart';

// Helper functions
String _formatCurrency(double amount) {
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  return formatter.format(amount);
}

// Format tiền tệ ngắn gọn cho biểu đồ
String _formatCurrencyShort(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)} M';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)} K';
  }
  return '${value.toStringAsFixed(0)}đ';
}

String _formatDate(DateTime date) {
  final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
  return formatter.format(date);
}

IconData _getIconData(String iconName) {
  const iconMap = {
    'restaurant': Icons.restaurant,
    'shopping_bag': Icons.shopping_bag,
    'local_gas_station': Icons.local_gas_station,
    'house': Icons.house,
    'work': Icons.work,
    'attach_money': Icons.attach_money,
  };
  return iconMap[iconName] ?? Icons.category;
}

Color _parseColor(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentReportPage = 0;
  final PageController _reportPageController = PageController();

  @override
  void dispose() {
    _reportPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsManager = context.watch<TransactionsManager>();
    final categoriesManager = context.watch<CategoriesManager>();
    final balance = transactionsManager.balance;
    final totalIncome = transactionsManager.totalIncome;
    final totalExpense = transactionsManager.totalExpense;
    final recentTransactions = transactionsManager.transactions
        .take(7)
        .toList();

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return _buildLandscapeLayout(
            context,
            transactionsManager,
            categoriesManager,
            balance,
            totalIncome,
            totalExpense,
            recentTransactions,
          );
        } else {
          return _buildPortraitLayout(
            context,
            transactionsManager,
            categoriesManager,
            balance,
            totalIncome,
            totalExpense,
            recentTransactions,
          );
        }
      },
    );
  }

  // Layout dọc (Portrait) - giao diện hiện tại
  Widget _buildPortraitLayout(
    BuildContext context,
    TransactionsManager transactionsManager,
    CategoriesManager categoriesManager,
    double balance,
    double totalIncome,
    double totalExpense,
    List<Transaction> recentTransactions,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trang chủ',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Chức năng tìm kiếm
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng tìm kiếm sẽ được triển khai'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Tìm kiếm',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Chức năng thông báo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng thông báo sẽ được triển khai'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Thông báo',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Balance Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Số dư hiện tại',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatCurrency(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Income & Expense Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Income Card
                  Expanded(
                    child: Container(
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
                            _formatCurrency(totalIncome),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Expense Card
                  Expanded(
                    child: Container(
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
                            _formatCurrency(totalExpense),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Progress Bar - Spending Analysis
            Padding(
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
                          totalExpense > totalIncome
                              ? Colors.red
                              : Colors.orange,
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
                              ? 'Còn lại: ${_formatCurrency(totalIncome - totalExpense)}'
                              : 'Vượt chi!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: totalIncome > totalExpense
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Reports Carousel với Navigation
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  PageView(
                    controller: _reportPageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentReportPage = index;
                      });
                    },
                    children: [
                      _buildMonthlyReportCard(transactionsManager),
                      _buildMonthlyIncomeReportCard(transactionsManager),
                    ],
                  ),
                  // Left Arrow Button
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          if (_currentReportPage > 0) {
                            _reportPageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  // Right Arrow Button
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          if (_currentReportPage < 1) {
                            _reportPageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentReportPage == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentReportPage == index
                        ? Colors.green
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Savings Goals
            SavingsGoalsBlock(),
            const SizedBox(height: 24),

            // Recent Transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to transactions screen
                    },
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Transaction List
            recentTransactions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có giao dịch nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recentTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = recentTransactions[index];
                      final category = categoriesManager.items.firstWhere(
                        (c) => c.id == transaction.categoryId,
                        orElse: () => categoriesManager.items.first,
                      );
                      final isIncome = transaction.type == 'income';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _parseColor(
                                category.color,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconData(category.icon),
                              color: _parseColor(category.color),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            transaction.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            '${category.name} • ${_formatDate(transaction.date)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Text(
                            '${isIncome ? '+' : '-'} ${_formatCurrency(transaction.amount)}',
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Layout ngang (Landscape) - giao diện 2 cột
  Widget _buildLandscapeLayout(
    BuildContext context,
    TransactionsManager transactionsManager,
    CategoriesManager categoriesManager,
    double balance,
    double totalIncome,
    double totalExpense,
    List<Transaction> recentTransactions,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trang chủ',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng tìm kiếm sẽ được triển khai'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Tìm kiếm',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng thông báo sẽ được triển khai'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Thông báo',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT COLUMN (45%) - Balance, Summary, Savings
          Expanded(
            flex: 45,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Balance Card - Compact
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Số dư hiện tại',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Income & Expense Cards
                  Row(
                    children: [
                      // Income Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_downward,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Thu nhập',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatCurrency(totalIncome),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Expense Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_upward,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Chi tiêu',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatCurrency(totalExpense),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress Bar - Spending Analysis
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        const Text(
                          'Phân tích chi tiêu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: totalIncome > 0
                                ? (totalExpense / totalIncome).clamp(0.0, 1.0)
                                : 0,
                            minHeight: 10,
                            backgroundColor: Colors.green.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              totalExpense > totalIncome
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              totalIncome > 0
                                  ? '${((totalExpense / totalIncome) * 100).toStringAsFixed(1)}%'
                                  : '0%',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              totalIncome > totalExpense
                                  ? 'Còn lại: ${_formatCurrencyShort(totalIncome - totalExpense)}'
                                  : 'Vượt chi!',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: totalIncome > totalExpense
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Savings Goals - Compact
                  SavingsGoalsBlock(),
                ],
              ),
            ),
          ),

          // RIGHT COLUMN (55%) - Reports & Recent Transactions
          Expanded(
            flex: 55,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reports Carousel
                  SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        PageView(
                          controller: _reportPageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentReportPage = index;
                            });
                          },
                          children: [
                            _buildMonthlyReportCard(transactionsManager),
                            _buildMonthlyIncomeReportCard(transactionsManager),
                          ],
                        ),
                        Positioned(
                          left: 8,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                if (_currentReportPage > 0) {
                                  _reportPageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                if (_currentReportPage < 1) {
                                  _reportPageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentReportPage == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentReportPage == index
                              ? Colors.green
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Giao dịch gần đây',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Transaction List
                  recentTransactions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Chưa có giao dịch nào',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = recentTransactions[index];
                            final category = categoriesManager.items.firstWhere(
                              (c) => c.id == transaction.categoryId,
                              orElse: () => categoriesManager.items.first,
                            );
                            final isIncome = transaction.type == 'income';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _parseColor(
                                      category.color,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getIconData(category.icon),
                                    color: _parseColor(category.color),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  _formatDate(transaction.date),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'} ${_formatCurrency(transaction.amount)}',
                                  style: TextStyle(
                                    color: isIncome ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tính tổng chi tiêu tháng trước
  double _getPreviousMonthExpense(TransactionsManager transactionsManager) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final startOfLastMonth = DateTime(lastMonth.year, lastMonth.month, 1);
    final endOfLastMonth = DateTime(
      lastMonth.year,
      lastMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    return transactionsManager.transactions
        .where(
          (t) =>
              t.type == 'expense' &&
              t.date.isAfter(
                startOfLastMonth.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(endOfLastMonth.add(const Duration(seconds: 1))),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Tính tổng thu nhập tháng trước
  double _getPreviousMonthIncome(TransactionsManager transactionsManager) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final startOfLastMonth = DateTime(lastMonth.year, lastMonth.month, 1);
    final endOfLastMonth = DateTime(
      lastMonth.year,
      lastMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    return transactionsManager.transactions
        .where(
          (t) =>
              t.type == 'income' &&
              t.date.isAfter(
                startOfLastMonth.subtract(const Duration(seconds: 1)),
              ) &&
              t.date.isBefore(endOfLastMonth.add(const Duration(seconds: 1))),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Báo cáo chi tiêu tháng này với dữ liệu thật
  Widget _buildMonthlyReportCard(TransactionsManager transactionsManager) {
    final currentMonth = transactionsManager.totalExpense;
    final previousMonth = _getPreviousMonthExpense(transactionsManager);

    // Tính % thay đổi
    String percentageText;
    if (previousMonth == 0) {
      percentageText = currentMonth > 0 ? 'Mới bắt đầu' : 'Chưa có chi tiêu';
    } else {
      final change = ((currentMonth - previousMonth) / previousMonth) * 100;
      percentageText = change > 0
          ? '+${change.toStringAsFixed(1)}%'
          : '${change.toStringAsFixed(1)}%';
    }

    // Tính chiều cao cột cho bar chart
    final maxValue = currentMonth > previousMonth
        ? currentMonth
        : previousMonth;
    final currentHeight = maxValue > 0 ? (currentMonth / maxValue) * 100 : 50.0;
    final previousHeight = maxValue > 0
        ? (previousMonth / maxValue) * 100
        : 50.0;

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
            _formatCurrency(currentMonth),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: previousHeight.clamp(30.0, 100.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
                      border: Border.all(color: Colors.red.shade300, width: 1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tháng trước',
                    style: TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCurrencyShort(currentMonth),
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 70,
                    height: currentHeight.clamp(30.0, 100.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      border: Border.all(
                        color: Colors.red.shade700,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tháng này',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Báo cáo thu nhập tháng này với dữ liệu thật
  Widget _buildMonthlyIncomeReportCard(
    TransactionsManager transactionsManager,
  ) {
    final currentMonth = transactionsManager.totalIncome;
    final previousMonth = _getPreviousMonthIncome(transactionsManager);

    // Tính % thay đổi
    String percentageText;
    if (previousMonth == 0) {
      percentageText = currentMonth > 0 ? 'Mới bắt đầu' : 'Chưa có thu nhập';
    } else {
      final change = ((currentMonth - previousMonth) / previousMonth) * 100;
      percentageText = change > 0
          ? '+${change.toStringAsFixed(1)}%'
          : '${change.toStringAsFixed(1)}%';
    }

    // Tính chiều cao cột cho bar chart
    final maxValue = currentMonth > previousMonth
        ? currentMonth
        : previousMonth;
    final currentHeight = maxValue > 0 ? (currentMonth / maxValue) * 100 : 50.0;
    final previousHeight = maxValue > 0
        ? (previousMonth / maxValue) * 100
        : 50.0;

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
            _formatCurrency(currentMonth),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: previousHeight.clamp(30.0, 100.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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
                        color: Colors.green.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tháng trước',
                    style: TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCurrencyShort(currentMonth),
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 70,
                    height: currentHeight.clamp(30.0, 100.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      border: Border.all(
                        color: Colors.green.shade700,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tháng này',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
