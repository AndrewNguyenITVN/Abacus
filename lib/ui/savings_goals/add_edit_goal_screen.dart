import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/ui/savings_goals/savings_goals_manager.dart';
import '/models/savings_goal.dart';

class AddEditGoalScreen extends StatefulWidget {
  final SavingsGoal? goal;

  const AddEditGoalScreen({super.key, this.goal});

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();

  DateTime? _targetDate;
  String _selectedIcon = 'savings';
  String _selectedColor = '#4CAF50';

  bool get _isEditing => widget.goal != null;

  // Icon options
  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'savings', 'icon': Icons.savings, 'label': 'Tiết kiệm'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Nhà'},
    {'name': 'directions_car', 'icon': Icons.directions_car, 'label': 'Ô tô'},
    {'name': 'two_wheeler', 'icon': Icons.two_wheeler, 'label': 'Xe máy'},
    {'name': 'flight', 'icon': Icons.flight, 'label': 'Du lịch'},
    {'name': 'beach_access', 'icon': Icons.beach_access, 'label': 'Nghỉ dưỡng'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Học tập'},
    {'name': 'laptop', 'icon': Icons.laptop, 'label': 'Laptop'},
    {'name': 'phone_android', 'icon': Icons.phone_android, 'label': 'Điện thoại'},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag, 'label': 'Mua sắm'},
    {'name': 'account_balance', 'icon': Icons.account_balance, 'label': 'Ngân hàng'},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard, 'label': 'Quà tặng'},
  ];

  // Color options
  final List<Map<String, dynamic>> _colorOptions = [
    {'hex': '#4CAF50', 'color': const Color(0xFF4CAF50), 'label': 'Xanh lá'},
    {'hex': '#2196F3', 'color': const Color(0xFF2196F3), 'label': 'Xanh dương'},
    {'hex': '#FF5722', 'color': const Color(0xFFFF5722), 'label': 'Đỏ cam'},
    {'hex': '#9C27B0', 'color': const Color(0xFF9C27B0), 'label': 'Tím'},
    {'hex': '#FF9800', 'color': const Color(0xFFFF9800), 'label': 'Cam'},
    {'hex': '#F44336', 'color': const Color(0xFFF44336), 'label': 'Đỏ'},
    {'hex': '#00BCD4', 'color': const Color(0xFF00BCD4), 'label': 'Xanh cyan'},
    {'hex': '#FFEB3B', 'color': const Color(0xFFFFEB3B), 'label': 'Vàng'},
    {'hex': '#795548', 'color': const Color(0xFF795548), 'label': 'Nâu'},
    {'hex': '#607D8B', 'color': const Color(0xFF607D8B), 'label': 'Xám xanh'},
    {'hex': '#E91E63', 'color': const Color(0xFFE91E63), 'label': 'Hồng'},
    {'hex': '#009688', 'color': const Color(0xFF009688), 'label': 'Xanh ngọc'},
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.goal!.name;
      _descriptionController.text = widget.goal!.description ?? '';
      _targetAmountController.text = widget.goal!.targetAmount.toString();
      _currentAmountController.text = widget.goal!.currentAmount.toString();
      _targetDate = widget.goal!.targetDate;
      _selectedIcon = widget.goal!.icon;
      _selectedColor = widget.goal!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Chỉnh sửa mục tiêu' : 'Tạo mục tiêu mới',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Color Selection
              _buildIconColorSelection(),

              const SizedBox(height: 24),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên mục tiêu *',
                  hintText: 'VD: Mua xe máy, Du lịch,...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên mục tiêu';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Mô tả chi tiết về mục tiêu...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Target Amount
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền mục tiêu *',
                  hintText: 'Nhập số tiền',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: '₫',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền mục tiêu';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Số tiền không hợp lệ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Current Amount
              TextFormField(
                controller: _currentAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền hiện tại',
                  hintText: 'Nhập số tiền đã tiết kiệm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  suffixText: '₫',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'Số tiền không hợp lệ';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Target Date
              InkWell(
                onTap: () => _selectTargetDate(context),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hạn hoàn thành',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: _targetDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _targetDate = null;
                              });
                            },
                          )
                        : null,
                  ),
                  child: Text(
                    _targetDate != null
                        ? DateFormat('dd/MM/yyyy', 'vi_VN').format(_targetDate!)
                        : 'Chọn ngày hoàn thành (tùy chọn)',
                    style: TextStyle(
                      color: _targetDate != null
                          ? Colors.black87
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Preview
              _buildPreview(),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Cập nhật mục tiêu' : 'Tạo mục tiêu',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconColorSelection() {
    final selectedColor = _colorOptions.firstWhere(
      (c) => c['hex'] == _selectedColor,
      orElse: () => _colorOptions[0],
    )['color'] as Color;

    final selectedIconData = _iconOptions.firstWhere(
      (i) => i['name'] == _selectedIcon,
      orElse: () => _iconOptions[0],
    )['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selectedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selectedColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Preview icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: selectedColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              selectedIconData,
              size: 48,
              color: selectedColor,
            ),
          ),

          const SizedBox(height: 16),

          // Icon selection
          const Text(
            'Chọn biểu tượng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _iconOptions.map((option) {
              final isSelected = option['name'] == _selectedIcon;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIcon = option['name'] as String;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withOpacity(0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? selectedColor
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    option['icon'] as IconData,
                    size: 24,
                    color: isSelected ? selectedColor : Colors.grey.shade600,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Color selection
          const Text(
            'Chọn màu sắc',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorOptions.map((option) {
              final isSelected = option['hex'] == _selectedColor;
              final color = option['color'] as Color;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedColor = option['hex'] as String;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.black87 : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_nameController.text.isEmpty &&
        _targetAmountController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
    final currentAmount = double.tryParse(_currentAmountController.text) ?? 0;
    final progress = targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

    final selectedColor = _colorOptions.firstWhere(
      (c) => c['hex'] == _selectedColor,
      orElse: () => _colorOptions[0],
    )['color'] as Color;

    final selectedIconData = _iconOptions.firstWhere(
      (i) => i['name'] == _selectedIcon,
      orElse: () => _iconOptions[0],
    )['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xem trước',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  selectedIconData,
                  color: selectedColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty
                          ? 'Tên mục tiêu'
                          : _nameController.text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_targetDate != null)
                      Text(
                        'Đến ${DateFormat('dd/MM/yyyy').format(_targetDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: selectedColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(selectedColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                    .format(currentAmount),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              Text(
                NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                    .format(targetAmount),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectTargetDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final goalsManager = context.read<SavingsGoalsManager>();
    final targetAmount = double.parse(_targetAmountController.text);
    final currentAmount = _currentAmountController.text.isEmpty
        ? 0.0
        : double.parse(_currentAmountController.text);

    try {
      if (_isEditing) {
        // Update existing goal
        final updatedGoal = widget.goal!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          targetDate: _targetDate,
          icon: _selectedIcon,
          color: _selectedColor,
          updatedAt: DateTime.now(),
        );
        await goalsManager.updateGoal(updatedGoal);
      } else {
        // Create new goal
        final newGoal = SavingsGoal(
          id: 'g${DateTime.now().millisecondsSinceEpoch}',
          userId: 'user1', // TODO: Get from auth
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          targetDate: _targetDate,
          icon: _selectedIcon,
          color: _selectedColor,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await goalsManager.addGoal(newGoal);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Đã cập nhật mục tiêu'
                  : 'Đã tạo mục tiêu mới',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

