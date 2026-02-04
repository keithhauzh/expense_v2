import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/expense_item.dart';
import 'package:expense_v2/ui/dialog/month_picker_dialog.dart';
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
  DateTime selectedMonth = DateTime.now();
  double monthTotal = 0.0;

  Future<void> _init(BuildContext context) async {
    // TODO: move this to a helper function?

    // We are using _init() here to check for
    // the current logged in user and also
    // to assign the username to a variable
    // that we use to fetch the respective documents.
    //
    // If username doesn't exist (user is not logged in),
    // we send user back to the login screen
    try {
      // We use mounted here to prevent state problems
      // with navigation
      //
      // mounted is used for checking if
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

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MonthPickerDialog(
          selectedMonth: selectedMonth,
          onMonthSelected: (newMonth) {
            setState(() {
              selectedMonth = newMonth;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  bool _isExpenseInMonth(Expense expense) {
    final created = expense.effectiveCreatedAt;
    // Use effectiveCreatedAt to avoid null checking
    return created.year == selectedMonth.year &&
        created.month == selectedMonth.month;
  }

  double _calculateMonthTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Convert the stream to a broadcast to allow multiple listeners
    final expensesStream =
        (selectedCategories == null || selectedCategories!.isEmpty)
        ? expenseRepo
              .getAllExpensesForCurrentUser(username!)
              .asBroadcastStream()
        : expenseRepo
              .getAllExpensesForCurrentUser(username!)
              .map(
                (list) => list
                    .where((e) => selectedCategories!.contains(e.categoryName))
                    .toList(),
              )
              .asBroadcastStream();

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
              // Pinned Month Selector
              StreamBuilder(
                stream: expensesStream,
                builder: (context, AsyncSnapshot<List<Expense>> asyncData) {
                  final allExpenses = asyncData.data ?? [];
                  final monthExpenses = allExpenses
                      .where(_isExpenseInMonth)
                      .toList();
                  final total = _calculateMonthTotal(monthExpenses);
                  return SliverPersistentHeader(
                    pinned: true,
                    delegate: MonthSelectorDelegate(
                      selectedMonth: selectedMonth,
                      onMonthPressed: _showMonthPicker,
                      totalExpenses: total,
                    ),
                  );
                },
              ),
              StreamBuilder(
                stream: expensesStream,
                builder: (context, AsyncSnapshot<List<Expense>> asyncData) {
                  if (asyncData.connectionState == ConnectionState.waiting) {
                    // Using non Sliver widgets necessitates a SliverToBoxAdapter
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (asyncData.hasData) {
                    final expenses = asyncData.data ?? [];
                    final monthExpenses = expenses
                        .where(_isExpenseInMonth)
                        .toList();

                    if (monthExpenses.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Expenses',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No expenses found for ${_formatMonth(selectedMonth)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.all(8.0),
                      sliver: SliverList.builder(
                        itemBuilder: (context, index) => ExpenseItem(
                          expense: monthExpenses[index],
                          onClickItem: (expense) => _showExpenseDialog(expense),
                        ),
                        itemCount: monthExpenses.length,
                      ),
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
