import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/my_category.dart';
import '../../models/transaction.dart';
import '../../models/transaction_type.dart';
import '../categories/categories_manager.dart';
import '../transactions/transactions_manager.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;
  late List<MyCategory> _categories;
  String? _selectedCategoryId;

  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateCategories();
  }

  void _updateCategories() {
    final categoriesManager = Provider.of<CategoriesManager>(context, listen: false);
    setState(() {
      _categories = _selectedType == TransactionType.expense
          ? categoriesManager.expenseCategories
          : categoriesManager.incomeCategories;
      _selectedCategoryId = null;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addAmount(String amount) {
    String currentAmount = _amountController.text.replaceAll('.', '');
    if (amount == '000') {
      if (currentAmount.isEmpty) {
        return;
      }
      currentAmount += '000';
    } else {
      int valueToAdd = int.parse(amount);
      int currentAmountInt = int.tryParse(currentAmount) ?? 0;
      currentAmount = (currentAmountInt + valueToAdd).toString();
    }
    final formatter = NumberFormat('#,###');
    _amountController.text = formatter.format(int.parse(currentAmount)).replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Thêm giao dịch',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FD),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type selector với gradient
            _buildTypeSelector(),
            
            const SizedBox(height: 20),
            
            // Amount input card
            _buildAmountCard(),
            
            const SizedBox(height: 16),
            
            // Quick amount buttons
            _buildQuickAmountButtons(),
            
            const SizedBox(height: 20),
            
            // Category selector
            _buildCategorySelector(),
            
            const SizedBox(height: 20),
            
            // Description field
            _buildDescriptionField(),
            
            const SizedBox(height: 32),
            
            // Save button
            _buildSaveButton(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Build type selector với gradient
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
              gradient: [const Color(0xFFee0979), const Color(0xFFff6a00)],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.income,
              label: 'Thu nhập',
              icon: Icons.trending_up_rounded,
              gradient: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
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
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          _updateCategories();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: gradient)
              : null,
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

  // Build amount card
  Widget _buildAmountCard() {
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
                    colors: _selectedType == TransactionType.expense
                        ? [const Color(0xFFee0979), const Color(0xFFff6a00)]
                        : [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _selectedType == TransactionType.expense
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
            controller: _amountController,
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
              if (double.tryParse(value.replaceAll('.', '')) == null) {
                return 'Vui lòng nhập một số hợp lệ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Build quick amount buttons
  Widget _buildQuickAmountButtons() {
    return Row(
      children: [
        for (var i = 0; i < ['1000', '10000', '100000', '000'].length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i < 3 ? 8 : 0,
              ),
              child: _buildQuickAmountButton(['1000', '10000', '100000', '000'][i]),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return InkWell(
      onTap: () => _addAmount(amount),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            amount == '000'
                ? '+000'
                : '+${NumberFormat.compact().format(int.parse(amount))}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  // Build category selector
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
            value: _selectedCategoryId,
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
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategoryId = newValue!;
              });
            },
            items: _categories.map<DropdownMenuItem<String>>((MyCategory category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            validator: (value) =>
                value == null ? 'Vui lòng chọn danh mục' : null,
          ),
        ],
      ),
    );
  }

  // Build description field
  Widget _buildDescriptionField() {
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
            controller: _descriptionController,
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

  // Build save button
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _selectedType == TransactionType.expense
              ? [const Color(0xFFee0979), const Color(0xFFff6a00)]
              : [const Color(0xFF11998e), const Color(0xFF38ef7d)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_selectedType == TransactionType.expense
                    ? const Color(0xFFee0979)
                    : const Color(0xFF11998e))
                .withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              final transactionsManager = Provider.of<TransactionsManager>(context, listen: false);
              final amount = double.parse(_amountController.text.replaceAll('.', ''));
              final description = _descriptionController.text;
              final categoryId = _selectedCategoryId!;
              final type = _selectedType.toString().split('.').last;

              final newTransaction = Transaction(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                amount: amount,
                description: description,
                date: DateTime.now(),
                categoryId: categoryId,
                type: type,
              );

              transactionsManager.addTransaction(newTransaction);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Đã thêm giao dịch thành công!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF11998e),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );

              Navigator.pop(context);
            }
          },
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
                  'Lưu giao dịch',
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
