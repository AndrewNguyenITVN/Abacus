import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/models/transaction.dart';
import '/models/transaction_type.dart';
import '/models/my_category.dart';
import '/ui/categories/categories_manager.dart';
import '/ui/transactions/transactions_manager.dart';
import '../shared/app_helpers.dart';
import 'transaction_form.dart';
import 'package:go_router/go_router.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TransactionType _selectedType;
  late List<MyCategory> _categories;
  String? _selectedCategoryId;
  String? _imagePath;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing transaction data
    _selectedType = widget.transaction.type == 'income' 
        ? TransactionType.income 
        : TransactionType.expense;
    
    _selectedCategoryId = widget.transaction.categoryId;
    _imagePath = widget.transaction.imagePath;
    
    // Format amount for display
    final formatter = NumberFormat.decimalPattern('vi_VN');
    _amountController.text = formatter.format(widget.transaction.amount);
    
    _descriptionController.text = widget.transaction.description;
    
    _updateCategories();
  }

  void _updateCategories() {
    final categoriesManager = Provider.of<CategoriesManager>(context, listen: false);
    setState(() {
      _categories = _selectedType == TransactionType.expense
          ? categoriesManager.expenseCategories
          : categoriesManager.incomeCategories;
      
      // Check if current category exists in new category list (if switching types)
      final categoryExists = _categories.any((c) => c.id == _selectedCategoryId);
      if (!categoryExists && _selectedType != (widget.transaction.type == 'income' ? TransactionType.income : TransactionType.expense)) {
         _selectedCategoryId = null;
      }
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
      
      final amount = AppHelpers.parseAmount(_amountController.text)!;
      final description = _descriptionController.text;
      final categoryId = _selectedCategoryId!;
      final type = _selectedType.toString().split('.').last;

      final updatedTransaction = Transaction(
        id: widget.transaction.id,
        userId: widget.transaction.userId,
        amount: amount,
        description: description,
        date: widget.transaction.date,
        categoryId: categoryId,
        type: type,
        note: widget.transaction.note,
        imagePath: _imagePath,
      );

      try {
        await transactionsManager.updateTransaction(updatedTransaction);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật giao dịch'),
              behavior: SnackBarBehavior.floating,
            ),
          );

          //Navigator.of(context).pop();
          context.pop();
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

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              //onPressed: () => Navigator.of(context).pop(),
              onPressed: () => context.pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final transactionsManager = Provider.of<TransactionsManager>(context, listen: false);
                
                try {
                  await transactionsManager.deleteTransaction(widget.transaction.id);
                  
                  if (mounted) {
                    //Navigator.of(context).pop(); // Close dialog
                    context.pop();
                    //Navigator.of(context).pop(); // Return to transactions screen
                    context.pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa giao dịch')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    //Navigator.of(context).pop(); // Close dialog
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        title: const Text(
          'Chỉnh sửa giao dịch',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteTransaction,
            tooltip: 'Xóa giao dịch',
          ),
        ],
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
            actionButtonText: 'Cập nhật giao dịch',
            onActionTap: _saveTransaction,
            imagePath: _imagePath,
            onImageChanged: (path) => setState(() => _imagePath = path),
          ),
        ),
      ),
    );
  }
}
