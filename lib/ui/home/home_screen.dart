import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/ui/shared/app_drawer.dart';
import '/ui/transactions/transactions_manager.dart';

// Import các widget components
import 'balance_card.dart';
import 'income_expense_cards.dart';
import 'spending_analysis_card.dart';
import 'monthly_report_card.dart';
import 'trend_report_card.dart';
import 'recent_transactions_list.dart';

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

    final balance = transactionsManager.balance;
    final totalIncome = transactionsManager.totalIncome;
    final totalExpense = transactionsManager.totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trang chủ',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FD),
        surfaceTintColor: Colors.transparent,
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
      body: Container(
        color: const Color(0xFFF8F9FD), // Subtle background color
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              BalanceCard(balance: balance),

              const SizedBox(height: 8),

              // Income & Expense Cards
              IncomeExpenseCards(
                totalIncome: totalIncome,
                totalExpense: totalExpense,
              ),

              const SizedBox(height: 20),

              // Spending Analysis
              SpendingAnalysisCard(
                totalIncome: totalIncome,
                totalExpense: totalExpense,
              ),

              const SizedBox(height: 20),

              // Reports Carousel
              SizedBox(
                height: 320,
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
                        // Monthly Report
                        MonthlyReportCard(totalExpense: totalExpense),
                        // Trend Report
                        TrendReportCard(
                          totalExpense: totalExpense,
                          totalIncome: totalIncome,
                        ),
                      ],
                    ),
                    // Navigation buttons
                    _buildNavigationButton(
                      alignment: Alignment.centerLeft,
                      icon: Icons.chevron_left,
                      onPressed: () {
                        if (_currentReportPage > 0) {
                          _reportPageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                    _buildNavigationButton(
                      alignment: Alignment.centerRight,
                      icon: Icons.chevron_right,
                      onPressed: () {
                        if (_currentReportPage < 1) {
                          _reportPageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Dots indicator
              _buildPageIndicator(),

              const SizedBox(height: 20),

              // Recent Transactions
              const RecentTransactionsList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng nút điều hướng cho carousel
  Widget _buildNavigationButton({
    required Alignment alignment,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Positioned(
      left: alignment == Alignment.centerLeft ? 8 : null,
      right: alignment == Alignment.centerRight ? 8 : null,
      top: 0,
      bottom: 0,
      child: Center(
        child: IconButton(
          icon: Icon(icon, color: Colors.green),
          onPressed: onPressed,
        ),
      ),
    );
  }

  /// Xây dựng chỉ báo trang (dots)
  Widget _buildPageIndicator() {
    return Row(
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
    );
  }
}
