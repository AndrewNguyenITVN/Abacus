import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/ui/savings_goals/savings_goals_manager.dart';
import '/ui/savings_goals/add_edit_goal_screen.dart';
import 'savings_goal_card.dart';

class SavingsGoalsScreen extends StatefulWidget {
  final String? selectedGoalId;

  const SavingsGoalsScreen({super.key, this.selectedGoalId});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mục tiêu tiết kiệm',
          style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'Đang thực hiện'),
            Tab(text: 'Hoàn thành'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditGoalScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGoalsList(isCompleted: false),
          _buildGoalsList(isCompleted: true),
        ],
      ),
    );
  }

  Widget _buildGoalsList({required bool isCompleted}) {
    final goalsManager = context.watch<SavingsGoalsManager>();
    final colorScheme = Theme.of(context).colorScheme;
    
    final goals = isCompleted
        ? goalsManager.completedGoals
        : goalsManager.activeGoals;

    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_outline : Icons.emoji_events_outlined,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted
                  ? 'Chưa có mục tiêu nào hoàn thành'
                  : 'Chưa có mục tiêu đang thực hiện',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return SavingsGoalCard(goal: goal, isDetailMode: true);
      },
    );
  }
}
