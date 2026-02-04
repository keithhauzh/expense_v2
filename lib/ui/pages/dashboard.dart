import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/pie_chart_component.dart';
import 'package:expense_v2/ui/components/monthly_trend_chart.dart';
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
  Stream<List<Category>>? categories;
  Stream<List<Expense>>? expenses;
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
      
      final categoriesFromRepo = categoryRepo.getAllCategories();
      final expensesFromRepo = expensesRepo.getAllExpensesForCurrentUser(
        username!,
      );
      
      // We set _loading to be false if username
      // is not null and set the streams
      if (mounted) {
        setState(() {
          categories = categoriesFromRepo;
          expenses = expensesFromRepo;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || categories == null || expenses == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StreamBuilder<List<Category>>(
            stream: categories!,
            builder: (context, AsyncSnapshot<List<Category>> categorySnapshot) {
              return StreamBuilder<List<Expense>>(
                stream: expenses!,
                builder: (context, AsyncSnapshot<List<Expense>> expenseSnapshot) {
                  if (!expenseSnapshot.hasData ||
                      !categorySnapshot.hasData) {
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

                  // Calculate monthly totals for trend chart
                  final monthlyTotals = _aggregateMonthlyExpenses(expenseList);

                  // Return both charts in a column
                  return Column(
                    children: [
                      PieChartComponent(
                        nonZeroExpenses: nonZeroExpenses,
                        totalExpensePerCategory: totalExpensePerCategory,
                      ),
                      MonthlyTrendChart(monthlyTotals: monthlyTotals),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Map<DateTime, double> _aggregateMonthlyExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    
    // Generate last 6 months including current
    final last6Months = List.generate(6, (index) {
      return DateTime(currentMonth.year, currentMonth.month - index, 1);
    }).reversed.toList();

    // Initialize all months with 0
    final Map<DateTime, double> monthlyTotals = {
      for (var month in last6Months) month: 0.0
    };

    // Aggregate expenses by month
    for (var expense in expenses) {
      final expenseDate = expense.effectiveCreatedAt;
      final monthKey = DateTime(expenseDate.year, expenseDate.month, 1);
      
      // Only include expenses from the last 6 months
      if (monthlyTotals.containsKey(monthKey)) {
        monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0.0) + expense.amount;
      }
    }

    return monthlyTotals;
  }
}
