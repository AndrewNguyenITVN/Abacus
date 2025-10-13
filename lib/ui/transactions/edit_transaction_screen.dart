import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../categories/categories_manager.dart';

enum TransactionType { expense, income }

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TransactionType _selectedType;
  final _categoriesManager = CategoriesManager();
  late List<Category> _categories;
  late String? _selectedCategoryId;

  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing transaction data
    _selectedType = widget.transaction.type == 'income' 
        ? TransactionType.income 
        : TransactionType.expense;
    
    _selectedCategoryId = widget.transaction.categoryId;
    
    // Format amount for display
    final formatter = NumberFormat('#,###');
    _amountController.text = formatter
        .format(widget.transaction.amount.toInt())
        .replaceAll(',', '.');
    
    _descriptionController.text = widget.transaction.description;
    _noteController.text = widget.transaction.note ?? '';
    
    _updateCategories();
  }

  void _updateCategories() {
    setState(() {
      _categories = _selectedType == TransactionType.expense
          ? _categoriesManager.expenseCategories
          : _categoriesManager.incomeCategories;
      
      // Check if current category exists in new category list
      final categoryExists = _categories.any((c) => c.id == _selectedCategoryId);
      if (!categoryExists) {
        _selectedCategoryId = null;
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
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

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.replaceAll('.', ''));
      final description = _descriptionController.text;
      final note = _noteController.text;
      final categoryId = _selectedCategoryId;
      final type = _selectedType.toString().split('.').last;

      // Log for now (in a real app, you would update the transaction in a database)
      print('Updated Transaction ID: ${widget.transaction.id}');
      print('Amount: $amount');
      print('Description: $description');
      print('Note: $note');
      print('Category ID: $categoryId');
      print('Type: $type');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật giao dịch')),
      );

      // Return to previous screen
      Navigator.of(context).pop();
    }
  }

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                // Log for now (in a real app, you would delete from database)
                print('Deleted Transaction ID: ${widget.transaction.id}');
                
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to transactions screen
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa giao dịch')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa giao dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTransaction,
            tooltip: 'Xóa giao dịch',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                      value: TransactionType.expense, label: Text('Chi tiêu')),
                  ButtonSegment(
                      value: TransactionType.income, label: Text('Thu nhập')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _updateCategories();
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  icon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var amount in ['1000', '10000', '100000', '000'])
                    ElevatedButton(
                      onPressed: () => _addAmount(amount),
                      child: Text(amount == '000'
                          ? '000'
                          : NumberFormat.compact().format(int.parse(amount))),
                    )
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                hint: const Text('Chọn danh mục'),
                icon: const Icon(Icons.category),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategoryId = newValue!;
                  });
                },
                items: _categories.map<DropdownMenuItem<String>>((Category category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn danh mục' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  icon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      child: const Text('Lưu thay đổi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

