import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/expense_item.dart';
import 'package:expense_v2/ui/dialog/sort_by_category_dialog.dart';
import 'package:expense_v2/ui/dialog/view_expense_dialog.dart';
import 'package:flutter/material.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final repo = ExpenseRepoFireImpl();
  List<String>? _selectedCategories;
  List<Expense>? expenses;

  void _showExpenseDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ViewExpenseDialog(expense: expense);
      },
    );
  }

  void _triggerSort() async {
    // Here, we wait for the result to come back from sort_by_category_dialog
    final List<String>? selected = await showDialog(
      context: context,
      builder: (_) => SortByCategoryDialog(),
    );
    if (selected != null) {
      setState(() {
        debugPrint(selected.toString());
        _selectedCategories = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Using a stack allows us to position certain elements, in this case, a FloatingActionButton widget
      // at a certain point in the window, we use Positioned widgets to do this, the reason i am using
      // this implementation instead of a Scaffold and FloatingActionButton is because you should not
      // nest Scaffold widgets within Scaffold widgets
      // this page is a nested class inside of main.dart/navigation.dart
      children: [
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              StreamBuilder(
                stream: _selectedCategories == null
                    ? repo.getAllExpenses()
                    : repo.getAllExpenses().map(
                        (expenses) => expenses
                            .where(
                              (expense) => _selectedCategories!.contains(
                                expense.categoryName,
                              ),
                            )
                            .toList(),
                      ),
                builder: (context, AsyncSnapshot<List<Expense>> asyncData) {
                  if (asyncData.connectionState == ConnectionState.waiting) {
                    // Using non Sliver widgets necessitates a SliverToBoxAdapter
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (asyncData.hasData) {
                    final expenses = asyncData.data ?? [];

                    if (expenses.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No Expenses Found'),
                          ),
                        ),
                      );
                    }

                    return SliverList.builder(
                      itemBuilder: (context, index) => ExpenseItem(
                        expense: expenses[index],
                        onClickItem: (expense) => _showExpenseDialog(expense),
                        // safe to index now
                      ),
                      itemCount: expenses.length,
                    );
                  } else {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(asyncData.error.toString())),
                    );
                  }
                },
              ),
            ],
          ),
        ),

        Positioned(
          left: 16.0,
          bottom: 16.0,
          child: FloatingActionButton.extended(
            label: Text("All"),
            onPressed: _triggerSort,
            icon: Icon(Icons.sort),
          ),
        ),
      ],
    );
  }
}
