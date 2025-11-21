import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/transaction.dart';
import '/models/transaction_type.dart';
import '/models/my_category.dart';
import '/ui/categories/categories_manager.dart';
import '/ui/transactions/transactions_manager.dart';
import 'transaction_helpers.dart';
import 'transaction_form.dart';

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

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final transactionsManager = Provider.of<TransactionsManager>(context, listen: false);
      
      final amount = TransactionHelpers.parseAmount(_amountController.text)!;
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

      try {
        await transactionsManager.addTransaction(newTransaction);

        if (mounted) {
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: TransactionForm(
            selectedType: _selectedType,
            onTypeChanged: (type) {
              setState(() {
                _selectedType = type;
                _updateCategories();
              });
            },
            amountController: _amountController,
            onAmountChanged: () => setState(() {}),
            categories: _categories,
            selectedCategoryId: _selectedCategoryId,
            onCategoryChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
            descriptionController: _descriptionController,
            actionButtonText: 'Lưu giao dịch',
            onActionTap: _saveTransaction,
          ),
        ),
      ),
    );
  }
}
