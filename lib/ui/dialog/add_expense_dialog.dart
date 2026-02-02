import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:expense_v2/ui/dialog/add_expense_date_to_group_dialog.dart';
import 'package:flutter/material.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final userRepo = UserRepoFireImpl();
  final expenseRepo = ExpenseRepoFireImpl();

  String _name = "", _description = "";
  double _amount = 0.0;
  DateTime _selectedDate = DateTime.now();
  String? _nameError, _amountError;

  bool _validateFields() {
    final nameError = _name.isEmpty ? "Name cannot be empty" : null;
    final amountError = _amount <= 0 ? "Invalid amount" : null;
    setState(() {
      _nameError = nameError;
      _amountError = amountError;
    });
    // Error assignments happen before function exits
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

  // TODO: cancel button?
  // void _onCancel() {
  //   Navigator.pop(context, "Cancel");
  //   debugPrint("Cancelled creation");
  // }

  void _onConfirm() async {
    if (_validateFields()) {
      try {
        final username = await userRepo.getUsername();
        final expense = Expense(
          name: _name,
          amount: _amount,
          description: _description,
          whopaid: username,
          createdAt: _selectedDate,
        );
        debugPrint(expense.toString());
        final addedExpense = await expenseRepo.addExpense(expense);
        if (addedExpense) {
          if (!mounted) return;
          Navigator.pop(context, 'OK');
        } else {
          _nameError = "expense name is already taken";
        }
      } on Exception catch (e) {
        setState(() {
          _nameError = e.toString();
        });
      } catch (_) {
        setState(() {
          _nameError = "Failed to add expense.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Expense"),
      content: Padding(
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                onChanged: (value) => _onNameChanged(value),
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
