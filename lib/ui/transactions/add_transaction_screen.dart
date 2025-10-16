import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/my_category.dart';
import '../../models/transaction.dart';
import '../categories/categories_manager.dart';
import '../transactions/transactions_manager.dart';

enum TransactionType { expense, income }

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
      appBar: AppBar(title: const Text('Thêm giao dịch')),
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
                items: _categories.map<DropdownMenuItem<String>>((MyCategory category) {
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
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
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
                      const SnackBar(content: Text('Đã thêm giao dịch mới')),
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text('Lưu giao dịch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
