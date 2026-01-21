import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/model/expense.dart';
import 'package:expense_v2/data/repo/category_repo_fire_impl.dart';
import 'package:expense_v2/data/repo/expense_repo_fire_impl.dart';
import 'package:expense_v2/ui/components/expense_item.dart';
import 'package:expense_v2/ui/dialog/view_expense_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewCategoryScreen extends StatefulWidget {
  const ViewCategoryScreen({required this.categoryId, super.key});

  final String categoryId;

  @override
  State<ViewCategoryScreen> createState() => _ViewCategoryScreenState();
}

class _ViewCategoryScreenState extends State<ViewCategoryScreen> {
  final categoryRepo = CategoryRepoFireImpl();
  final expenseRepo = ExpenseRepoFireImpl();
  Category? category;
  Category categoryData = Category();
  List<Expense>? expenses;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    category = await categoryRepo.getCategoryById(widget.categoryId);
    if (category != null || expenses != null) {
      setState(() {
        categoryData = category!;
      });
    } else {
      debugPrint("category found from categoryName is null");
    }
  }

  void _showExpenseDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ViewExpenseDialog(expense: expense);
      },
    );
  }

  void _navigateToAddExpenses(String categoryName) {
    context.go('/categories/${widget.categoryId}/add_expenses');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                stretch: true,
                pinned: true,
                floating: false,
                snap: false,
                flexibleSpace: FlexibleSpaceBar(title: Text(categoryData.name)),
              ),
              // TODO: Use delegate
              StreamBuilder(
                stream: expenseRepo.getAllExpensesInGroup(categoryData.name),
                builder: (context, AsyncSnapshot<List<Expense>> asyncData) {
                  if (asyncData.connectionState == ConnectionState.waiting) {
                    // Using non Sliver widgets necessitates a SliverToBoxAdapter
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (asyncData.hasData) {
                    final expenses = asyncData.data ?? [];
                    if (expenses.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No Expenses found in ${categoryData.name}',
                            ),
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
          right: 16.0,
          bottom: 16.0,
          child: FloatingActionButton.extended(
            onPressed: () => _navigateToAddExpenses(categoryData.name),
            icon: Icon(Icons.add),
            label: Text("Add Existing Expense to ${categoryData.name}"),
          ),
        ),

      ],
    );
  }
}
