import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/ui/transactions/transactions_manager.dart';
import '/ui/categories/categories_manager.dart';
import '/ui/savings_goals/savings_goals_block.dart';
import '/ui/notifications/notifications_manager.dart';
import '/ui/notifications/notifications_bottom_sheet.dart';
import '/ui/bottom_nav_bar_screen.dart';
import 'home_summary_cards.dart';
import 'monthly_report_cards.dart';
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
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return _buildLandscapeLayout();
        } else {
          return _buildPortraitLayout();
        }
      },
    );
  }

  Widget _buildPortraitLayout() {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  Widget _buildLandscapeLayout() {
    final transactionsManager = context.watch<TransactionsManager>();
    final categoriesManager = context.watch<CategoriesManager>();

    return Scaffold(
      appBar: _buildAppBar(),
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
                  HomeBalanceCard(balance: transactionsManager.balance),
                  const SizedBox(height: 16),
                  // Income & Expense Cards
                  HomeIncomeExpenseCard(
                    totalIncome: transactionsManager.totalIncome,
                    totalExpense: transactionsManager.totalExpense,
                  ),
                  const SizedBox(height: 16),
                  // Spending Analysis
                  HomeSpendingAnalysis(
                    totalIncome: transactionsManager.totalIncome,
                    totalExpense: transactionsManager.totalExpense,
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
                  _buildReportsCarousel(transactionsManager),
                  const SizedBox(height: 8),
                  // Dots Indicator
                  _buildDotsIndicator(),
                  const SizedBox(height: 20),
                  // Recent Transactions Header & List
                  _buildRecentTransactionsSection(
                    transactionsManager,
                    categoriesManager,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Trang chủ',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      elevation: 0,
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
        _buildNotificationButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Consumer<NotificationsManager>(
      builder: (context, notificationsManager, _) {
        final unreadCount = notificationsManager.unreadCount;
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                showNotificationsBottomSheet(context);
              },
              tooltip: 'Thông báo',
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    final transactionsManager = context.watch<TransactionsManager>();
    final categoriesManager = context.watch<CategoriesManager>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: HomeBalanceCard(balance: transactionsManager.balance),
          ),

          // Income & Expense Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeIncomeExpenseCard(
              totalIncome: transactionsManager.totalIncome,
              totalExpense: transactionsManager.totalExpense,
            ),
          ),

          const SizedBox(height: 24),

          // Spending Analysis
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HomeSpendingAnalysis(
              totalIncome: transactionsManager.totalIncome,
              totalExpense: transactionsManager.totalExpense,
            ),
          ),

          const SizedBox(height: 24),

          // Reports Carousel
          _buildReportsCarousel(transactionsManager),

          const SizedBox(height: 8),

          // Dots Indicator
          _buildDotsIndicator(),

          const SizedBox(height: 24),

          // Savings Goals
          SavingsGoalsBlock(),

          const SizedBox(height: 24),

          // Recent Transactions
          _buildRecentTransactionsSection(
            transactionsManager,
            categoriesManager,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReportsCarousel(TransactionsManager transactionsManager) {
    return SizedBox(
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
              MonthlyReportCard(
                currentMonthAmount: transactionsManager.totalExpense,
                previousMonthAmount: transactionsManager.previousMonthExpense,
                reportType: ReportType.expense,
              ),
              MonthlyReportCard(
                currentMonthAmount: transactionsManager.totalIncome,
                previousMonthAmount: transactionsManager.previousMonthIncome,
                reportType: ReportType.income,
              ),
            ],
          ),
          // Navigation Arrows
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.green),
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
                icon: const Icon(Icons.chevron_right, color: Colors.green),
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
    );
  }

  Widget _buildDotsIndicator() {
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

  Widget _buildRecentTransactionsSection(
    TransactionsManager transactionsManager,
    CategoriesManager categoriesManager,
  ) {
    final recentTransactions = transactionsManager.getRecentTransactions(7);

    return Column(
      children: [
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
                  // Navigate đến Transactions screen (index 1)
                  final bottomNavState = context
                      .findAncestorStateOfType<BottomNavBarScreenState>();
                  bottomNavState?.navigateToIndex(1);
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        RecentTransactionsList(
          transactions: recentTransactions,
          categories: categoriesManager.items,
        ),
      ],
    );
  }
}
