import 'package:flutter/foundation.dart';
import '../../models/savings_goal.dart';
import '../../models/account.dart';
import '../../services/savings_goal_service.dart';

class SavingsGoalsManager extends ChangeNotifier {
  final SavingsGoalService _goalService = SavingsGoalService();
  
  List<SavingsGoal> _goals = [];
  bool _isLoaded = false;
  String? _userId;

  SavingsGoalsManager();

  void update(Account? user) {
    if (user == null) {
      _userId = null;
      _goals = [];
      _isLoaded = false;
      notifyListeners();
      return;
    }

    if (_userId != user.id || !_isLoaded) {
      _userId = user.id;
      _loadGoals();
    }
  }

  bool get isLoaded => _isLoaded;

  // Load goals từ SQLite
  Future<void> _loadGoals() async {
    if (_userId == null) return;
    try {
      _goals = await _goalService.getGoals(_userId!);
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      print('Error loading goals: $e');
      _isLoaded = true;
      notifyListeners();
    }
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
    if (_userId == null) return;
    try {
      final goalWithUserId = goal.copyWith(userId: _userId);
      await _goalService.insertGoal(goalWithUserId);
      _goals.add(goalWithUserId);
      notifyListeners();
    } catch (error) {
      print('Error adding goal: $error');
      rethrow;
    }
  }

  // Update goal
  Future<void> updateGoal(SavingsGoal updatedGoal) async {
    if (_userId == null) return;
    try {
      final goalWithTimestamp = updatedGoal.copyWith(
        userId: _userId,
        updatedAt: DateTime.now(),
      );
      await _goalService.updateGoal(goalWithTimestamp);
      
      final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = goalWithTimestamp;
        notifyListeners();
      }
    } catch (error) {
      print('Error updating goal: $error');
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
      await _goalService.deleteGoal(id);
      _goals.removeWhere((g) => g.id == id);
      notifyListeners();
    } catch (error) {
      print('Error deleting goal: $error');
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

  // Refresh goals từ database
  Future<void> fetchGoals() async {
    _isLoaded = false;
    await _loadGoals();
  }
}

