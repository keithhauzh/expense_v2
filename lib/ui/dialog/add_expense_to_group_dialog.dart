import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
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
