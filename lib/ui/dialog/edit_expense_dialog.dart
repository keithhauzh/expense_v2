import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/ui/dialog/add_expense_date_to_group_dialog.dart';
import 'package:flutter/material.dart';

class EditExpenseDialog extends StatefulWidget {
  final Expense expense;
  
  const EditExpenseDialog({super.key, required this.expense});

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  final expenseRepo = ExpenseRepoFireImpl();

  late String _name, _description;
  late double _amount;
  late DateTime _selectedDate;
  String? _nameError, _amountError;
  
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _name = widget.expense.name;
    _description = widget.expense.description ?? '';
    _amount = widget.expense.amount;
    _selectedDate = widget.expense.effectiveCreatedAt;
    
    _nameController = TextEditingController(text: _name);
    _amountController = TextEditingController(text: _amount.toString());
    _descController = TextEditingController(text: _description);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final nameError = _name.isEmpty ? "Name cannot be empty" : null;
    final amountError = _amount <= 0 ? "Invalid amount" : null;
    setState(() {
      _nameError = nameError;
      _amountError = amountError;
    });
    if (_name.isEmpty || _amount <= 0.0) {
      return false;
    }
    return true;
  }

  void _onNameChanged(String value) {
    setState(() {
      _name = value;
      _nameError = null;
    });
  }

  void _onDescChanged(String value) {
    setState(() {
      _description = value;
    });
  }

  void _onAmountChanged(String value) {
    setState(() {
      double? amountToBeParsed = double.tryParse(value);
      if (amountToBeParsed != null) {
        _amount = amountToBeParsed;
        _amountError = null;
      } else {
        _amount = 0.0;
      }
    });
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExpenseDateToExpenseDialog(
          selectedMonth: _selectedDate,
          onMonthSelected: (newMonth) {
            setState(() {
              _selectedDate = DateTime(newMonth.year, newMonth.month, 1);
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  String _formatMonth(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _onConfirm() async {
    if (_validateFields()) {
      try {
        final updatedExpense = widget.expense.copy(
          name: _name,
          amount: _amount,
          description: _description,
          createdAt: _selectedDate,
        );
        await expenseRepo.updateExpense(updatedExpense);
        if (!mounted) return;
        Navigator.pop(context, 'OK');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated successfully')),
        );
      } catch (e) {
        setState(() {
          _nameError = "Failed to update expense: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Expense"),
      content: Padding(
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                onChanged: (value) => _onNameChanged(value),
                controller: _nameController,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: "Enter Name",
                  errorText: _nameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) => _onAmountChanged(value),
                controller: _amountController,
                maxLength: 15,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: "Enter Amount",
                  errorText: _amountError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) => _onDescChanged(value),
                controller: _descController,
                minLines: 3,
                maxLines: null,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: "Enter Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _showMonthPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatMonth(_selectedDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              FilledButton(
                onPressed: () => _onConfirm(),
                child: Text("Confirm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
