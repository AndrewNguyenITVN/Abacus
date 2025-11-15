import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/ui/savings_goals/savings_goals_manager.dart';
import '/ui/savings_goals/add_edit_goal_screen.dart';
import '/models/savings_goal.dart';

// Helper function to format currency
String _formatCurrency(double amount) {
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  return formatter.format(amount);
}

// Helper function to format date
String _formatDate(DateTime date) {
  final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
  return formatter.format(date);
}

// Helper function to get icon data
IconData _getIconData(String iconName) {
  const iconMap = {
    'home': Icons.home,
    'two_wheeler': Icons.two_wheeler,
    'directions_car': Icons.directions_car,
    'flight': Icons.flight,
    'beach_access': Icons.beach_access,
    'school': Icons.school,
    'laptop': Icons.laptop,
    'phone_android': Icons.phone_android,
    'shopping_bag': Icons.shopping_bag,
    'savings': Icons.savings,
    'account_balance': Icons.account_balance,
    'card_giftcard': Icons.card_giftcard,
  };
  return iconMap[iconName] ?? Icons.savings;
}

// Helper function to parse color
Color _parseColor(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mục tiêu tiết kiệm',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
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
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted
                  ? 'Chưa có mục tiêu nào hoàn thành'
                  : 'Chưa có mục tiêu đang thực hiện',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
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
        return _buildGoalCard(context, goal);
      },
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingsGoal goal) {
    final color = _parseColor(goal.color);
    final daysRemaining = goal.daysRemaining;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showGoalDetailDialog(context, goal),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(goal.icon),
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (goal.description != null && goal.description!.isNotEmpty)
                          Text(
                            goal.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddEditGoalScreen(goal: goal),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmDialog(context, goal);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${goal.progressPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progressPercentage / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatCurrency(goal.currentAmount),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    _formatCurrency(goal.targetAmount),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Info row
              Row(
                children: [
                  if (daysRemaining != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      daysRemaining > 0
                          ? 'Còn $daysRemaining ngày'
                          : 'Đã đến hạn',
                      style: TextStyle(
                        fontSize: 12,
                        color: daysRemaining > 30
                            ? Colors.grey.shade600
                            : Colors.orange.shade700,
                        fontWeight: daysRemaining <= 30
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(
                    Icons.trending_up,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Còn ${_formatCurrency(goal.remainingAmount)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              if (!goal.isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showUpdateProgressDialog(context, goal, isAdd: true),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Thêm tiền'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showUpdateProgressDialog(context, goal, isAdd: false),
                        icon: const Icon(Icons.remove, size: 18),
                        label: const Text('Rút tiền'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalDetailDialog(BuildContext context, SavingsGoal goal) {
    final color = _parseColor(goal.color);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconData(goal.icon),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                goal.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (goal.description != null && goal.description!.isNotEmpty) ...[
                Text(
                  goal.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildDetailRow('Mục tiêu', _formatCurrency(goal.targetAmount)),
              _buildDetailRow('Đã tiết kiệm', _formatCurrency(goal.currentAmount)),
              _buildDetailRow('Còn lại', _formatCurrency(goal.remainingAmount)),
              _buildDetailRow('Tiến độ', '${goal.progressPercentage.toStringAsFixed(1)}%'),
              if (goal.targetDate != null)
                _buildDetailRow('Hạn hoàn thành', _formatDate(goal.targetDate!)),
              if (goal.daysRemaining != null)
                _buildDetailRow(
                  'Còn lại',
                  goal.daysRemaining! > 0
                      ? '${goal.daysRemaining} ngày'
                      : 'Đã đến hạn',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditGoalScreen(goal: goal),
                ),
              );
            },
            child: const Text('Chỉnh sửa'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(BuildContext context, SavingsGoal goal, {required bool isAdd}) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(isAdd ? 'Thêm tiền vào mục tiêu' : 'Rút tiền từ mục tiêu'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Số dư hiện tại: ${_formatCurrency(goal.currentAmount)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  hintText: 'Nhập số tiền',
                  prefixText: '₫ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Số tiền không hợp lệ';
                  }
                  if (!isAdd && amount > goal.currentAmount) {
                    return 'Số tiền vượt quá số dư hiện tại';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(controller.text);
                final goalsManager = context.read<SavingsGoalsManager>();
                
                try {
                  await goalsManager.updateProgress(
                    goal.id,
                    isAdd ? amount : -amount,
                  );
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isAdd
                              ? 'Đã thêm ${_formatCurrency(amount)} vào mục tiêu'
                              : 'Đã rút ${_formatCurrency(amount)} từ mục tiêu',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Có lỗi xảy ra: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAdd ? Colors.green : Colors.orange,
            ),
            child: Text(isAdd ? 'Thêm tiền' : 'Rút tiền'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa mục tiêu "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final goalsManager = context.read<SavingsGoalsManager>();
              try {
                await goalsManager.deleteGoal(goal.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa mục tiêu'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Có lỗi xảy ra: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

