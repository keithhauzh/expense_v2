import 'package:expense_v2/data/model/expense.dart';
import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  const ExpenseItem({
    super.key,
    required this.expense,
    required this.onClickItem,
  });
  final Expense expense;
  final Function(Expense) onClickItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClickItem(expense),
      child: Card(
        margin: const EdgeInsets.all(10.0),
        child: Container(
          margin: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [Text(expense.name), Text(expense.description ?? "")],
              ),
              Text(expense.amount.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
