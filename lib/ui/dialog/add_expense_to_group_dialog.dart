import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:expense_v2/ui/dialog/month_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddExpenseToGroupDialog extends StatefulWidget {
  const AddExpenseToGroupDialog({required this.groupName, super.key});

  final String groupName;

  @override
  State<AddExpenseToGroupDialog> createState() => _AddExpenseToGroupState();
}

class _AddExpenseToGroupState extends State<AddExpenseToGroupDialog> {
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
        return MonthPickerDialog(
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

  void _onCancel() {
    Navigator.pop(context, "Cancel");
    debugPrint("Cancelled creation");
  }

  void _onConfirm() async {
    if (_validateFields()) {
      try {
        final username = await userRepo.getUsername();
        final expenseWithGroupName = Expense(
          name: _name,
          amount: _amount,
          description: _description,
          groupName: widget.groupName,
          whopaid: username,
          createdAt: _selectedDate,
        );
        await expenseRepo.addExpense(expenseWithGroupName);
        if (!mounted) return;
        Navigator.pop(context, 'OK');
        debugPrint(
          "Successfully added an expense: $_name, $_amount, $_description to ${widget.groupName}",
        );
      } on Exception catch (e) {
        context.go('/login');
        debugPrint(
          "Something went wrong when trying to create an expense: ${e.toString()}",
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          // TODO: maybe a modal to show error
          _nameError = "Failed to add expense.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Expense to ${widget.groupName}"),
      content: Padding(
        padding: EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextField(
                onChanged: (value) => _onNameChanged(value),
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
