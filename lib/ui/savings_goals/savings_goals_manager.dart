import 'package:flutter/foundation.dart';
import '/models/savings_goal.dart';

class SavingsGoalsManager extends ChangeNotifier {
  final List<SavingsGoal> _goals = [];

  SavingsGoalsManager() {
    // Sample data for demonstration
    final now = DateTime.now();
    _goals.addAll([
      SavingsGoal(
        id: 'g1',
        userId: 'user1',
        name: 'Mua xe máy',
        description: 'Tiết kiệm để mua xe máy mới',
        targetAmount: 40000000,
        currentAmount: 15000000,
        targetDate: now.add(const Duration(days: 180)),
        icon: 'two_wheeler',
        color: '#FF5722',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      SavingsGoal(
        id: 'g2',
        userId: 'user1',
        name: 'Mua nhà',
        description: 'Tiết kiệm để mua nhà',
        targetAmount: 500000000,
        currentAmount: 80000000,
        targetDate: now.add(const Duration(days: 730)),
        icon: 'home',
        color: '#4CAF50',
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
      ),
      SavingsGoal(
        id: 'g3',
        userId: 'user1',
        name: 'Du lịch Nhật Bản',
        description: 'Chuyến du lịch mùa hè',
        targetAmount: 30000000,
        currentAmount: 25000000,
        targetDate: now.add(const Duration(days: 120)),
        icon: 'flight',
        color: '#2196F3',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
    ]);
  }

  // Getters
  List<SavingsGoal> get goals => [..._goals]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  
  List<SavingsGoal> get activeGoals => goals.where((g) => !g.isCompleted).toList();
  
  List<SavingsGoal> get completedGoals => goals.where((g) => g.isCompleted).toList();

  int get totalGoals => _goals.length;
  
  int get activeGoalsCount => activeGoals.length;
  
  int get completedGoalsCount => completedGoals.length;

  // Get total saved amount
  double get totalSaved => _goals.fold(0, (sum, goal) => sum + goal.currentAmount);

  // Get total target amount
  double get totalTarget => _goals.fold(0, (sum, goal) => sum + goal.targetAmount);

  // Get overall progress percentage
  double get overallProgress {
    if (totalTarget <= 0) return 0;
    return ((totalSaved / totalTarget) * 100).clamp(0, 100);
  }

  // Find goal by id
  SavingsGoal? findById(String id) {
    try {
      return _goals.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new goal
  Future<void> addGoal(SavingsGoal goal) async {
    try {
      // TODO: Save to PocketBase
      _goals.add(goal);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Update goal
  Future<void> updateGoal(SavingsGoal updatedGoal) async {
    try {
      final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        // TODO: Update in PocketBase
        _goals[index] = updatedGoal.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  // Update goal progress (add or subtract amount)
  Future<void> updateProgress(String goalId, double amount) async {
    try {
      final goal = findById(goalId);
      if (goal != null) {
        final newAmount = (goal.currentAmount + amount).clamp(0.0, double.infinity).toDouble();
        await updateGoal(goal.copyWith(
          currentAmount: newAmount,
          updatedAt: DateTime.now(),
        ));
      }
    } catch (error) {
      rethrow;
    }
  }

  // Delete goal
  Future<void> deleteGoal(String id) async {
    try {
      // TODO: Delete from PocketBase
      _goals.removeWhere((g) => g.id == id);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Get goals sorted by progress
  List<SavingsGoal> getGoalsSortedByProgress({bool ascending = false}) {
    final sorted = [..._goals];
    sorted.sort((a, b) {
      final comparison = a.progressPercentage.compareTo(b.progressPercentage);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  // Get goals sorted by target date
  List<SavingsGoal> getGoalsSortedByDate({bool ascending = true}) {
    final sorted = _goals.where((g) => g.targetDate != null).toList();
    sorted.sort((a, b) {
      final comparison = a.targetDate!.compareTo(b.targetDate!);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  // Get goals near deadline (within days)
  List<SavingsGoal> getGoalsNearDeadline(int days) {
    return _goals.where((g) {
      if (g.targetDate == null || g.isCompleted) return false;
      final remaining = g.daysRemaining;
      return remaining != null && remaining <= days && remaining >= 0;
    }).toList();
  }

  // Load goals from backend (placeholder)
  Future<void> fetchGoals() async {
    try {
      // TODO: Fetch from PocketBase
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}

