import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/user_repo_fire_impl.dart';
import 'package:fl_chart/fl_chart.dart';
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

  int touchedIndex = -1;

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

                  final nonZeroExpenses = totalExpensePerCategory.entries
                      .where((category) => category.value > 0)
                      .toList();

                  return AspectRatio(
                    aspectRatio: 2,
                    child: Row(
                      children: [
                        const SizedBox(width: 28),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildIndicators(nonZeroExpenses),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                        setState(() {
                                          if (!event
                                                  .isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection ==
                                                  null) {
                                            touchedIndex = -1;
                                            return;
                                          }
                                          touchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        });
                                      },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: _buildPieChartSections(
                                  totalExpensePerCategory,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildIndicators(
    List<MapEntry<String, double>> nonZeroExpenses,
  ) {
    if (nonZeroExpenses.isEmpty) {
      return [Text('No expenses', style: TextStyle(color: Colors.grey))];
    }

    final totalExpense = nonZeroExpenses.fold(
      0.0,
      (sum, category) => sum + category.value,
    );

    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return nonZeroExpenses.asMap().entries.map((entry) {
      final i = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / totalExpense) * 100;
      final color = colors[i % colors.length];

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryEntry.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '\$${categoryEntry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> totalExpensePerCategory,
  ) {
    final nonZeroExpenses = totalExpensePerCategory.entries
        .where((category) => category.value > 0)
        .toList();

    if (nonZeroExpenses.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'No data',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
      ];
    }

    final totalExpense = nonZeroExpenses.fold(
      0.0,
      (sum, category) => sum + category.value,
    );

    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return List.generate(nonZeroExpenses.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      final category = nonZeroExpenses[i];
      final percentage = (category.value / totalExpense) * 100;
      final color = colors[i % colors.length];

      return PieChartSectionData(
        color: color,
        value: category.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    });
  }
}
