import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/expense_item.dart';
import 'package:expense_v2/ui/dialog/sort_by_category_dialog.dart';
import 'package:expense_v2/ui/dialog/view_expense_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final expenseRepo = ExpenseRepoFireImpl();
  final userRepo = UserRepoFireImpl();
  List<String>? selectedCategories;
  List<Expense>? expenses;
  String? username;
  bool _loading = true;

  Future<void> _init(BuildContext context) async {
    try {
      // We use mounted here to prevent state problems
      // with navigation
      //
      // Mounted is used for checking if
      // the state object we are operating on
      // is currently active in the widget tree
      // this is helps avoid erros when performing
      // async operations
      username = await userRepo.getUsername();
      if (username == null || username!.isEmpty) {
        if (mounted) context.go('/login');
        debugPrint("Please sign in first.");
        return;
      }
			// We set _loading to be false if username
			// is not null
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _init(context);
  }

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
      builder: (_) =>
          SortByCategoryDialog(selectedCategories: selectedCategories ?? []),
    );
    if (selected != null) {
      setState(() {
        selectedCategories = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                stream:
                    selectedCategories == null || selectedCategories!.isEmpty
                    ? expenseRepo.getAllExpensesForCurrentUser(username!)
                    : expenseRepo
                          .getAllExpensesForCurrentUser(username!)
                          .map(
                            (expenses) => expenses
                                .where(
                                  (expense) => selectedCategories!.contains(
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
            label: Text(
              selectedCategories == null || selectedCategories!.isEmpty
                  ? "All"
                  : selectedCategories!.join(", ").toString(),
            ),
            onPressed: _triggerSort,
            icon: Icon(Icons.sort),
          ),
        ),
      ],
    );
  }
}
