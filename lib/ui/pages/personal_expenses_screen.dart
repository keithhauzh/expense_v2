import 'package:expense_v2/ui/dialog/add_expense_dialog.dart';
import 'package:flutter/material.dart';

class PersonalExpensesScreen extends StatefulWidget {
  const PersonalExpensesScreen({super.key});

  @override
  State<PersonalExpensesScreen> createState() => _PersonalExpensesScreen();
}

class _PersonalExpensesScreen extends State<PersonalExpensesScreen> {
  void _triggerModal() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddExpenseDialog();
      },
    );

    if (result == 'OK') {
      print("Expense Added Successfully");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Using a stack allows us to position certain elements, in this case, a FloatingActionButton widget
      // at a certain point in the window, we use Positioned widgets to do this, the reason i am using
      // this implementation instead of a Scaffold and FloatingActionButton is because you should not
      // nest Scaffold widgets within Scaffold widgets (this page is a nested class inside of main.dart)
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Personal Expenses',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),

        // We position the FloatingActionButton on this page to be on the bottom right
        // in this window
        Positioned(
          right: 16.0,
          bottom: 16.0,
          child: FloatingActionButton(
            onPressed: _triggerModal,
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
