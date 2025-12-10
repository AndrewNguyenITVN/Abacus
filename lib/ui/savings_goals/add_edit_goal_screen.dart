import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/ui/savings_goals/savings_goals_manager.dart';
import '/models/savings_goal.dart';
import '../shared/app_helpers.dart';
import '../shared/app_constants.dart';
import 'quick_amount_selector.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.goal!.name;
      _descriptionController.text = widget.goal!.description ?? '';
      // Format numbers when loading
      final formatter = NumberFormat.decimalPattern('vi_VN');
      _targetAmountController.text = formatter.format(widget.goal!.targetAmount);
      _currentAmountController.text = formatter.format(widget.goal!.currentAmount);
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Chỉnh sửa mục tiêu' : 'Tạo mục tiêu mới',
          style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
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
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Tên mục tiêu *',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  hintText: 'VD: Mua xe máy, Du lịch,...',
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  prefixIcon: Icon(Icons.label, color: colorScheme.onSurfaceVariant),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Vui lòng nhập tên mục tiêu' : null,
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  hintText: 'Mô tả chi tiết về mục tiêu...',
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  prefixIcon: Icon(Icons.description, color: colorScheme.onSurfaceVariant),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Target Amount
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Số tiền mục tiêu *',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  hintText: 'Nhập số tiền',
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  prefixIcon: Icon(Icons.attach_money, color: colorScheme.onSurfaceVariant),
                  suffixText: '₫',
                  suffixStyle: TextStyle(color: colorScheme.onSurface),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền mục tiêu';
                  final amount = AppHelpers.parseAmount(value);
                  if (amount == null || amount <= 0) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),

              const SizedBox(height: 8),
              QuickAmountSelector(
                controller: _targetAmountController,
                onChanged: () => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Current Amount
              TextFormField(
                controller: _currentAmountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Số tiền hiện tại',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  hintText: 'Nhập số tiền đã tiết kiệm',
                  hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  prefixIcon: Icon(Icons.account_balance_wallet, color: colorScheme.onSurfaceVariant),
                  suffixText: '₫',
                  suffixStyle: TextStyle(color: colorScheme.onSurface),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final amount = AppHelpers.parseAmount(value);
                    if (amount == null || amount < 0) return 'Số tiền không hợp lệ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),
              QuickAmountSelector(
                controller: _currentAmountController,
                onChanged: () => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Target Date
              InkWell(
                onTap: () => _selectTargetDate(context),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hạn hoàn thành',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    prefixIcon: Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant),
                    suffixIcon: _targetDate != null
                        ? IconButton(
                            icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                            onPressed: () => setState(() => _targetDate = null),
                          )
                        : null,
                  ),
                  child: Text(
                    _targetDate != null
                        ? AppHelpers.formatDate(_targetDate!)
                        : 'Chọn ngày hoàn thành (tùy chọn)',
                    style: TextStyle(
                      color: _targetDate != null ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.6),
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
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isEditing ? 'Cập nhật mục tiêu' : 'Tạo mục tiêu',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    final selectedColor = AppHelpers.parseColor(_selectedColor);
    final selectedIconData = AppHelpers.getIconData(_selectedIcon);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selectedColor.withOpacity(isDark ? 0.2 : 0.1),
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
            child: Icon(selectedIconData, size: 48, color: selectedColor),
          ),
          const SizedBox(height: 16),

          // Icon selection
          Text('Chọn biểu tượng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          
          // Using GridView for Icons (Similar to Categories)
          Container(
            height: 150,
            decoration: BoxDecoration(
               color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
               borderRadius: BorderRadius.circular(12),
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: AppConstants.iconMap.length,
              itemBuilder: (context, index) {
                final entry = AppConstants.iconMap.entries.elementAt(index);
                final isSelected = entry.key == _selectedIcon;
                
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = entry.key),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? selectedColor.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: selectedColor) : null,
                    ),
                    child: Icon(
                      entry.value,
                      size: 20,
                      color: isSelected ? selectedColor : colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Color selection
          Text('Chọn màu sắc', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.colorOptions.map((option) {
              final isSelected = option['hex'] == _selectedColor;
              final color = option['color'] as Color;
              return InkWell(
                onTap: () => setState(() => _selectedColor = option['hex'] as String),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? colorScheme.onSurface : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
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
    if (_nameController.text.isEmpty && _targetAmountController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final targetAmount = AppHelpers.parseAmount(_targetAmountController.text) ?? 0;
    final currentAmount = AppHelpers.parseAmount(_currentAmountController.text) ?? 0;
    final progress = targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

    final selectedColor = AppHelpers.parseColor(_selectedColor);
    final selectedIconData = AppHelpers.getIconData(_selectedIcon);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Xem trước', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(isDark ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(selectedIconData, color: selectedColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty ? 'Tên mục tiêu' : _nameController.text,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                    ),
                    if (_targetDate != null)
                      Text(
                        'Đến ${AppHelpers.formatDate(_targetDate!)}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                      ),
                  ],
                ),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: selectedColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(selectedColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppHelpers.formatCurrency(currentAmount),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700),
              ),
              Text(
                AppHelpers.formatCurrency(targetAmount),
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
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
    );
    if (picked != null && picked != _targetDate) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final goalsManager = context.read<SavingsGoalsManager>();
    
    final targetAmount = AppHelpers.parseAmount(_targetAmountController.text)!;
    final currentAmount = AppHelpers.parseAmount(_currentAmountController.text) ?? 0.0;

    try {
      if (_isEditing) {
        final updatedGoal = widget.goal!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          targetDate: _targetDate,
          icon: _selectedIcon,
          color: _selectedColor,
          updatedAt: DateTime.now(),
        );
        await goalsManager.updateGoal(updatedGoal);
      } else {
        final newGoal = SavingsGoal(
          id: 'g${DateTime.now().millisecondsSinceEpoch}',
          userId: '', // Placeholder, Manager will set correct userId
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Đã cập nhật mục tiêu' : 'Đã tạo mục tiêu mới'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

}
