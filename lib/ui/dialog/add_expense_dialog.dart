import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:flutter/material.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  String _name = "", _description = "";
  double _amount = 0.0;
  String? _nameError, _descError, _amountError;

  void _onNameChanged(String value) {
    setState(() {
      _name = value;
      _nameError != null;
    });
  }

  void _onDescChanged(String value) {
    setState(() {
      _description = value;
      _descError != null;
    });
  }

  void _onAmountChanged(String value) {
    setState(() {
      _amount = double.parse(value);
      _amountError != null;
    });
  }

  void _onCancel() {
    Navigator.pop(context, "Cancel");
    print("Cancelled creation");
  }

  void _onConfirm() {
    Navigator.pop(context, 'OK');
    print(
      "New Expense Created: Name: $_name, Amount: $_amount, Description: $_description",
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Expense"),
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
                  errorText: _descError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              FilledButton(onPressed: () => _onConfirm(), child: Text("Add")),
            ],
          ),
        ),
      ),
    );
  }
}
