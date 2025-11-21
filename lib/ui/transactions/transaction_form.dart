import 'package:flutter/material.dart';
import '/models/transaction_type.dart';
import '/models/my_category.dart';
import '../savings_goals/quick_amount_selector.dart';
import '../shared/app_constants.dart';
import '../shared/app_helpers.dart';

class TransactionForm extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;
  final TextEditingController amountController;
  final VoidCallback onAmountChanged;
  final List<MyCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController descriptionController;
  final String actionButtonText;
  final VoidCallback onActionTap;
  final bool isDelete;
  final VoidCallback? onDeleteTap;

  const TransactionForm({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.amountController,
    required this.onAmountChanged,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.descriptionController,
    required this.actionButtonText,
    required this.onActionTap,
    this.isDelete = false,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTypeSelector(),
        const SizedBox(height: 20),
        _buildAmountInputCard(),
        const SizedBox(height: 16),
        QuickAmountSelector(
          controller: amountController,
          onChanged: onAmountChanged,
        ),
        const SizedBox(height: 20),
        _buildCategorySelector(),
        const SizedBox(height: 20),
        _buildDescriptionInput(),
        const SizedBox(height: 32),
        _buildActionButton(context),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- Type Selector ---

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.expense,
              label: 'Chi tiêu',
              icon: Icons.trending_down_rounded,
              gradient: AppConstants.expenseGradient,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.income,
              label: 'Thu nhập',
              icon: Icons.trending_up_rounded,
              gradient: AppConstants.incomeGradient,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required String label,
    required IconData icon,
    required List<Color> gradient,
  }) {
    final isSelected = selectedType == type;
    return InkWell(
      onTap: () => onTypeChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradient) : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Amount Input ---

  Widget _buildAmountInputCard() {
    final gradient = selectedType == TransactionType.expense
        ? AppConstants.expenseGradient
        : AppConstants.incomeGradient;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  selectedType == TransactionType.expense
                      ? Icons.remove_rounded
                      : Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Số tiền',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: amountController,
            onChanged: (_) => onAmountChanged(),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 32,
                color: Colors.grey.shade300,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              suffixText: '₫',
              suffixStyle: const TextStyle(
                fontSize: 24,
                color: Color(0xFF1a1a2e),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a2e),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số tiền';
              }
              final amount = AppHelpers.parseAmount(value);
              if (amount == null || amount <= 0) {
                return 'Số tiền không hợp lệ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // --- Category Selector ---

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Danh mục',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedCategoryId,
            hint: Text(
              'Chọn danh mục',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF11998e),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            onChanged: onCategoryChanged,
            items: categories.map<DropdownMenuItem<String>>((MyCategory category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Row(
                  children: [
                    Icon(
                      AppHelpers.getIconData(category.icon),
                      size: 18,
                      color: AppHelpers.parseColor(category.color),
                    ),
                    const SizedBox(width: 8),
                    Text(category.name),
                  ],
                ),
              );
            }).toList(),
            validator: (value) =>
                value == null ? 'Vui lòng chọn danh mục' : null,
          ),
        ],
      ),
    );
  }

  // --- Description Input ---

  Widget _buildDescriptionInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notes_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ghi chú',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Thêm ghi chú cho giao dịch này...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF11998e),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // --- Action Button ---

  Widget _buildActionButton(BuildContext context) {
    final gradient = selectedType == TransactionType.expense
        ? AppConstants.expenseGradient
        : AppConstants.incomeGradient;

    final shadowColor = selectedType == TransactionType.expense
        ? const Color(0xFFee0979)
        : const Color(0xFF11998e);

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onActionTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  actionButtonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
