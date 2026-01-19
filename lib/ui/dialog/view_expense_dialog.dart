import 'package:expense_v2/data/model/expense.dart';
import 'package:flutter/material.dart';

class ViewExpenseDialog extends StatelessWidget {
  const ViewExpenseDialog({
      required this.expense,
      super.key
  });

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(expense.name),
      content: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(expense.description ?? ""),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text(expense.amount.toString())],
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ),
      ),
    );
  }
}
