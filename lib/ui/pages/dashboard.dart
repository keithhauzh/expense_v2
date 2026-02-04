import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/pie_chart_component.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final userRepo = UserRepoFireImpl();
  final categoryRepo = CategoryRepoFireImpl();
  final expensesRepo = ExpenseRepoFireImpl();
  Stream<List<Category>> categories = Stream.value([]);
  Stream<List<Expense>> expenses = Stream.value([]);
  String? username;
  bool _loading = true;

  Future<void> _init() async {
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
    final categoriesFromRepo = categoryRepo.getAllCategories();
    final expensesFromRepo = expensesRepo.getAllExpensesForCurrentUser(
      username!,
    );
    setState(() {
      categories = categoriesFromRepo;
      expenses = expensesFromRepo;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StreamBuilder<List<Category>>(
            stream: categories,
            builder: (context, AsyncSnapshot<List<Category>> categorySnapshot) {
              return StreamBuilder<List<Expense>>(
                stream: expenses,
                builder: (context, AsyncSnapshot<List<Expense>> expenseSnapshot) {
                  if (!expenseSnapshot.hasData ||
                      !categorySnapshot.hasData ||
                      _loading) {
                    return SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final categoryList = categorySnapshot.data!;
                  final expenseList = expenseSnapshot.data!;

                  final Map<String, double> totalExpensePerCategory = {};
                  for (Category category in categoryList) {
                    double expensesSum = 0.0;

                    for (Expense expense in expenseList) {
                      if (expense.categoryName != null &&
                          expense.categoryName == category.name) {
                        expensesSum += expense.amount;
                      }
                    }

                    totalExpensePerCategory[category.name] = expensesSum;
                  }

                  // Add uncategorized expenses
                  double uncategorizedSum = 0.0;
                  for (Expense expense in expenseList) {
                    // Check if expense has no category or empty category
                    if (expense.categoryName == null ||
                        expense.categoryName!.isEmpty) {
                      uncategorizedSum += expense.amount;
                    } else {
                      // Check if the category actually exists in the category list
                      bool categoryExists = categoryList.any(
                        (c) => c.name == expense.categoryName,
                      );
                      if (!categoryExists) {
                        uncategorizedSum += expense.amount;
                      }
                    }
                  }
                  if (uncategorizedSum > 0) {
                    totalExpensePerCategory['Uncategorized'] = uncategorizedSum;
                  }

                  final nonZeroExpenses = totalExpensePerCategory.entries
                      .where((category) => category.value > 0)
                      .toList();

                  // Pie chart component (lib/ui/components/pie_chart_component.dart)
                  return PieChartComponent(
                    nonZeroExpenses: nonZeroExpenses,
                    totalExpensePerCategory: totalExpensePerCategory,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
